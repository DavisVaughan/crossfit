#' CrossFit Games
#'
#' @description
#' `cf_games()` retrieves data from the CrossFit Games API, lightly
#' pre-processed. If you need low level access to the API, use [cf_request()].
#'
#' If no data is returned by the API, an empty tibble with zero columns and zero
#' rows is returned.
#'
#' You'll typically need to use [tidyr::unnest_wider()] and [tidyr::hoist()] to
#' further process this data.
#'
#' @inheritParams cf_open
#'
#' @return A tibble.
#'
#' @export
#' @examples
#' library(tidyr)
#' library(dplyr)
#'
#' games <- cf_games(2021)
#'
#' # 15 workouts in the 2021 CrossFit games
#' games %>%
#'   unnest_wider(entrant) %>%
#'   hoist(scores, two = 2) %>%
#'   select(competitorName, two) %>%
#'   unnest_wider(two) %>%
#'   select(competitorName, score, breakdown)
#'
#' # What affiliates were the top 20 associated with?
#' # (This is also a way to find an affiliate ID)
#' games %>%
#'   unnest_wider(entrant) %>%
#'   slice(1:20) %>%
#'   select(competitorName, affiliateId, affiliateName)
cf_games <- function(year,
                     ...,
                     division = cf_division$Men,
                     n_pages = NULL,
                     progress = TRUE) {
  check_dots_empty()

  req <- cf_request(competition = cf_competition$games, year = year)
  req <- cf_req_division(req, division = division)
  req <- cf_req_limit(req, limit = 100L)

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
