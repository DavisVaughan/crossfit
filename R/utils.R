multi_req_paginate <- function(req,
                               next_page,
                               n_pages = NULL,
                               progress = TRUE) {
  out <- vector("list", n_pages %||% 100)
  i <- 1L

  if (progress) {
    if (is.null(n_pages)) {
      format <- NULL
    } else {
      format <- "Downloading {cli::pb_bar} {cli::pb_current} / {cli::pb_total}"
    }

    cli::cli_progress_bar(
      total = n_pages,
      format = format
    )
  }

  repeat({
    out[[i]] <- req_perform(req)

    if (progress) {
      cli::cli_progress_update()
    }

    if (!is.null(n_pages) && i == n_pages) {
      break
    }

    req <- next_page(req, out[[i]])
    if (is.null(req)) {
      break
    }

    i <- i + 1L
    if (i > length(out)) {
      length(out) <- length(out) * 2L
    }
  })

  if (i != length(out)) {
    out <- out[seq_len(i)]
  }

  if (progress) {
    cli::cli_progress_done()
  }

  out
}

leaderboard_one_page <- function(body) {
  leaderboard <- body$leaderboardRows

  tibble::new_tibble(
    x = list(leaderboard = leaderboard),
    nrow = length(leaderboard)
  )
}

cf_next_page <- function(req, resp) {
  resp <- resp_body_json(resp)

  current_page <- resp$pagination$currentPage
  total_pages <- resp$pagination$totalPages

  if (current_page == total_pages) {
    NULL
  } else {
    cf_req_page(req, current_page + 1L)
  }
}
