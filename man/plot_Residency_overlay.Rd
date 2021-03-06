% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_Residency_overlay.R
\name{plot_Residency_overlay}
\alias{plot_Residency_overlay}
\title{Plot residency from Wormlab dauer data by space and time, overlaying density by time_bin}
\usage{
plot_Residency_overlay(df, time_bin, y_bin, nopause)
}
\arguments{
\item{df}{data frame}

\item{time_bin}{number of bins to split plot}

\item{y_bin}{number of position bins}
}
\description{
Plot residency from Wormlab dauer data by space and time, overlaying density by time_bin
}
\examples{
plot_Residency(time_bin = 4, y_bin = 100, nopause = TRUE)
}
