source("../../R/constants.R")
source("../../R/simulation.R")

test_that("Simulation produces correct data structure", {
  n <- 10
  sim <- simulate_chuck_a_luck(n, 1, 1)
  expect_equal(nrow(sim), n)
  expect_true(all(c("Round", "Matches", "NetWin") %in% names(sim)))
})

test_that("Matches are correctly calculated", {
  sim <- simulate_chuck_a_luck(100, 1, 1)
  expect_true(all(sim$Matches >= 0 & sim$Matches <= 3))
})
