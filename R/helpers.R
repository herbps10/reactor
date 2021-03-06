# Format titles for inputs
make_title <- function(title) {
  ifelse(title == "", title, glue::glue("<strong>{title}</strong><br/>"))
}

#' Mark text to be displayed as markdown
#'
#' @param text text to display as markdown
#' @export
md <- function(text) {
  class(text) <- c("md")
  text
}

#' Print md class
#' 
#' @param x markdown text
#' @param ... not used
#' @export
print.md <- function(x, ...) {
  attributes(x) <- NULL
  cat(x)
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
#' @examples 
#' # Run this in a cell to display a number input
#' input <- slider(min = 1, max = 10, step = 1, value = 5, title = "Your title")
#' 
#' # In another cell, retrieve the value of the slider input:
#' as.numeric(input)
#' 
#' @export
#' 
slider <- function(min = 0, max = 100, step = 1, value = mean(c(min, max)), title = "") {
  view <- value
  class(view) <- "view"
  attr(view, 'call') <- list(fun = match.call(), min = min, max = max, step = step, value = value, title = title)
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
#' @examples 
#' # Run this in a cell to display a number input
#' input <- number(min = 1, max = 10, step = 1, value = 5, title = "Your title")
#' 
#' # In another cell, retrieve the value of the number input:
#' as.numeric(input)
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
#' @examples 
#' # Run this in a cell to display a checkbox input
#' input <- checkbox(value = FALSE, title = "Your title")
#' 
#' # In another cell, retrieve the value of the checkbox:
#' as.logical(input)
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
#' @examples 
#' # Run this in a cell to display a text input
#' input <- text(value = "Default value", title = "Your title")
#' 
#' # In another cell, retrieve the value of the textbox:
#' as.character(input)
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

