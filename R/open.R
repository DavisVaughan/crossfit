#' CrossFit Open
#'
#' @description
#' `cf_open()` retrieves data from the CrossFit Open API, lightly pre-processed.
#' If you need low level access to the API, use [cf_request()].
#'
#' If no data is returned by the API, an empty tibble with zero columns and
#' zero rows is returned.
#'
#' You'll typically need to use [tidyr::unnest_wider()] and [tidyr::hoist()]
#' to further process this data.
#'
#' This function will automatically paginate through the data. To avoid
#' overloading the API, it will not perform more than 100 requests per minute.
#'
#' @inheritParams rlang::args_dots_empty
#'
#' @param year The year to retrieve data for. Note that not all parameters
#' will be valid for past years.
#'
#' @param division The division to retrieve data for. One of the values in
#' [cf_division].
#'
#' @param scale The workout scale to retrieve data for. One of the values in
#' [cf_scale].
#'
#' @param affiliate An optional integer ID to only retrieve data about a
#' particular affiliate.
#'
#' @param n_pages An optional integer to limit the number of pages returned.
#' Each page will have a maximum of 100 rows returned. This is useful if you
#' just want to explore the data without downloading all of it. If not
#' specified, this will download all available data.
#'
#' @param progress Should a progress bar be shown for longer downloads?
#'
#' @return A tibble.
#'
#' @export
#' @examples
#' library(tidyr)
#' library(dplyr)
#'
#' top_100 <- cf_open(2022, n_pages = 1)
#'
#' top_100 %>%
#'   unnest_wider(entrant) %>%
#'   hoist(scores, one = 1) %>%
#'   select(competitorName, one) %>%
#'   unnest_wider(one) %>%
#'   select(competitorName, score, breakdown)
#'
#' # CrossFit Huntersville
#' affiliate <- 16292
#'
#' cf_open(2022, division = cf_division$Women, affiliate = affiliate) %>%
#'   unnest_wider(entrant) %>%
#'   hoist(scores, two = 2) %>%
#'   select(competitorName, two) %>%
#'   unnest_wider(two) %>%
#'   select(competitorName, score, breakdown)
cf_open <- function(year,
                    ...,
                    division = cf_division$Men,
                    scale = cf_scale$rx,
                    affiliate = NULL,
                    n_pages = NULL,
                    progress = TRUE) {
  check_dots_empty()

  req <- cf_request(competition = cf_competition$open, year = year)
  req <- cf_req_division(req, division = division)
  req <- cf_req_scale(req, scale = scale)
  req <- cf_req_limit(req, limit = 100L)

  if (!is.null(affiliate)) {
    req <- cf_req_affiliate(req, affiliate)
  }

  req <- req_retry(req, max_tries = 3L)

  n_requests_per_minute <- 100 / 60
  req <- req_throttle(req, rate = n_requests_per_minute)

  test <- req_perform(req)
  test <- resp_body_json(test)
  total_pages <- test$pagination$totalPages

  if (total_pages == 0L) {
    # Worst case scenario, request worked but no data returned.
    # Just return an empty tibble. Complex to figure out "expected" columns.
    out <- tibble::new_tibble(x = list(), nrow = 0L)
    return(out)
  }

  if (is.null(n_pages)) {
    n_pages <- total_pages
  } else {
    n_pages <- min(total_pages, n_pages)
  }

  responses <- multi_req_paginate(
    req = req,
    next_page = cf_next_page,
    n_pages = n_pages,
    progress = progress
  )

  bodies <- lapply(responses, resp_body_json)

  leaderboard <- lapply(bodies, leaderboard_one_page)
  leaderboard <- vec_rbind(!!!leaderboard)

  leaderboard <- tidyr::unnest_wider(leaderboard, col = leaderboard)

  leaderboard
}
