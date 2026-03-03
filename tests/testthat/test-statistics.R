source("../../R/constants.R")
source("../../R/statistics.R")

test_that("Theoretical probabilities are correctly defined", {
  expect_equal(get_theoretical_prob(0), 125 / 216)
  expect_equal(get_theoretical_prob(1), 75 / 216)
  expect_equal(get_theoretical_prob(2), 15 / 216)
  expect_equal(get_theoretical_prob(3), 1 / 216)
  expect_equal(get_theoretical_prob(4), 0)
})

test_that("Theoretical house edge and win rate are correct", {
  std_payouts <- c("0" = -1, "1" = 1, "2" = 2, "3" = 3)
  expect_equal(get_theoretical_house_edge(std_payouts), 17 / 216)
  expect_equal(get_theoretical_win_rate(std_payouts), (75 + 15 + 1) / 216)
})

test_that("Sample metrics are calculated correctly", {
  df <- data.frame(
    Matches = c(0, 1, 1, 2),
    NetWin = c(-1, 1, 1, 2)
  )
  expect_equal(calc_sample_probability(df, 1), 0.5)
  expect_equal(calc_win_rate(df), 0.75)
  expect_equal(calc_sample_house_edge(df, 1), -sum(df$NetWin) / (nrow(df) * 1))
})

test_that("Wilson Score Interval edge cases", {
  expect_equal(calc_wilson_ci(0, 0), c(0, 0))

  ci_zero <- calc_wilson_ci(0, 100)
  expect_equal(ci_zero[1], 0)
  expect_gt(ci_zero[2], 0)

  ci_one <- calc_wilson_ci(1, 100)
  expect_lt(ci_one[1], 1)
  expect_equal(ci_one[2], 1)
})

test_that("MOE and CI formatting", {
  expect_equal(calc_moe_proportion(0.5, 0), 0)
  expect_type(format_confidence_interval(0.5, 0.1), "character")
  expect_match(format_confidence_interval(0.5, 0.1), "\\[0.4000, 0.6000\\]")
})

test_that("Sample house edge handles edge cases", {
  expect_equal(calc_sample_house_edge(data.frame(), 1), 0)
  sim <- data.frame(NetWin = 1)
  expect_equal(calc_sample_house_edge(sim, 1), -1)
})
