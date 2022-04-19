#' Low level requests to the CrossFit API
#'
#' @description
#' These are low level functions for constructing requests to the CrossFit API.
#' You can use them to build custom requests along with the [data
#' objects][cf-data] if the wrapped functions don't provide enough flexibility
#' or don't hit an endpoint you'd like to see. Be aware that certain endpoints
#' may lose support for query parameters as you go back in time. Additionally
#' different endpoints require different query parameters, but none of this
#' is documented on the CrossFit side.
#'
#' `cf_request()` creates the base request object for a particular
#' competition/year combination. Always start with this object.
#'
#' Then you can layer in additional query parameter modifiers:
#'
#' - `cf_req_division()`: Request a particular division. The set of divisions
#' can be seen with [cf_division].
#'
#' - `cf_req_region()`: Request a particular region. The set of regions can be
#' seen with [cf_region]. The easiest to use is `cf_region$worldwide`.
#'
#' - `cf_req_scale()`: Request a particular scale (Rx, Scaled, Foundations). The
#' set of scales can be seen with [cf_scale].
#'
#' - `cf_req_limit()`: Alter the number of returned rows. Default seems to be 50
#' if you don't set anything, and has a maximum value of 100.
#'
#' - `cf_req_affiliate()`: Request a particular affiliate's data. You'll have to
#' look up your affiliate's ID on the CrossFit website. It is generally in the
#' URL on your affiliate's webpage.
#'
#' - `cf_req_page()`: Alter the current page, i.e. for use with pagination. If
#' you process a response with `resp_body_json()` and look at `resp$pagination`,
#' then there is typically some information there about which page you are
#' currently on and how many pages of data are available.
#'
#' @param competition A competition. One of the values from [cf_competition].
#'
#' @param year A single integer of the year to retrieve data for.
#'
#' @param req A request object from `cf_request()` to modify.
#'
#' @param division A division. One of the values from [cf_division].
#'
#' @param region A region. One of the values from [cf_region].
#'
#' @param scale A workout scaling. One of the values from [cf_scale].
#'
#' @param limit The number of rows to return. A single integer between
#' `[0, 100]`.
#'
#' @param affiliate A single integer of the affiliate ID to return data for.
#'
#' @param page A single integer of the "current page" to retrieve data for.
#'
#' @return
#' A request object.
#'
#' @name cf-request
#'
#' @examples
#' library(tidyr)
#' library(tibble)
#' library(dplyr)
#'
#' # ---------------------------------------------------------------------------
#'
#' # Top two from the crossfit open 2022, Men's Rx
#' resp <- cf_request(cf_competition$open, 2022) %>%
#'   cf_req_division(cf_division$Men) %>%
#'   cf_req_region(cf_region$worldwide) %>%
#'   cf_req_scale(cf_scale$rx) %>%
#'   cf_req_limit(2L) %>%
#'   req_perform() %>%
#'   resp_body_json()
#'
#' # Some pagination information here!
#' resp$pagination
#'
#' leaderboard <- tibble(rows = resp$leaderboardRows)
#' leaderboard
#'
#' leaderboard %>%
#'   unnest_wider(rows)
#'
#' leaderboard %>%
#'   unnest_wider(rows) %>%
#'   unnest_wider(entrant)
#'
#' # 2022's 3 workouts
#' workouts <- leaderboard %>%
#'   unnest_wider(rows) %>%
#'   unnest_wider(entrant) %>%
#'   hoist(scores, one = 1, two = 2, three = 3)
#'
#' # Let's look at 22.1
#' workouts %>%
#'   select(competitorName, one) %>%
#'   unnest_wider(one) %>%
#'   select(competitorName, rank, score, scoreDisplay, breakdown)
#'
#' # ---------------------------------------------------------------------------
#'
#' # Top five from the crossfit games 2021 Women's division
#' resp <- cf_request(cf_competition$games, 2021) %>%
#'   cf_req_division(cf_division$Women) %>%
#'   cf_req_limit(5L) %>%
#'   req_perform() %>%
#'   resp_body_json()
#'
#' leaderboard <- tibble(rows = resp$leaderboardRows)
#' leaderboard
#'
#' # Toomey, of course
#' leaderboard %>%
#'   unnest_wider(rows) %>%
#'   unnest_wider(entrant)
#'
#' # There are actually 15 workouts here, let's just pick the first
#' workouts <- leaderboard %>%
#'   unnest_wider(rows) %>%
#'   unnest_wider(entrant) %>%
#'   hoist(scores, one = 1)
#'
#' workouts %>%
#'   select(competitorName, one) %>%
#'   unnest_wider(one) %>%
#'   select(competitorName, rank, score)
NULL

#' @rdname cf-request
#' @export
cf_request <- function(competition, year) {
  competition <- vec_cast(competition, to = character())
  vec_assert(competition, size = 1L)

  year <- vec_cast(year, to = integer())
  vec_assert(year, size = 1L)

  out <- request("https://c3po.crossfit.com/api/competitions/v2/competitions")
  out <- req_user_agent(out, string = "crossfit (https://github.com/DavisVaughan/crossfit)")

  out <- req_url_path_append(out, competition)
  out <- req_url_path_append(out, year)
  out <- req_url_path_append(out, "leaderboards")

  out
}

#' @rdname cf-request
#' @export
cf_req_division <- function(req, division) {
  division <- vec_cast(division, to = integer())
  vec_assert(division, size = 1L)

  req_url_query(req, division = division)
}

#' @rdname cf-request
#' @export
cf_req_region <- function(req, region) {
  region <- vec_cast(region, to = integer())
  vec_assert(region, size = 1L)

  req_url_query(req, region = region)
}

#' @rdname cf-request
#' @export
cf_req_scale <- function(req, scale) {
  scale <- vec_cast(scale, to = integer())
  vec_assert(scale, size = 1L)

  req_url_query(req, scaled = scale)
}

#' @rdname cf-request
#' @export
cf_req_limit <- function(req, limit) {
  limit <- vec_cast(limit, to = integer())
  vec_assert(limit, size = 1L)

  if (is.na(limit)) {
    abort("`limit` can't be `NA`.")
  }
  if (limit < 0L || limit > 100L) {
    abort("`limit` must be between `[0, 100]`.")
  }

  req_url_query(req, per_page = limit)
}

#' @rdname cf-request
#' @export
cf_req_affiliate <- function(req, affiliate) {
  affiliate <- vec_cast(affiliate, to = integer())
  vec_assert(affiliate, size = 1L)

  req_url_query(req, affiliate = affiliate)
}

#' @rdname cf-request
#' @export
cf_req_page <- function(req, page) {
  page <- vec_cast(page, to = integer())
  vec_assert(page, size = 1L)

  if (is.na(page)) {
    abort("`page` can't be `NA`.")
  }
  if (page <= 0L) {
    abort("`page` must be a positive integer.")
  }

  req_url_query(req, page = page)
}
