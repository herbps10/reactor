% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/server.R
\name{start_reactor}
\alias{start_reactor}
\title{Starts a Reactor server}
\usage{
start_reactor(notebook)
}
\arguments{
\item{notebook}{ReactorNotebook to view in the web-based notebook editor}
}
\description{
Starts a Reactor server
}
\examples{
\dontrun{
library(ReactorNotebook)
notebook <- ReactorNotebook$new()

server <- start_reactor(notebook)

stop_reactor(server)
}

}
