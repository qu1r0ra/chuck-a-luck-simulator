library(ggplot2)
source("../../R/constants.R")
source("../../R/statistics.R")
source("../../R/plots.R")

test_that("LLN plot produces a ggplot object", {
  sim <- data.frame(Round = 1:10, Matches = sample(0:3, 10, replace = TRUE))
  p <- plot_lln_convergence(sim, 2)
  expect_s3_class(p, "ggplot")
})

test_that("LLN plot handles empty data", {
  p <- plot_lln_convergence(data.frame(), 2)
  expect_s3_class(p, "ggplot")
})

test_that("Distribution plot produces a ggplot object", {
  sim <- data.frame(Matches = sample(0:3, 100, replace = TRUE))
  p <- plot_outcome_distribution(sim)
  expect_s3_class(p, "ggplot")
})

test_that("Distribution plot handles empty data", {
  p <- plot_outcome_distribution(data.frame())
  expect_s3_class(p, "ggplot")
})

test_that("CI comparison plot produces a ggplot object", {
  p <- plot_ci_comparison(0.5, 100)
  expect_s3_class(p, "ggplot")
})

test_that("CI behavioral plot produces a ggplot object", {
  sim <- data.frame(Round = 1:100, Matches = sample(0:3, 100, replace = TRUE))
  p <- plot_ci_behavior(sim, 2)
  expect_s3_class(p, "ggplot")
})
