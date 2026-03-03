DEFAULT_PAYOUT_MULTIPLIERS <- c(
  "0" = -1,
  "1" = 1,
  "2" = 2,
  "3" = 3
)

CHUCK_A_LUCK_PROBS <- c(
  "0" = 125 / 216,
  "1" = 75 / 216,
  "2" = 15 / 216,
  "3" = 1 / 216
)

utils::globalVariables(c(
  # Variables used in dplyr and ggplot
  "Matches", "CumulativeCount", "Round", "NetWin", "count", "Theoretical",

  # Functions defined across scripts but used globally via source()
  "CHUCK_A_LUCK_PROBS", "DEFAULT_PAYOUT_MULTIPLIERS",
  "simulate_chuck_a_luck", "get_theoretical_prob", "get_theoretical_win_rate",
  "get_theoretical_house_edge", "calc_win_rate", "calc_sample_probability",
  "calc_sample_house_edge", "calc_moe_proportion", "calc_wilson_ci",
  "plot_lln_convergence", "plot_outcome_distribution", "format_confidence_interval"
))
