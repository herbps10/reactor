library(httpuv)
library(jsonlite)

staticDir <- tempdir()

source("ReactiveNotebook.R")

options(max.print = 100)

notebook <- ReactiveNotebook$new()

server <- startServer(
  host = "0.0.0.0",
  port = 5000,
  app = list(
    onWSOpen = function(ws) {
      ws$onMessage(function(binary, contents) {
        cell = fromJSON(contents)
        
        changeset <- tryCatch({
          notebook$run_cell(cell)
        }, error = function(e) {
          e
        })
        
        #if(is.null(value)) value <- ""
        #result <- list(id = cell$id, result = paste0(capture.output(value), collapse = "\n"), hasImage = hasImage)
        
        if(!("error" %in% class(changeset))) {
          result <- map(names(changeset), function(x) {
            list(
              id = x,
              result = paste0(capture.output(changeset[[x]]), collapse = "\n"),
              RClass = class(changeset[[x]]),
              #hasImage = FALSE
              hasImage = notebook$cells[[x]]$hasImage
            )
          })
        }
        else {
          result <- list(id = cell$id, error = toString(changeset))
        }
        
        ws$send(toJSON(result))
      })
    },
    staticPaths = list(
      "/static" = staticDir
    )
  )
)

stopServer(server)
