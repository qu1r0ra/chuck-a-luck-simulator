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

test_that("CI width expands with higher confidence levels", {
  n <- 100
  p <- 0.5
  ci_80 <- calc_wilson_ci(p, n, conf_level = 0.80)
  ci_99 <- calc_wilson_ci(p, n, conf_level = 0.99)

  width_80 <- ci_80[2] - ci_80[1]
  width_99 <- ci_99[2] - ci_99[1]

  expect_gt(width_99, width_80)
})

test_that("Wald interval correctly handles p=0 edge case (collapses)", {
  # This verifies we documented its failure correctly
  ci_wald <- calc_wald_ci(0, 100, 0.95)
  expect_equal(ci_wald[1], 0)
  expect_equal(ci_wald[2], 0)
})

test_that("CI methods converge at large n", {
  # At n=1,000,000, standard errors are tiny, and all methods should yield ~the same
  n <- 1e6
  p <- 1 / 6
  conf <- 0.95

  wald <- calc_wald_ci(p, n, conf)
  wilson <- calc_wilson_ci(p, n, conf)
  agresti <- calc_agresti_coull_ci(p, n, conf)

  # Check that they are equal within a very small tolerance (0.001)
  expect_equal(wald[1], wilson[1], tolerance = 1e-3)
  expect_equal(wilson[1], agresti[1], tolerance = 1e-3)
  expect_equal(wald[2], agresti[2], tolerance = 1e-3)
})
