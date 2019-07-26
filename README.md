# ReactiveNotebook
_Reactive notebooks for R_

**This is experimental software**

Reactive notebooks are collections of cells containing R code. When you update a cell, all of the cells that reference it are automatically updated, like a spreadsheet. ReactiveNotebooks integrate R code, plots, HTML, and text into one document.

```r
devtools::install_github("herbps10/ReactiveNotebook")

library(ReactiveNotebook)

# Create new ReactiveNotebook
notebook <- ReactiveNotebook$new()

# Launch server at http://localhost:5000
server <- launch_reactive_notebook(notebook)

# Bring down server
stop_reactive_notebook(server)

```

## Features

### Reactive execution
If a cell is used to define a variable, ReactiveNotebook keeps track of all the other cells that depend on it. If you update the variable, all the dependent cells are rerun.

<img src="https://thumbs.gfycat.com/HarmoniousGroundedEquestrian-size_restricted.gif" width="100%" alt="Example of reactive execution" style='box-shadow: 0px 0px 20px rgba(0, 0, 0, 0.2)' />

### Interactivity
Interactive inputs can be used to set the value of an R variable.

<img src="https://thumbs.gfycat.com/ScientificConcernedInvisiblerail-size_restricted.gif" width="100%" alt="Example of reactive execution" style='box-shadow: 0px 0px 20px rgba(0, 0, 0, 0.2)' />


### Widgets
Any R variable with the class "htmlwidget" will be rendered as HTML. 

## Comparison to existing tools

ReactiveNotebook is inspired by [Observable](http://observablehq.com), which provides a similar notebook interface for Javascript. I've been very happy with the Observable workflow, and wanted to be able to use a similar interface with R so I could access more heavy duty statistical tools. In R, the package [Shiny](https://shiny.rstudio.com) is similar, in that it supports reactive execution for R, but it doesn't currently provide the ability to author code (a new package, [shinymeta](https://rstudio.github.io/shinymeta), does allow for exporting R code that Shiny generated reactively.) [Jupyter](https://jupyter.com) notebooks are a very popular notebook interface for various backend languages, but it generally does not enforce any execution order for its cells. The [dfkernel](https://github.com/dataflownb/dfkernel/) project extends Jupyter notebooks for Python to enable a reactive execution flow. 

|                                      | Language   | Authoring | Reactive |
|--------------------------------------|------------|-----------|----------|
| ReactiveNotebook                     | R          | ✔         | ✔        |
| [Shiny](https://shiny.rstudio.com/)   | R          |           | ✔        |
| [Observable](https://observablehq.com)| Javascript | ✔         | ✔        |
| [Jupyter](https://jupyter.com)               | Various    | ✔         | For Python with [dfkernel](https://github.com/dataflownb/dfkernel/)        |
| Spreadsheets                         | Various    | ✔          | ✔ |

## Todo list

- [x] export to R script 
- [ ] export to HTML
- HTML inputs:
  - [x] range/slider
  - [ ] checkbox
  - [ ] radiobox
  - [ ] text
  - [ ] textarea