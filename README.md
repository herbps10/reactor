# ReactiveNotebook
Reactive notebooks for R

Reactive notebooks are collections of cells containing R code. When you update a cell, all of the cells that reference it are automatically updated, like a spreadsheet.

ReactiveNotebook is inspired by [Observable](http://observablehq.com), which provides a similar notebook interface for Javascript.


|                                      | Language   | Authoring | Reactive |
|--------------------------------------|------------|-----------|----------|
| ReactiveNotebook                     | R          | ✔         | ✔        |
| [Shiny](http://shiny.rstudio.com/)   | R          |           | ✔        |
| [Observable](http://observablehq.com)| Javascript | ✔         | ✔        |
| [Jupyter](jupyter.com)               | Various    | ✔         | For Python with [dfkernel](https://github.com/dataflownb/dfkernel/)        |

## Todo list

HTML Inputs

- [x] range/slider
- [ ] checkbox
- [ ] radiobox
- [ ] text
- [ ] textarea