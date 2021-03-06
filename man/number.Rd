% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helpers.R
\name{number}
\alias{number}
\title{Generate an HTML number input}
\usage{
number(min = 0, max = 100, step = 1, value = mean(c(min, max)), title = "")
}
\arguments{
\item{min}{minimum}

\item{max}{maximum}

\item{step}{increment}

\item{value}{starting value}

\item{title}{title of input}
}
\description{
Generate an HTML number input
}
\examples{
# Run this in a cell to display a number input
input <- number(min = 1, max = 10, step = 1, value = 5, title = "Your title")

# In another cell, retrieve the value of the number input:
as.numeric(input)

}
