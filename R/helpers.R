# Format titles for inputs
make_title <- function(title) {
  ifelse(title == "", title, glue::glue("<strong>{title}</strong><br/>"))
}

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

#' Generate an HTML slider input
#'
#' @param min minimum
#' @param max maximum
#' @param step increment
#' @param value starting value
#' @param title title of input
#' 
#' @importFrom glue glue
#' 
#' @export
#' 
slider <- function(min = 0, max = 100, step = 1, value = mean(c(min, max)), title = "") {
  view <- value
  class(view) <- "view"
  attr(view, 'view') <- glue("
  <div>
    <<make_title(title)>>
    <input type='range'
      min=<<min>>
      max=<<max>>
      step=<<step>>
      value=<<value>>
      oninput='this.nextElementSibling.innerHTML = this.value'
      onchange='var event = new CustomEvent(\"update-cell\", { bubbles: true, detail: this.value }); this.dispatchEvent(event);'
      />
    <span><<value>></span>
  </div>", .open = "<<", .close = ">>")
  view
}

#' Generate an HTML number input
#'
#' @param min minimum
#' @param max maximum
#' @param step increment
#' @param value starting value
#' @param title title of input
#' 
#' @importFrom glue glue
#' 
#' @export
#' 
number <- function(min = 0, max = 100, step = 1, value = mean(c(min, max)), title = "") {
  view <- value
  class(view) <- "view"
  attr(view, 'view') <- glue("
  <div>
    <<make_title(title)>>
    <input type='number'
      min=<<min>>
      max=<<max>>
      step=<<step>>
      value=<<value>>
      onchange='var event = new CustomEvent(\"update-cell\", { bubbles: true, detail: this.value }); this.dispatchEvent(event);'
      />
  </div>", .open = "<<", .close = ">>")
  view
}


#' Generate an HTML checkbox input
#'
#' @param value initial value (TRUE or FALSE)
#' @param title title of input
#' 
#' @importFrom glue glue
#' 
#' @export
#' 
checkbox <- function(value = FALSE, title = "") {
  view <- value
  class(view) <- "view"
  checked <- ifelse(value, "checked", "")
  attr(view, 'view') <- glue("
  <div>
    <<make_title(title)>>
    <input type='checkbox'
      <<checked>>
      onchange='var event = new CustomEvent(\"update-cell\", { bubbles: true, detail: (this.checked == true ? \"TRUE\" : \"FALSE\") }); this.dispatchEvent(event);'
      />
  </div>", .open = "<<", .close = ">>")
  view
}


#' Generate an HTML text input
#'
#' @param value initial value
#' @param title title of input
#' 
#' @importFrom glue glue
#' 
#' @export
#' 
text <- function(value = "", title = "") {
  view <- value
  class(view) <- "view"
  
  attr(view, 'view') <- glue("
  <div>
    <<make_title(title)>>
    <input type=''
      value=\"<<value>>\"
      onchange='var event = new CustomEvent(\"update-cell\", { bubbles: true, detail: stringWrap(this.value) }); this.dispatchEvent(event);'
      />
  </div>", .open = "<<", .close = ">>")
  view
}

