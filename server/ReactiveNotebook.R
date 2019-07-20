library(R6)
library(igraph)
library(tidyverse)
library(pryr)


md <- function(text) {
  class(text) <- "md"
  text
}

latex <- function(text) {
  class(text) <- "latex"
  text
}

html <- function(text) {
  class(text) <- "html"
  text
}

slider <- function(min = 0, max = 100, step = 1, value = mean(c(min, max)), title = "") {
  view <- 1
  class(view) <- "view"
  attr(view, 'view') <- glue::glue("
  <div>
    <strong><<title>></strong>
    <input type='range'
      min=<<min>>
      max=<<max>>
      step=<<step>>
      value=<<value>>
      oninput='this.nextElementSibling.innerHTML = this.value'
      onchange='window.range = this; var event = new CustomEvent(\"update-cell\", { bubbles: true, detail: this.value }); this.dispatchEvent(event);'
      />
    <span><<value>></span>
  </div>", .open = "<<", .close = ">>")
  view
}

ReactiveNotebook <- R6Class("ReactiveNotebook",
                            git
  public = list(
    cells = list(),
    initialize = function() {
      private$env <- new.env()
    },
    run_in_env = function(code) {
      eval(parse(text = code), private$env)
    },
    move = function(source, destination) {
      self$cells <- map(self$cells, function(cell) {
        if(cell$position == source) cell$position <- destination
        cell
      })
      
      cell_ranks <- rank(unlist(lapply(self$cells, '[', 'position')))
      
      i <- 1
      for(id in names(self$cells)) {
        self$cells[[id]]$position <- cell_ranks[i]
        i <- i + 1
      }
      cell_ranks
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
        private$graph <- delete.vertices(private$graph, V(private$graph)[[cell$id]])
      }
    },
    run_cell = function(cell, update = TRUE) {
      private$callstack = c()
      
      # Capture plots
      while(dev.cur() > 1) dev.off()
      
      ggplot2:::.store$set(NULL)
      
      svgPath <- paste0(file.path(staticDir, cell$id), ".svg")
      svg(filename = svgPath)
      dev.control(displaylist = "enable")
      #eval(parse(text = paste0("svg('", str_replace_all(svgPath, "\\\\", "/"), "')")), private$env)
      #eval(parse(text = 'dev.control(displaylist = "enable")'), private$env)
      
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
      
      #p <- eval(parse(text = "recordPlot()"), private$env)
      p <- recordPlot()
      p2 <- last_plot()
      dev.off()
      if(!is.null(p2)) {
        ggsave(svgPath)
      }
      hasImage = !is.null(p[[1]]) || !is.null(p2)
      
      pos <- cell$position
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
      
      self$cells[[cell$id]] = list(
        id = cell$id,
        value = cell$value,
        position = pos,
        hasImage = hasImage,
        name = name,
        result = res
      );
      
      
      if(!is.null(name)) {
        private$name_to_id[name] = cell$id
      }
      
      if(!(cell$id %in% names(V(private$graph)))) {
        private$graph <- add_vertices(private$graph, 1, name = cell$id)
      }
      
      for(call in private$callstack) {
        call_id <- private$name_to_id[call]
        if(!are.connected(private$graph, cell$id, call_id)) {
          private$graph <- add_edges(private$graph, c(cell$id, call_id))
        }
      }
      
      if(is.null(res)) res <- ""
      updates = c(cell$id)
      
      if(update == TRUE) {
        updates <- c(updates, self$propogate_updates(cell))
      }
      
      updates
    },
    viewUpdate = function(cell, value) {
      self$run_in_env(str_c(cell$name, "_saved[1] = ", value))
      
      updates <- self$propogate_updates(cell)
      updates
    },
    propogate_updates = function(cell) {
      # Get dependencies
      updates <- c()
      ego_graph <- make_ego_graph(self$getGraph(), order = 1000, nodes = cell$id, mindist = 0, mode = "in")[[1]]
      
      # Sort dependencies to topological order
      dependencies <- names(topo_sort(ego_graph, mode = "in")[-1])
      
      for(dependency in dependencies) {
        updates <- c(updates, self$run_cell(self$cells[[dependency]], update = FALSE))
      }
      updates
    },
    data_frame = function() {
      bind_rows(lapply(self$cells, "[", c("id", "value", "position", "hasImage"))) %>%
        arrange(position)
    },
    getGraph = function() {
      return(private$graph)
    },
    print = function() {
      for(cell in self$cells) {
        cat(cell, "\n", sep = "")
      }
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
    }
  )
)

nb <- ReactiveNotebook$new()
nb$run_cell(list(id = "start", value = "start <- slider()", position = 1))
nb$run_cell(list(id = "x", value = "y <- as.numeric(start)", position = 2))

nb$data_frame()
nb$run_in_env("y")

nb$viewUpdate(list(id = "start", name = "start"), 3)

nb$move(2, 0.5)

nb$data_frame()
#
#nb$delete_cell(list(id = "y"))
#nb$data_frame()
#nb$run_cell(list(id = "y2", value = "y2 <- cos(x)"))
#nb$run_cell(list(id = "plot", value = "{
#  plot(x, y, type = 'l')
#  plot(x, y2, col = 'green')
#}"))
#
#nb$run_cell(list(id = "start", value = "start <- 5"))
#
#nb$run_in_env("length(y)")
#nb$run_in_env("length(y2)")
#
#
#plot(nb$getGraph())
#
#nb <- ReactiveNotebook$new()
#
#nb$run_cell(list(id = "a", value = "df <- data.frame(x = 1:10, y = 1:10)"))
#nb$run_cell(list(id = "b", value = "ggplot(df, aes(x, y)) + geom_point()"))
#nb$run_cell(list(id = "d", value = "plot(df$x, df$y)"))
#
#nb$data_frame()

#notebook <- ReactiveNotebook$new()
#
#notebook$run_cell(list(id = "a", value = "a <- 10"))
#notebook$run_cell(list(id = "b", value = "b <- a"))
#notebook$run_cell(list(id = "c1", value = "a"))
#
#notebook$run_cell(list(id = "c2", value = "plot(1:10)"))
#notebook$data_frame()
#
#notebook$run_cell(list(id = "a", value = "a <- 15"))
#
#notebook$run_cell("b <- a")
#
#notebook$run_cell("a <- 15")
#
#notebook$run_cell("d <- a")
#notebook$run_cell("e <- d")
#
#plot(notebook$getGraph())
#
#notebook$run_in_env("b")
#
#notebook$data_frame()
#
#node <- V(notebook$getGraph())[1]
#
#topo_sort(make_ego_graph(notebook$getGraph(), order = 10, nodes = "a", mindist = 0, mode = "in")[[1]], mode = "in")
