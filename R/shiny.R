withMathJax2 <- function (...) {
  path <- "https://mathjax.rstudio.com/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"
  mathjaxConfig <- shiny::HTML("
    MathJax.Hub.Config({
      tex2jax: { inlineMath: [['$', '$'], ['\\\\(', '\\\\)']] }
    })
  ")
  shiny::tagList(
          shiny::tags$head(shiny::tags$script(mathjaxConfig, type = "text/x-mathjax-config")),
          shiny::tags$head(shiny::singleton(shiny::tags$script(src = path, type = "text/javascript"))), 
          ..., shiny::tags$script(shiny::HTML("if (window.MathJax) MathJax.Hub.Queue([\"Typeset\", MathJax.Hub]);")))
}

cell_to_ui_element <- function(cell) {
  if("view" %in% class(cell$result)) {
    view_call <- attr(cell$result, 'call')
    view_type <- as.character(view_call$fun[[1]])
    
    if(view_type == "slider") {
      return(
        shiny::sliderInput(
          inputId = cell$id,
          label   = view_call$title,
          min     = view_call$min,
          max     = view_call$max,
          value   = view_call$value,
          step    = view_call$step
        )
      )
    }
  }
  else if(any(c("html", "md") %in% class(cell$result))) {
    return(
      shiny::uiOutput(
        outputId = cell$id
      )
    )
  }
  else if(cell$hasImage == TRUE) {
    return(
      shiny::plotOutput(
        outputId = cell$id
      )
    )
  }
  else if(is.null(cell$name)) {
    return(
      shiny::textOutput(
        outputId = cell$id
      )
    )
  }
}

fixNames <- function(notebook, cell, input_names) {
  neighbors <- igraph::neighbors(notebook$get_graph(), cell$id, mode = "out")
  depend_names <- igraph::get.vertex.attribute(notebook$get_graph(), "name", neighbors)
  if(length(depend_names) == 0) return("")
  #glue::glue("{depend_names} <- {depend_names}Reactive()")
  paste0(ifelse(depend_names %in% input_names,
    glue::glue("`{depend_names}` <- input$`{depend_names}`"),
    glue::glue("`{depend_names}` <- `{depend_names}Reactive`()")
  ), collapse = "\n")
}

#' Run a reactor notebook in Shiny
#' 
#' @param notebook Reactor notebook
#' 
#' importFrom shiny fluidPage
#' importFrom glue glue
#'
#' @export
start_reactor_as_shiny <- function(notebook) {
  
  ui_elements <- lapply(notebook$cells[order(unlist(lapply(notebook$cells, `[[`, 'position')))], cell_to_ui_element)
  
  ui <- shiny::fixedPage(ui_elements)
  
  server <- function(input, output) {
    reactives <- list()
    
    eval_text <- c()
    
    for(cell in notebook$cells) {
      cell_eval <- cell
      cell_eval$result <- NULL
      
      # View
      if("view" %in% class(cell$result)) {
        observer <- glue::glue("
        shiny::observeEvent(input$`<<cell$id>>`, {
          notebook$update_from_view(list(id = '<<cell$id>>', name = '<<cell$name>>'), input$`<<cell$id>>`, capturePlots = FALSE)
        }, priority = 100)", .open = "<<", .close = ">>") 
        eval_text <- c(eval_text, observer)
      }
      
      # HTML
      else if(c("html") %in% class(cell$result)) {
        dependencies <- fixNames(notebook, cell, shiny::isolate(names(input)))
        render_text <- glue::glue("
        output$`<<cell$id>>` <- shiny::renderUI({
          <<dependencies>>
          notebook$run_cell(<<list(cell_eval)>>)
          shiny::HTML(notebook$cells$`<<cell$id>>`$result)
        })", .open = "<<", .close = ">>")
        eval_text <- c(eval_text, render_text)
      }
      
      # Markdown
      else if(c("md") %in% class(cell$result)) {
        dependencies <- fixNames(notebook, cell, shiny::isolate(names(input)))
        render_text <- glue::glue("
        output$`<<cell$id>>` <- shiny::renderUI({
          <<dependencies>>
          notebook$run_cell(<<list(cell_eval)>>)
          withMathJax2(
            shiny::HTML(commonmark::markdown_html(notebook$cells$`<<cell$id>>`$result))
          )
        })", .open = "<<", .close = ">>")
        eval_text <- c(eval_text, render_text)
      }
      
      # Plot
      else if(cell$hasImage == TRUE) {
        dependencies <- fixNames(notebook, cell, shiny::isolate(names(input)))
        render_text <- glue::glue("
        output$`<<cell$id>>` <- shiny::renderPlot({
          <<dependencies>>
          notebook$run_cell(<<list(cell_eval)>>, capturePlots = FALSE)
          notebook$cells$`<<cell$id>>`$result
        })", .open = "<<", .close = ">>")
        eval_text <- c(eval_text, render_text)
      }
      
      # Reactive variable
      else if(!is.null(cell$name)) {
        dependencies <- fixNames(notebook, cell, shiny::isolate(names(input)))
        reactive_text <- glue::glue("
        `<<cell$id>>Reactive` <- shiny::reactive({
          <<dependencies>>
          notebook$cells$`<<cell$id>>`$result
        })", .open = "<<", .close = ">>")
        eval_text <- c(eval_text, reactive_text)
      }
      
      # Render everything else as text
      else {
        dependencies <- fixNames(notebook, cell, shiny::isolate(names(input)))
        render_text <- glue::glue("
        output$`<<cell$id>>` <- shiny::renderText({
          <<dependencies>>
          notebook$run_cell(<<list(cell_eval)>>)
          res <- notebook$cells$`<<cell$id>>`$result
          if(is.null(res)) return('')
          res
        })", .open = "<<", .close = ">>")
        eval_text <- c(eval_text, render_text)
      }
    }
    
    eval(parse(text = eval_text))
  }
  
  shiny::shinyApp(ui = ui, server = server)
}

export_shiny <- function(notebook, directory) {
  notebook$save(paste0(directory, "/notebook.Rmd"))
  txt <- glue::glue("
# shinyApp

library(shiny)
library(reactor)

notebook <- ReactorNotebook$load('notebook.Rmd')

start_reactor_as_shiny(notebook)
  ")
  
  cat(txt, file = paste0(directory, "/app.R"))
}