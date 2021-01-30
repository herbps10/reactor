#' List Reactor notebook examples
#' 
#' @export
reactor_example_list <- function() {
  dir(system.file("examples", package = "reactor"))
}

#' Load a Reactor example notebook
#' 
#' @param name example notebook filename
#' 
#' @seealso reactor_example_list
#' 
#' @export
reactor_example <- function(name) {
  if(!(name %in% reactor_example_list())) {
    stop("Example not found.")
  }
  
  ReactorNotebook$load(system.file("examples", name, package = "reactor"))
}