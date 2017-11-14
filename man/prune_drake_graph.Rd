% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/graph.R
\name{prune_drake_graph}
\alias{prune_drake_graph}
\title{Function prune_drake_graph}
\usage{
prune_drake_graph(graph, to = igraph::V(graph)$name, jobs = 1)
}
\arguments{
\item{graph}{An igraph object to be pruned.}

\item{to}{Character vector, names of the vertices that draw
the line for pruning. The pruning process removes all vertices
downstream of \code{to}.}

\item{jobs}{Number of jobs for light parallelism (on non-Windows machines).}
}
\value{
A pruned igraph object representing the dependency network
of the workflow.
}
\description{
Prune an igraph object. Igraph objects are used
internally to represent the dependency network of your workflow.
See \code{\link{config}(my_plan)$graph} from the basic example.
}
\details{
For a supplied graph, take the subgraph of all combined
incoming paths to the vertices in \code{to}. In other words,
remove the vertices after \code{to} from the graph.
}
\examples{
\dontrun{
load_basic_example() # Load the canonical example.
# Build the igraph object representing the workflow dependency network.
# You could also use drake_config(my_plan)$graph
graph <- build_drake_graph(my_plan)
# The default plotting is not the greatest,
# but you will get the idea.
plot(graph)
# Prune the graph: that is, remove the nodes downstream
# from 'small' and 'large'
pruned <- prune_drake_graph(graph = graph, to = c("small", "large"))
plot(pruned)
}
}
\seealso{
\code{\link{build_drake_graph}}, \code{\link{config}},
\code{\link{make}}
}