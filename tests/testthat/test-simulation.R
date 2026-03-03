source("../../R/constants.R")
source("../../R/simulation.R")

test_that("Simulation produces correct data structure", {
  n <- 10
  sim <- simulate_chuck_a_luck(n, 1, 1)
  expect_equal(nrow(sim), n)
  expect_true(all(c("Round", "Matches", "NetWin") %in% names(sim)))
  expect_type(sim$Round, "integer")
  expect_type(sim$Matches, "integer")
})

test_that("Simulation handles zero or negative rounds", {
  expect_equal(nrow(simulate_chuck_a_luck(0, 1, 1)), 0)
  expect_equal(nrow(simulate_chuck_a_luck(-1, 1, 1)), 0)
})

test_that("Matches are correctly calculated", {
  sim <- simulate_chuck_a_luck(100, 1, 1)
  expect_true(all(sim$Matches >= 0 & sim$Matches <= 3))
})

test_that("Custom payouts are respected", {
  # If we set payout for 1 match to 100
  custom_payouts <- c("0" = 0, "1" = 100, "2" = 0, "3" = 0)
  # We need a predictable outcome, but sample is random.
  # We can check if NetWin is always a multiple of 100 or 0.
  sim <- simulate_chuck_a_luck(100, 1, 1, payouts = custom_payouts)
  expect_true(all(sim$NetWin %in% c(0, 100)))
})
