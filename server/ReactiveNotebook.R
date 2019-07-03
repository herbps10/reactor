library(R6)
library(igraph)
library(tidyverse)
library(pryr)

staticDir = tempdir()

ReactiveNotebook <- R6Class("ReactiveNotebook",
  public = list(
    cells = list(),
    initialize = function() {
      private$env <- new.env()
    },
    run_in_env = function(code) {
      eval(parse(text = code), private$env)
    },
    run_cell = function(cell) {
      private$callstack = c()
      
      # Capture plots
      while(dev.cur() > 1) dev.off()
      
      ggplot2:::.store$set(NULL)
      
      svgPath <- paste0(staticDir, "\\", cell$id, ".svg")
      svg(filename = svgPath)
      dev.control(displaylist = "enable")
      #eval(parse(text = paste0("svg('", str_replace_all(svgPath, "\\\\", "/"), "')")), private$env)
      #eval(parse(text = 'dev.control(displaylist = "enable")'), private$env)
      
      name <- NULL
      if(str_detect(cell$value, "^.+ <-")) {
        name <- str_match(cell$value, "^(.+?) ?<-")[,2]
        modified_cell <- str_replace(cell$value, paste0("^", name), paste0(name, "_saved"))
        eval(parse(text = private$wrap(name)), private$env)
        res <- eval(parse(text = modified_cell), private$env)
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
      
      self$cells[[cell$id]] = list(id = cell$id, value = cell$value, hasImage = hasImage);
      
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
      
      # Get dependencies
      ego_graph <- make_ego_graph(self$getGraph(), order = 1, nodes = cell$id, mindist = 0, mode = "in")[[1]]
      
      # Sort dependencies to topological order
      dependencies <- names(topo_sort(ego_graph, mode = "in")[-1])
      
      if(is.null(res)) res <- ""
      
      updates = list()
      updates[[cell$id]] <- res
      
      for(dependency in dependencies) {
        updates <- c(updates, self$run_cell(self$cells[[dependency]]))
      }
      
      updates
    },
    data_frame = function() {
      bind_rows(self$cells)
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

error <- NULL
result <- tryCatch({
  nb$run_cell(list(id = "a", value = "a"))
}, error = function(e) {
  e
})

nb$run_cell(list(id = "a", value = "df <- data.frame(x = 1:10, y = 1:10)"))
nb$run_cell(list(id = "b", value = "ggplot(df, aes(x, y)) + geom_point()"))
nb$run_cell(list(id = "d", value = "plot(df$x, df$y)"))

nb$data_frame()

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
