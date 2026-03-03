#' Get theoretical probability for a match count
#' @param matches [integer] The target number of matches (0-3)
#' @return [numeric] The theoretical probability
#' @export
get_theoretical_prob <- function(matches) {
  prob <- CHUCK_A_LUCK_PROBS[as.character(matches)]
  if (is.na(prob)) {
    0
  } else {
    unname(prob)
  }
}

#' @param payouts [numeric vector] Named vector of payout multipliers
#' @return [numeric] The theoretical win rate
#' @export
get_theoretical_win_rate <- function(payouts = DEFAULT_PAYOUT_MULTIPLIERS) {
  winning_matches <- names(payouts[payouts > 0])
  valid_matches <- intersect(winning_matches, names(CHUCK_A_LUCK_PROBS))
  sum(CHUCK_A_LUCK_PROBS[valid_matches])
}

#' @param payouts [numeric vector] Named vector of payout multipliers
#' @return [numeric] The theoretical house edge
#' @export
get_theoretical_house_edge <- function(payouts = DEFAULT_PAYOUT_MULTIPLIERS) {
  expected_value <- sum(payouts[names(CHUCK_A_LUCK_PROBS)] * CHUCK_A_LUCK_PROBS)
  -expected_value
}

#' @param sim_data [data.frame] Simulation data with a 'Matches' column
#' @param target_matches [integer] The match count to calculate probability for
#' @return [numeric] The sample probability
#' @export
calc_sample_probability <- function(sim_data, target_matches) {
  if (nrow(sim_data) == 0) {
    0
  } else {
    sum(sim_data$Matches == target_matches) / nrow(sim_data)
  }
}

#' @param sim_data [data.frame] Simulation data with 'NetWin' column
#' @return [numeric] The sample win rate
#' @export
calc_win_rate <- function(sim_data) {
  if (nrow(sim_data) == 0) {
    0
  } else {
    sum(sim_data$NetWin > 0) / nrow(sim_data)
  }
}

#' @param sim_data [data.frame] Simulation data with 'NetWin' column
#' @param wager_per_round [numeric] The amount bet per round
#' @return [numeric] The sample house edge
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

#' @param p_hat [numeric] Sample proportion
#' @param n [integer] Sample size
#' @param conf_level [numeric] Confidence level (e.g., 0.95)
#' @return [numeric] The margin of error
#' @export
calc_moe_proportion <- function(p_hat, n, conf_level = 0.95) {
  if (n == 0) {
    0
  } else {
    z <- stats::qnorm(1 - (1 - conf_level) / 2)
    z * sqrt(p_hat * (1 - p_hat) / n)
  }
}

#' @param p_hat [numeric] Sample proportion
#' @param n [integer] Sample size
#' @param conf_level [numeric] Confidence level (default 0.95)
#' @return [numeric vector] Lower and upper bounds
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

#' @param p_hat [numeric] Sample proportion
#' @param moe [numeric] Margin of Error
#' @return [character] Formatted interval string
#' @export
format_confidence_interval <- function(p_hat, moe) {
  lower <- max(0, p_hat - moe)
  upper <- min(1, p_hat + moe)
  sprintf("[%s, %s]", format(round(lower, 4), nsmall = 4), format(round(upper, 4), nsmall = 4))
}
