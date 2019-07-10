library(httpuv)
library(jsonlite)

staticDir = tempdir()
source("ReactiveNotebook.R")

options(max.print = 10)

notebook <- ReactiveNotebook$new()

formatCell <- function(cell) {
  if(class(cell$result) %in% c("md", "html", "latex")) {
    res <- paste0(cell$result, collapse = "\n")
  }
  else if(class(cell$result) == "matrix") {
    res <- cell$result
  }
  else if(class(cell) == "view") {
    res <- paste0(attr(cell$result, "view"), collapse = "\n")
  }
  else {
    res <- paste0(capture.output(cell$result), collapse = "\n")
  }
  
  list(
    id = cell$id,
    result = res,
    value = cell$value,
    RClass = class(cell$result),
    name = cell$name,
    #hasImage = FALSE
    hasImage = cell$hasImage
  )
}

server <- startServer(
  host = "0.0.0.0",
  port = 5000,
  app = list(
    onWSOpen = function(ws) {
      ws$send(toJSON(list(cells = map(notebook$cells, formatCell))))
      
      ws$onMessage(function(binary, contents) {
        payload = fromJSON(contents)
        result <- NULL
        
        if(payload$type == "update") {
          cell <- payload$cell
          changeset <- tryCatch({
            notebook$run_cell(cell)
          }, error = function(e) {
            e
          })
          
          #if(is.null(value)) value <- ""
          #result <- list(id = cell$id, result = paste0(capture.output(value), collapse = "\n"), hasImage = hasImage)
          
          if(!("error" %in% class(changeset))) {
            result <- map(changeset, function(id) formatCell(notebook$cells[[id]]))
          }
          else {
            result <- list(id = cell$id, error = toString(changeset))
          }
        }
        else if(payload$type == "delete") {
          cell <- payload$cell
          
          notebook$delete_cell(cell)
        }
        
        if(!is.null(result)) {
          ws$send(toJSON(result))
        }
      })
    },
    staticPaths = list(
      "/static" = staticDir
    )
  )
)

stopServer(server)
