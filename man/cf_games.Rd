% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/games.R
\name{cf_games}
\alias{cf_games}
\title{CrossFit Games}
\usage{
cf_games(
  year,
  ...,
  division = cf_division$Men,
  n_pages = NULL,
  progress = TRUE
)
}
\arguments{
\item{year}{The year to retrieve data for. Note that not all parameters
will be valid for past years.}

\item{...}{These dots are for future extensions and must be empty.}

\item{division}{The division to retrieve data for. One of the values in
\link{cf_division}.}

\item{n_pages}{An optional integer to limit the number of pages returned.
Each page will have a maximum of 100 rows returned. This is useful if you
just want to explore the data without downloading all of it. If not
specified, this will download all available data.}

\item{progress}{Should a progress bar be shown for longer downloads?}
}
\value{
A tibble.
}
\description{
\code{cf_games()} retrieves data from the CrossFit Games API, lightly
pre-processed. If you need low level access to the API, use \code{\link[=cf_request]{cf_request()}}.

If no data is returned by the API, an empty tibble with zero columns and zero
rows is returned.

You'll typically need to use \code{\link[tidyr:hoist]{tidyr::unnest_wider()}} and \code{\link[tidyr:hoist]{tidyr::hoist()}} to
further process this data.
}
\examples{
library(tidyr)
library(dplyr)

games <- cf_games(2021)

# 15 workouts in the 2021 CrossFit games
games \%>\%
  unnest_wider(entrant) \%>\%
  hoist(scores, two = 2) \%>\%
  select(competitorName, two) \%>\%
  unnest_wider(two) \%>\%
  select(competitorName, score, breakdown)

# What affiliates were the top 20 associated with?
# (This is also a way to find an affiliate ID)
games \%>\%
  unnest_wider(entrant) \%>\%
  slice(1:20) \%>\%
  select(competitorName, affiliateId, affiliateName)
}
