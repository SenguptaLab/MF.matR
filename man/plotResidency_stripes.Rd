% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotResidency_stripes.R
\name{plotResidency_stripes}
\alias{plotResidency_stripes}
\title{plotResidency_stripes}
\usage{
plotResidency_stripes(
  FileFilter,
  folderPath,
  arena_size = 16.1,
  frame_rate = 2,
  vid.length = 20,
  y_bins = 50,
  y_max = 5,
  heatmap_limits,
  heatmap_palette = "Greys",
  plot.direction = 1,
  time_bins = 1,
  ...
)
}
\arguments{
\item{FileFilter}{string to search/subset filenames}
}
\description{
Plots residency data by inside, outside stripe. Generates a heatmap by experiment
}
\examples{
data <- plotResidency_stripes()

}
