source("../../R/constants.R")
source("../../R/statistics.R")

test_that("Theoretical probabilities are correctly defined", {
  expect_equal(get_theoretical_prob(0), 125 / 216)
  expect_equal(get_theoretical_prob(1), 75 / 216)
  expect_equal(get_theoretical_prob(2), 15 / 216)
  expect_equal(get_theoretical_prob(3), 1 / 216)
  expect_equal(get_theoretical_prob(4), 0)
})

test_that("Wilson Score Interval stays within [0, 1]", {
  ci <- calc_wilson_ci(0.005, 100)
  expect_gt(ci[1], 0) || expect_equal(ci[1], 0)
  expect_lt(ci[2], 1) || expect_equal(ci[2], 1)
})

test_that("Sample house edge calculation handles edge cases", {
  expect_equal(calc_sample_house_edge(data.frame(), 1), 0)
  sim <- data.frame(NetWin = 1)
  expect_equal(calc_sample_house_edge(sim, 1), -1)
})
