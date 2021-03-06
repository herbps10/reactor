#' Reactor Notebook R6 class
#'
#' @importFrom R6 R6Class
#' @importFrom igraph make_ego_graph topo_sort V add_edges are.connected add_vertices delete_vertices graph.empty
#' @importFrom htmlwidgets saveWidget
#' @importFrom stringr str_detect str_match str_replace str_c
#' @importFrom pryr %<a-%
#' @importFrom ggplot2 last_plot
#' @importFrom purrr map
#' @importFrom dplyr bind_rows arrange
#' @importFrom glue glue
#' @importFrom knitr all_patterns
#' @importFrom knitr knit_patterns
#' @importFrom knitr knit_code
#' @import svglite
#' 
#' @export
ReactorNotebook <- R6Class("ReactorNotebook",
  public = list(
    cells = list(),
    static_dir = "",
    initialize = function(static_dir = tempdir()) {
      private$env <- new.env()
      self$static_dir <- static_dir
    },
    
    run_in_env = function(code) {
      eval(parse(text = code), private$env)
    },
    
    #
    # source: position of cell to move
    # destination: at end of move cell will have position destination
    #
    move = function(source, destination) {
      self$cells <- map(self$cells, function(cell) {
        if(cell$position == source) cell$position <- destination
        cell
      })
      
      private$position_from_rank()
    },
    
    delete_cell = function(cell) {
      if(is.null(self$cells[[cell$id]])) return()
      if(!is.null(self$cells[[cell$id]]$name)) {
        self$run_in_env(paste0("rm(", self$cells[[cell$id]]$name, ")"))
        self$run_in_env(paste0("rm(", self$cells[[cell$id]]$name, "_saved)"))
      }
      
      position <- self$cells[[cell$id]]$position
      
      self$cells[[cell$id]] <- NULL
      
      self$cells <- map(self$cells, function(cell) {
        if(cell$position > position) cell$position <- cell$position - 1
        cell
      })
      
      if(cell$id %in% names(V(private$graph))) {
        private$graph <- delete_vertices(private$graph, V(private$graph)[[cell$id]])
      }
    },
    run_all = function() {
      topo <- topo_sort(private$graph, mode = "in")
      for(cell in self$cells[topo]) {
        self$run_cell(cell, update = FALSE)
      }
    },
    run_cell = function(cell, update = TRUE, capturePlots = TRUE) {
      private$callstack = c()
      
      #
      # Set up plot capturing
      #
      if(capturePlots == TRUE) {
        while(dev.cur() > 1) dev.off()
        
        ggplot2:::.store$set(NULL)
        
        svgPath <- paste0(file.path(self$static_dir, cell$id), ".svg")
        svg(filename = svgPath)
        dev.control(displaylist = "enable")
      }
      
      #
      # Run the cell
      #
      name <- NULL
      if(str_detect(cell$value, "^.+ <-")) {
        name <- str_match(cell$value, "^(.+?) ?<-")[,2]
        modified_cell <- str_replace(cell$value, paste0("^", name), paste0(name, "_saved"))
        self$run_in_env(private$wrap(name))
        res <- self$run_in_env(modified_cell)
      }
      else {
        res <- eval(parse(text = cell$value), private$env)
      }
      
      #
      # Save any html widgets generated by the cell
      #
      if("htmlwidget" %in% class(res)) {
        htmlPath = paste0(file.path(self$static_dir, cell$id), ".html")
        htmlwidgets::saveWidget(res, htmlPath, selfcontained = TRUE)
      }
      
      #
      # Capture any plots from the cell
      # 
      hasImage = FALSE
      if(capturePlots == TRUE) {
        p <- recordPlot()
        p2 <- last_plot()
        dev.off()
        if(!is.null(p2)) {
          ggsave(svgPath)
        }
        hasImage = !is.null(p[[1]]) || !is.null(p2)
      }
      
      #
      # Figure out the cell position
      #
      pos <- unname(cell$position)
      if(is.null(pos) && length(self$cells) > 0) {
        positions <- sapply(self$cells, `[[`, "position")
        pos <- max(positions) + 1
      }
      else if(is.null(pos)){
        pos <- 1
      }
      
      self$cells <- map(self$cells, function(cell) {
        if(cell$position >= pos) cell$position <- cell$position + 1
        cell
      })
      
      # If the cell already exists but has a different name,
      # delete the previous variable.
      if(!is.null(self$cells[[cell$id]]) && !is.null(self$cells[[cell$id]]$name) && !is.null(name) && self$cells[[cell$id]]$name != name) {
        self$run_in_env(paste0("rm(", self$cells[[cell$id]]$name, ")"))
        self$run_in_env(paste0("rm(", self$cells[[cell$id]]$name, "_saved)"))
      }
      
      #
      # Save the cell
      #
      self$cells[[cell$id]] = list(
        id = cell$id,
        value = cell$value,
        position = unname(pos),
        hasImage = hasImage,
        name = name,
        result = res,
        viewWidth = cell$viewWidth,
        viewHeight = cell$viewHeight,
        open = ifelse(is.null(cell$open), FALSE, cell$open)
      );
      
      private$position_from_rank()
      
      
      if(!is.null(name)) {
        private$name_to_id[name] = cell$id
      }
      
      # Add the cell to the cell graph
      if(!(cell$id %in% names(V(private$graph)))) {
        private$graph <- add_vertices(private$graph, 1, name = cell$id)
      }
      
      # Add edges between the new cell and the cells it depends on
      for(call in private$callstack) {
        call_id <- private$name_to_id[call]
        if(!are.connected(private$graph, cell$id, call_id)) {
          private$graph <- add_edges(private$graph, c(cell$id, call_id))
        }
      }
      
      if(is.null(res)) res <- ""
      updates = c(cell$id)
      
      # propagate the new value of this cell to the cells that depend on it
      if(update == TRUE) {
        updates <- c(updates, self$propagate_updates(cell, capturePlots = capturePlots))
      }
      
      updates
    },
    update_from_view = function(cell, value, capturePlots = TRUE) {
      if(!is.null(cell$name) && cell$name != "") {
        self$run_in_env(str_c(cell$name, "_saved[1] = ", value))
      }
      
      updates <- self$propagate_updates(cell, capturePlots = capturePlots)
      updates
    },
    update_size = function(cell, value) {
      if(!is.null(value$width)) {
        self$cells[[cell$id]]$viewWidth = c(value$width)
      }
      
      if(!is.null(value$height)) {
        self$cells[[cell$id]]$viewHeight = c(value$height)
      }
    },
    update_open = function(cell, value) {
      if(!is.null(value$open)) {
        self$cells[[cell$id]]$open <- value$open
      }
    },
    propagate_updates = function(cell, capturePlots = TRUE) {
      # Get dependencies
      updates <- c()
      ego_graph <- make_ego_graph(self$get_graph(), order = 1000, nodes = cell$id, mindist = 0, mode = "in")[[1]]
      
      # Sort dependencies to topological order
      dependencies <- names(topo_sort(ego_graph, mode = "in")[-1])
      
      for(dependency in dependencies) {
        updates <- c(updates, self$run_cell(self$cells[[dependency]], update = FALSE, capturePlots = capturePlots))
      }
      updates
    },
    data_frame = function() {
      reformat_nulls <- function(x) lapply(x, function(y) ifelse(is.null(y), "", y))
      bind_rows(lapply(lapply(self$cells, "[", c("id", "value", "position", "hasImage", "viewWidth", "viewHeight")), reformat_nulls)) %>%
        arrange(position)
    },
    get_graph = function() {
      return(private$graph)
    },
    print = function() {
      cat(paste0("Reactor notebook with ", length(self$cells), " cell", ifelse(length(self$cells) == 1, "", "s"), "\n"), sep = "")
      for(cell in self$cells) {
        cat(cell$value, "\n", sep = "")
      }
    },
    save = function(file, rds = FALSE) {
      if(rds == TRUE) {
        contents_to_save <- list(
          graph = private$graph,
          cells = self$cells,
          name_to_id = private$name_to_id,
          static_dir = self$static_dir
        ) 
        
        saveRDS(contents_to_save, file)
      }
      else {
        topo <- topo_sort(private$graph, mode = "in")
        chunks <- lapply(self$cells[topo], private$cell_to_chunk)
        header <- glue::glue("
        ```{{r setup, include=FALSE}}
        # This is a [Reactor](https://github.com/herbps10/reactor) notebook. Here's how to run this notebook in Reactor: \n
        # ```
        # library(reactor)
        # 
        # notebook <- ReactorNotebook$load('{basename(file)}')
        # start_reactor(notebook)
        # ```
        
        library(reactor)
        ```
        
        
        ")
        
        footer <- "\n"
        
        txt <- str_c(header, str_c(unlist(chunks), collapse = "\n\n"), footer)
        
        cat(txt, file = file)
      }
    },
    load_ = function(file) {
      # Backwards compatibility
      # Handle RDS files
      if(tolower(tools::file_ext(file)) == "rds") {
        contents <- readRDS(file)
        
        private$graph <- contents$graph
        self$cells <- contents$cells
        private$name_to_id <- contents$name_to_id
        self$static_dir <- contents$static_dir
        if(!file.exists(self$static_dir)) self$static_dir <- tempdir()
        
        self$run_all()
      }
      else {
        knit_code$restore()
        md_pattern <- all_patterns[["md"]]
        knit_patterns$set(md_pattern)
        
        lines <- readLines(file)
        knitr:::split_file(lines)
        
        chunks <- knitr:::knit_code$get()
        
        cells <- lapply(chunks, private$chunk_to_cell)
        
        cells <- Filter(function(cell) cell$id != "setup", cells)
        
        lapply(cells, self$run_cell, update = FALSE)
        
      }
    },
    export = function() {
      topo <- topo_sort(private$graph, mode = "in")
      res <- stringr::str_c(lapply(self$cells[topo], `[[`, "value"), collapse = "\n\n")
      
      res
    },
    export_shiny = function() {
      
    }
  ),
  private = list(
    env = NULL,
    callstack = c(),
    name_to_id = c(),
    graph = graph.empty(directed = TRUE),
    wrap = function(name) {
      paste0(name, " %<a-% {
          private$callstack <- c(private$callstack, '", name, "')
          get('", name, "_saved', private$env)
        }
      ")
    },
    position_from_rank = function() {
      cell_ranks <- rank(unlist(lapply(self$cells, '[', 'position')))
      
      i <- 1
      for(id in names(self$cells)) {
        self$cells[[id]]$position <- unname(cell_ranks[i])
        i <- i + 1
      }
      cell_ranks
    },
    cell_to_chunk = function(cell) {
      props <- list(
        position = cell$position,
        open = cell$open,
        hasImage = cell$hasImage,
        viewWidth = cell$viewWidth,
        viewHeight = cell$viewHeight,
        echo = TRUE
      )
      if("md" %in% class(cell$result)) {
        props$results <- "'asis'"
        props$echo <- FALSE
      }
      private$make_chunk(cell$id, cell$value, props)
    },
    make_chunk = function(id, value, props) {
      props <- props[!unlist(map(props, is.null))]
      prop_string <- str_c(names(props), "=", props, collapse = ", ")
      glue("```{{r {id}, {prop_string}}}\n{value}\n```")
    },
    chunk_to_cell = function(chunk) {
      attr(chunk, "chunk_opts")$label <- str_replace(attr(chunk, "chunk_opts")$label, "^r ", "")
      c(list(
        id = attr(chunk, "chunk_opts")$label,
        value = str_c(as.vector(chunk), collapse = "\n")
      ), attributes(chunk)$chunk_opts)
    }
  )
)

# Static method
ReactorNotebook$load <- function(file) {
  notebook <- ReactorNotebook$new()
  notebook$load_(file)
  notebook
}