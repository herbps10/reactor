# Reactor
_Reactive notebooks for R_

<!-- badges: start -->
  [![Travis build status](https://travis-ci.org/herbps10/Reactor.svg?branch=master)](https://travis-ci.org/herbps10/Reactor)
<!-- badges: end -->

**This is experimental software**. That means there are bugs, and the API is liable to change without maintaining backwards compatibility. Use at your own risk.

## What is it?
Reactor notebooks are collections of cells containing R code. When you update a cell, all of the cells that reference it are automatically updated, like how a spreadsheet works. Reactor notebooks integrate R code, plots, HTML, and markdown into one document.

Reactor notebooks are useful for prototyping code and exploring subjects through interactive visualizations.

<img src='https://i.imgur.com/BNeLEPW.png' width='75%' />

## Getting started
```r
devtools::install_github("herbps10/Reactor")

library(Reactor)

# Create new Reactor notebook
notebook <- ReactorNotebook$new()

# Launch server at http://localhost:5000
server <- start_reactor(notebook)

# Bring down server
stop_reactor(server)

```

## Features

### Reactive execution
If a cell is used to define a variable, Reactor keeps track of all the other cells that depend on it. If you update the variable, all the dependent cells are rerun.

<img src="https://thumbs.gfycat.com/HarmoniousGroundedEquestrian-size_restricted.gif" width="100%" alt="Example of reactive execution" />

### Interactivity
Interactive inputs can be used to set the value of an R variable.

<img src="https://thumbs.gfycat.com/SickCircularLeonberger-size_restricted.gif" width="100%" alt="Example of interactive inputs" />

## Plotting
Reactor supports base plots and ggplot2.

<img src="https://thumbs.gfycat.com/ParchedMedicalAardvark-size_restricted.gif" width="100%" alt="Example of interactive HTML widgets" />

### Widgets
Any R variable with the class "htmlwidget" will be rendered as HTML. 

<img src="https://thumbs.gfycat.com/GrizzledSlowLacewing-size_restricted.gif" width="100%" alt="Example of interactive HTML widgets" />

## Comparison to existing tools

Reactor is inspired by [Observable](http://observablehq.com), which provides a similar notebook interface for Javascript. I've been very happy with the Observable workflow, and wanted to be able to use a similar interface with R so I could access more heavy duty statistical tools. In R, the package [Shiny](https://shiny.rstudio.com) is similar, in that it supports reactive execution for R, but it doesn't currently provide the ability to author code (a new package, [shinymeta](https://rstudio.github.io/shinymeta), does allow for exporting R code that Shiny generated reactively.) [Jupyter](https://jupyter.com) notebooks are a very popular notebook interface for various backend languages, but it generally does not enforce any execution order for its cells. The [dfkernel](https://github.com/dataflownb/dfkernel/) project extends Jupyter notebooks for Python to enable a reactive execution flow. 

|                                      | Language   | Authoring | Reactive |
|--------------------------------------|------------|-----------|----------|
| Reactor                              | R          | ✔         | ✔        |
| [Shiny](https://shiny.rstudio.com/)   | R          |           | ✔        |
| [Observable](https://observablehq.com)| Javascript | ✔         | ✔        |
| [Jupyter](https://jupyter.com)               | Various    | ✔         | For Python with [dfkernel](https://github.com/dataflownb/dfkernel/)        |
| Spreadsheets                         | Various    | ✔          | ✔ |

## Todo list

- [x] export to R script 
- [ ] export to HTML
- HTML inputs:
  - [x] range/slider
  - [x] number
  - [x] checkbox
  - [ ] radiobox
  - [x] text
  - [ ] textarea
  
