% Generated by roxygen2 (4.0.2): do not edit by hand
\name{tronco.plot}
\alias{tronco.plot}
\title{plot a progression model}
\usage{
tronco.plot(topology, title = paste("Progression model", topology@algorithm,
  sep = " "), title.color = "black", confidence = FALSE, legend = TRUE,
  legend.title = "Legend", legend.columns = 1, legend.inline = FALSE,
  legend.pos = "bottomright", legend.coeff = 1, label.coeff = 1,
  label.color = "black", label.edge.size = 12)
}
\arguments{
\item{topology}{A topology returned by a reconstruction algorithm}

\item{title}{plot Plot title (default "Progression model x", x reconstruction algorithm)}

\item{title.color}{color title (default "black")}

\item{confidence}{bool; plot edges according to confidence (default is f)}

\item{legend}{bool; show/hide the legend (default is t)}

\item{legend.title}{string; legend title (default is "Legend")}

\item{legend.columns}{int; use 1 or 2 columns to plot the legend (default is 1)}

\item{legend.inline}{bool; print inline legend (default is f)}

\item{legend.pos}{string; legend positioning, available keywords "topleft", "topright",
"bottom- left" and "bottomright" (default is "bottomright")}

\item{legend.coeff}{double; size of the types label in the legend (default is 1)}

\item{label.coeff}{double; size of the events label (default is 1)}

\item{label.color}{color events label (default "black")}

\item{label.edge.size}{double; size of the confidence label, when used (default is 12)}
}
\description{
\code{tronco.plot} plots a progression model from a recostructed \code{topology}.
}
\examples{
\dontrun{
types.load("data/types.txt")
events.load("data/events.txt")
data.load("data/CGH.txt")
topology <- tronco.caprese(data.values)
tronco.plot(topology, legend.pos = "topleft", legend = TRUE, confidence = TRUE,
legend.col = 1, legend.coeff = 0.7, label.edge.size = 10, label.coeff = 0.7)
}
}

