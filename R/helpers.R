#' Mark text to be displayed as markdown
#'
#' @param text text to display as markdown
#' @export
md <- function(text) {
  class(text) <- "md"
  text
}

#' Mark text to be displayed as markdown
#'
#' @param text text to display as latex
#' @export
latex <- function(text) {
  class(text) <- "latex"
  text
}

#' Mark text to be displayed as html
#'
#' @param text text to display as html
#' @export
html <- function(text) {
  class(text) <- "html"
  text
}

#' Generate an HTML slider to use as input
#'
#' @param min minimum
#' @param max maximum
#' @param step increment
#' @param value starting value
#' @param title title of slider to display
#' 
#' @export
#' 
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