#' Key-value lists used as arguments to cf functions
#'
#' @description
#' A set of incomplete but still useful key-value lists that map a query
#' parameter of interest to its underlying integer or string value used in
#' the actual request string. For example, the `Women` division has a query
#' parameter value of `2L`, but you can use `cf_division$Women` anywhere you
#' see a `division` argument.
#'
#' - `cf_scale`: The scale used in the workout. Includes `rx`, `scaled`, and
#' `foundations` scales.
#'
#' - `cf_competition`: The competition to retrieve data for. The two most
#' important are `open` and `games`.
#'
#' - `cf_region`: The region to filter down to. From what I can tell, using
#' `worldwide` as the region will pull in all the data, and then you can filter
#' from there. This is an incomplete set of data.
#'
#' - `cf_division`: The division to retrieve data for. Most relevant are `Men`
#' and `Women`, but you can also filter for an age group, like `Women (50-54)`.
#' This is an incomplete set of data.
#'
#' @name cf-data
#'
#' @examples
#' cf_scale
NULL

#' @rdname cf-data
#' @export
cf_scale <- list(
  rx = 0L,
  scaled = 1L,
  foundations = 2L
)

#' @rdname cf-data
#' @export
cf_competition <- list(
  open = "open",
  quarterfinals_individual = "quarterfinalsindividual",
  quarterfinals_team = "quarterfinalsteam",
  online_qualifiers = "onlinequalifiers",
  semifinals = "semifinals",
  regionals = "regionals",
  games = "games"
)

#' @rdname cf-data
#' @export
cf_region <- list(
  worldwide = 0L,
  asia = 28L,
  europe = 29L,
  africa = 30L,
  north_america = 31L,
  oceania = 32L,
  south_america = 33L
)

#' @rdname cf-data
#' @export
cf_division <- list(
  `Men` = 1L,
  `Women` = 2L,
  `Men (45-49)` = 3L,
  `Women (45-49)` = 4L,
  `Men (50-54)` = 5L,
  `Women (50-54)` = 6L,
  `Men (55-59)` = 7L,
  `Women (55-59)` = 8L,
  `Men (40-44)` = 12L,
  `Women (40-44)` = 13L,
  `Boys (14-15)` = 14L,
  `Girls (14-15)` = 15L,
  `Boys (16-17)` = 16L,
  `Girls (16-17)` = 17L,
  `Men (35-39)` = 18L,
  `Women (35-39)` = 19L,
  `Men Upper Extremity` = 20L,
  `Women Upper Extremity` = 21L,
  `Men Lower Extremity` = 22L,
  `Women Lower Extremity` = 23L,
  `Men Neuromuscular` = 24L,
  `Women Neuromuscular` = 25L,
  `Men Vision` = 26L,
  `Women Vision` = 27L,
  `Men Short Stature` = 28L,
  `Women Short Stature` = 29L,
  `Men Seated (w/ hip)` = 30L,
  `Women Seated (w/ hip)` = 31L,
  `Men Seated (w/o hip)` = 32L,
  `Women Seated (w/o hip)` = 33L,
  `Men Intellectual` = 34L,
  `Women Intellectual` = 35L,
  `Men (60-64)` = 36L,
  `Women (60-64)` = 37L,
  `Men (65+)` = 38L,
  `Women (65+)` = 39L
)
