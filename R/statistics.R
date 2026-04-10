#' Get theoretical probability for a match count
#'
#' Calculated using the Binomial distribution \eqn{B(3, 1/6)}:
#' \deqn{P(X=x) = \binom{3}{x} p^x (1-p)^{3-x}}
#'
#' @param matches integer The target number of matches (0-3)
#' @return numeric The theoretical probability
#' @export
get_theoretical_prob <- function(matches) {
  prob <- CHUCK_A_LUCK_PROBS[as.character(matches)]
  if (is.na(prob)) {
    0
  } else {
    unname(prob)
  }
}

#' Get the theoretical win rate
#'
#' The probability of rolling at least one match \eqn{X \ge 1}:
#' \deqn{P(X \geq 1) = \sum_{x=1}^{3} P(X=x)}
#'
#' @param payouts numeric vector Named vector of payout multipliers
#' @return numeric The theoretical win rate
#' @export
get_theoretical_win_rate <- function(payouts = DEFAULT_PAYOUT_MULTIPLIERS) {
  winning_matches <- names(payouts[payouts > 0])
  valid_matches <- intersect(winning_matches, names(CHUCK_A_LUCK_PROBS))
  sum(CHUCK_A_LUCK_PROBS[valid_matches])
}

#' Get the theoretical house edge
#'
#' The house edge is the negative of the Expected Value of a \$1 wager:
#' \deqn{House Edge = -\sum_{x=0}^{3} P(X=x) \cdot \text{Payout}_x}
#'
#' @param payouts numeric vector Named vector of payout multipliers
#' @return numeric The theoretical house edge
#' @export
get_theoretical_house_edge <- function(payouts = DEFAULT_PAYOUT_MULTIPLIERS) {
  expected_value <- sum(payouts[names(CHUCK_A_LUCK_PROBS)] * CHUCK_A_LUCK_PROBS)
  -expected_value
}

#' Calculate sample probability for a target match count
#' @param sim_data data.frame Simulation data with a 'Matches' column
#' @param target_matches integer The match count to calculate probability for
#' @return numeric The sample probability
#' @export
calc_sample_probability <- function(sim_data, target_matches) {
  if (nrow(sim_data) == 0) {
    0
  } else {
    sum(sim_data$Matches == target_matches) / nrow(sim_data)
  }
}

#' Calculate the actual sample win rate
#' @param sim_data data.frame Simulation data with 'NetWin' column
#' @return numeric The sample win rate
#' @export
calc_win_rate <- function(sim_data) {
  if (nrow(sim_data) == 0) {
    0
  } else {
    sum(sim_data$NetWin > 0) / nrow(sim_data)
  }
}

#' Calculate the actual sample house edge
#' @param sim_data data.frame Simulation data with 'NetWin' column
#' @param wager_per_round numeric The amount bet per round
#' @return numeric The sample house edge
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

#' Calculate the distribution of outcomes from simulation data
#' @param sim_data data.frame Simulation data with 'Matches' column
#' @return data.frame Relative frequency distribution
#' @export
get_sample_distribution <- function(sim_data) {
  if (nrow(sim_data) == 0) {
    return(data.frame(Matches = 0:3, Frequency = rep(0, 4)))
  }

  counts <- table(factor(sim_data$Matches, levels = 0:3))
  data.frame(
    Matches = 0:3,
    Frequency = as.numeric(counts) / nrow(sim_data)
  )
}

#' Calculate Margin of Error for a proportion
#'
#' The standard margin of error for a binomial proportion is calculated as:
#' \deqn{MoE = z \cdot \sqrt{\frac{\hat{p}(1-\hat{p})}{n}}}
#'
#' @param p_hat numeric Sample proportion
#' @param n integer Sample size
#' @param conf_level numeric Confidence level (e.g., 0.95)
#' @return numeric The margin of error
#' @export
calc_moe_proportion <- function(p_hat, n, conf_level = 0.95) {
  if (n == 0) {
    0
  } else {
    z <- stats::qnorm(1 - (1 - conf_level) / 2)
    z * sqrt(p_hat * (1 - p_hat) / n)
  }
}

#' Calculate Wilson Score Interval
#'
#' The Wilson score interval provides better coverage than the Wald interval,
#' especially for small \code{n} or extreme probabilities. It is calculated as:
#' \deqn{\frac{\hat{p} + \frac{z^2}{2n} \pm z \cdot \sqrt{\frac{\hat{p}(1-\hat{p})}{n} +
#' \frac{z^2}{4n^2}}}{1 + \frac{z^2}{n}}}
#'
#' @param p_hat numeric Sample proportion
#' @param n integer Sample size
#' @param conf_level numeric Confidence level (default 0.95)
#' @return numeric vector Lower and upper bounds
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

  c(lower, upper)
}

#' Calculate Agresti-Coull Confidence Interval
#'
#' Known as the "plus-four" interval, it adds pseudo-counts to improve centering:
#' \deqn{\tilde{n} = n + z^2}
#' \deqn{\tilde{p} = \frac{X + \frac{z^2}{2}}{\tilde{n}}}
#' \deqn{\tilde{p} \pm z \sqrt{\frac{\tilde{p}(1-\tilde{p})}{\tilde{n}}}}
#'
#' @param p_hat numeric Sample proportion
#' @param n integer Sample size
#' @param conf_level numeric Confidence level (default 0.95)
#' @return numeric vector Lower and upper bounds
#' @export
calc_agresti_coull_ci <- function(p_hat, n, conf_level = 0.95) {
  if (n == 0) {
    return(c(0, 0))
  }

  z <- stats::qnorm(1 - (1 - conf_level) / 2)
  tilde_n <- n + z^2
  tilde_p <- (p_hat * n + z^2 / 2) / tilde_n

  moe <- z * sqrt(tilde_p * (1 - tilde_p) / tilde_n)

  c(tilde_p - moe, tilde_p + moe)
}

#' Calculate Wald (Normal) Confidence Interval
#'
#' The standard normal approximation for a binomial proportion:
#' \deqn{\hat{p} \pm z \cdot \sqrt{\frac{\hat{p}(1-\hat{p})}{n}}}
#'
#' @param p_hat numeric Sample proportion
#' @param n integer Sample size
#' @param conf_level numeric Confidence level (default 0.95)
#' @return numeric vector Lower and upper bounds
#' @export
calc_wald_ci <- function(p_hat, n, conf_level = 0.95) {
  if (n == 0) {
    return(c(0, 0))
  }

  moe <- calc_moe_proportion(p_hat, n, conf_level)
  c(p_hat - moe, p_hat + moe)
}

#' Format a confidence interval for display from a vector
#' @param ci numeric vector Lower and upper bounds
#' @return character Formatted interval string
#' @export
format_ci_vector <- function(ci) {
  sprintf("[%s, %s]", format(round(ci[1], 4), nsmall = 4), format(round(ci[2], 4), nsmall = 4))
}

#' Format a confidence interval for display
#' @param p_hat numeric Sample proportion
#' @param moe numeric Margin of Error
#' @return character Formatted interval string
#' @export
format_confidence_interval <- function(p_hat, moe) {
  lower <- max(0, p_hat - moe)
  upper <- min(1, p_hat + moe)
  sprintf("[%s, %s]", format(round(lower, 4), nsmall = 4), format(round(upper, 4), nsmall = 4))
}
