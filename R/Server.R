options(max.print = 10)

# Format a cell ready for conversion to JSON
# 
format_cell <- function(cell) {
  if(any(class(cell$result) %in% c("md", "html", "latex"))) {
    res <- paste0(unclass(cell$result), collapse = "\n")
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
#' Starts a Reactor server
#' 
#' @param notebook ReactorNotebook to view in the web-based notebook editor
#' 
#' @importFrom httpuv startServer staticPathOptions
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom utils help
#' @importFrom readr read_file
#' 
#' @examples 
#' \dontrun{
#' library(ReactorNotebook)
#' notebook <- ReactorNotebook$new()
#' 
#' server <- start_reactor(notebook)
#' 
#' stop_reactor(server)
#' }
#' 
#' @export
#'
start_reactor <- function(notebook) {
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
        else if(req$PATH_INFO == "/docs") {
          query <- stringr::str_match(req$QUERY_STRING, "\\?query=(.+)")[,2]
          path <- stringr::str_c(stringr::str_replace(help(query), "help", "html"), ".html")
          
          if(file.exists(path)) {
            return(list(
              status = 200L,
              headers = list(
                'Content-Type' = 'text/html'
              ),
              body = read_file(path)
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
        # Send full notebook state to client
        if(length(notebook$cells) > 0) {
          ws$send(toJSON(list(cells = map(notebook$cells, format_cell)[order(unlist(lapply(notebook$cells, "[", "position")), decreasing = FALSE)])))
        }
        else {
          ws$send(toJSON(list(cells = c())))
        }
        
        ws$onMessage(function(binary, contents) {
          payload = fromJSON(contents)
          result <- NULL
          
          #
          # Handle message types
          #
          
          # Update cell contents
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
              result <- map(changeset, function(id) format_cell(notebook$cells[[id]]))
            }
            else {
              result <- list(id = cell$id, error = toString(changeset))
            }
          }
          # Delete cell
          else if(payload$type == "delete") {
            cell <- payload$cell
            
            notebook$delete_cell(cell)
          }
          # Move cell
          else if(payload$type == "move") {
            notebook$move(payload$source, payload$destination)
          }
          # Update cell value based on HTML view
          else if(payload$type == "update_from_view") {
            changeset <- notebook$update_from_view(payload$cell, payload$value)
            
            if(!("error" %in% class(changeset))) {
              result <- map(changeset, function(id) format_cell(notebook$cells[[id]]))
            }
            else {
              result <- list(id = cell$id, error = toString(changeset))
            }
          }
          # Update open/closed cell state
          else if(payload$type == "update_open") {
            if(!is.null(notebook$cells[[payload$cell$id]])) {
              notebook$update_open(payload$cell, payload$value)
            }
          }
          # Update output size of cell
          else if(payload$type == "update_size") {
            notebook$update_size(payload$cell, payload$value)
          }
          
          if(!is.null(result)) {
            ws$send(toJSON(result))
          }
        })
      },
      staticPaths = list(
        "/output" = notebook$static_dir,
        "/" = system.file("frontend", package = "reactor")
      ),
      staticPathOptions = staticPathOptions(fallthrough = TRUE)
    )
  )
  
  utils::browseURL("http://localhost:5000")
  
  return(server)
}

#'
#' Stops a Reactor server
#' 
#' @param server ReactiveNotebook server
#' 
#' @importFrom httpuv stopServer
#' 
#' @examples 
#' \dontrun{
#' library(ReactorNotebook)
#' notebook <- ReactorNotebook$new()
#' 
#' server <- start_reactor(notebook)
#' 
#' stop_reactor(server)
#' }
#' 
#' @export
#' 
stop_reactor <- function(server) {
  stopServer(server)
}
