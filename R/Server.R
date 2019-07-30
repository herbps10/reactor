options(max.print = 10)

# Format a cell ready for conversion to JSON
# 
formatCell <- function(cell) {
  if(any(class(cell$result) %in% c("md", "html", "latex"))) {
    res <- paste0(cell$result, collapse = "\n")
  }
  else if(class(cell$result) == "matrix") {
    res <- cell$result
  }
  else if(class(cell$result) == "view") {
    res <- paste0(attr(cell$result, "view"), collapse = "\n")
  }
  else {
    res <- paste0(utils::capture.output(cell$result), collapse = "\n")
  }
  
  list(
    id = cell$id,
    result = res,
    value = cell$value,
    RClass = class(cell$result),
    name = cell$name,
    position = cell$position,
    #hasImage = FALSE
    hasImage = cell$hasImage,
    viewWidth = cell$viewWidth,
    viewHeight = cell$viewHeight,
    open = cell$open
  )
}

#'
#' Launches a ReactiveNotebook server
#' 
#' @param notebook ReactiveNotebook to view in the web-based notebook editor
#' 
#' @importFrom httpuv startServer staticPathOptions
#' @importFrom jsonlite fromJSON toJSON
#' 
#' @examples 
#' \dontrun{
#' library(ReactiveNotebook)
#' notebook <- ReactiveNotebook$new()
#' 
#' server <- launch_reactive_notebook(notebook)
#' 
#' stop_reactive_notebook(server)
#' }
#' 
#' @export
#'
launch_reactive_notebook <- function(notebook) {
  server <- startServer(
    host = "0.0.0.0",
    port = 5000,
    app = list(
      call = function(req) {
        if(req$PATH_INFO == "/export") {
            return(list(
              status = 200L,
              headers = list(
                'Content-Type' = 'text/plain'
              ),
              body = notebook$export()
            ))
          }
        else {
          return(list(
            status = 404L,
            headers = list(
              'Content-Type' = 'text/html'
            ),
            body = "Not found"
          ))
        }
      },
      onWSOpen = function(ws) {
        if(length(notebook$cells) > 0) {
          ws$send(toJSON(list(cells = map(notebook$cells, formatCell)[order(unlist(lapply(notebook$cells, "[", "position")), decreasing = FALSE)])))
        }
        else {
          ws$send(toJSON(list(cells = c())))
        }
        
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
          else if(payload$type == "move") {
            notebook$move(payload$source, payload$destination)
          }
          else if(payload$type == "updateView") {
            changeset <- notebook$viewUpdate(payload$cell, payload$value)
            
            if(!("error" %in% class(changeset))) {
              result <- map(changeset, function(id) formatCell(notebook$cells[[id]]))
            }
            else {
              result <- list(id = cell$id, error = toString(changeset))
            }
          }
          else if(payload$type == "updateOpen") {
            if(!is.null(notebook$cells[[payload$cell$id]])) {
              notebook$updateOpen(payload$cell, payload$value)
            }
          }
          else if(payload$type == "updateSize") {
            notebook$updateSize(payload$cell, payload$value)
          }
          
          if(!is.null(result)) {
            ws$send(toJSON(result))
          }
        })
      },
      staticPaths = list(
        "/output" = notebook$staticDir,
        "/" = "inst/frontend"
      ),
      staticPathOptions = staticPathOptions(fallthrough = TRUE)
    )
  )
}

#'
#' Stops a ReactiveNotebook server
#' 
#' @param server ReactiveNotebook server
#' 
#' @importFrom httpuv stopServer
#' 
#' @examples 
#' \dontrun{
#' library(ReactiveNotebook)
#' notebook <- ReactiveNotebook$new()
#' 
#' server <- launch_reactive_notebook(notebook)
#' 
#' stop_reactive_notebook(server)
#' }
#' 
#' @export
#' 
stop_reactive_notebook <- function(server) {
  stopServer(server)
}
