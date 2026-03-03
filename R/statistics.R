#' Get the theoretical probability for an exact number of matches
#' @param matches The target number of matches (0, 1, 2, or 3)
#' @export
get_theoretical_prob <- function(matches) {
  prob <- CHUCK_A_LUCK_PROBS[as.character(matches)]
  if (is.na(prob)) {
    0
  } else {
    unname(prob)
  }
}

#' @export
get_theoretical_win_rate <- function(payouts = DEFAULT_PAYOUT_MULTIPLIERS) {
  winning_matches <- names(payouts[payouts > 0])
  valid_matches <- intersect(winning_matches, names(CHUCK_A_LUCK_PROBS))
  sum(CHUCK_A_LUCK_PROBS[valid_matches])
}

#' @export
get_theoretical_house_edge <- function(payouts = DEFAULT_PAYOUT_MULTIPLIERS) {
  expected_value <- sum(payouts[names(CHUCK_A_LUCK_PROBS)] * CHUCK_A_LUCK_PROBS)
  -expected_value
}

#' @export
calc_sample_probability <- function(sim_data, target_matches) {
  if (nrow(sim_data) == 0) {
    0
  } else {
    sum(sim_data$Matches == target_matches) / nrow(sim_data)
  }
}

#' @export
calc_win_rate <- function(sim_data) {
  if (nrow(sim_data) == 0) {
    0
  } else {
    sum(sim_data$NetWin > 0) / nrow(sim_data)
  }
}

#' @export
calc_sample_house_edge <- function(sim_data, wager_per_round) {
  if (nrow(sim_data) == 0 || wager_per_round == 0) {
    0
  } else {
    total_wagered <- nrow(sim_data) * wager_per_round
    total_won <- sum(sim_data$NetWin)
    -total_won / total_wagered
  }
}

#' @export
calc_moe_proportion <- function(p_hat, n, conf_level = 0.95) {
  if (n == 0) {
    0
  } else {
    z <- stats::qnorm(1 - (1 - conf_level) / 2)
    z * sqrt(p_hat * (1 - p_hat) / n)
  }
}

#' Calculate Wilson Score Interval (better for large N and small p)
#' @param p_hat Sample proportion
#' @param conf_level Confidence level (default 0.95)
#' @export
calc_wilson_ci <- function(p_hat, n, conf_level = 0.95) {
  if (n == 0) {
    return(c(0, 0))
  }

  z <- stats::qnorm(1 - (1 - conf_level) / 2)
  denom <- 1 + z^2 / n
  adj_p <- p_hat + z^2 / (2 * n)
  moe <- z * sqrt(p_hat * (1 - p_hat) / n + z^2 / (4 * n^2))

  lower <- (adj_p - moe) / denom
  upper <- (adj_p + moe) / denom

  c(max(0, lower), min(1, upper))
}

#' @export
format_confidence_interval <- function(p_hat, moe) {
  lower <- max(0, p_hat - moe)
  upper <- min(1, p_hat + moe)
  sprintf("[%s, %s]", format(round(lower, 4), nsmall = 4), format(round(upper, 4), nsmall = 4))
}
