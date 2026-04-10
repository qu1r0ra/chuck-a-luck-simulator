library(ggplot2)
library(dplyr)

#' Plot Law of Large Numbers convergence
#' @param sim_data data.frame Simulation data
#' @param target_matches integer The match count to visualize
#' @return ggplot Convergence plot
#' @export
plot_lln_convergence <- function(sim_data, target_matches) {
  if (nrow(sim_data) == 0) {
    ggplot() +
      theme_void() +
      annotate("text", x = 0.5, y = 0.5, label = "No data yet. Run simulations!")
  } else {
    theoretical <- get_theoretical_prob(target_matches)

    plot_df <- sim_data |>
      mutate(
        CumulativeCount = cumsum(Matches == target_matches),
        SampleProb = CumulativeCount / row_number()
      )

    ggplot(plot_df, aes(x = Round, y = SampleProb)) +
      geom_line(color = "#0d6efd", linewidth = 1) +
      geom_hline(yintercept = theoretical, color = "#dc3545", linetype = "dashed", linewidth = 1) +
      labs(
        title = "Law of Large Numbers Convergence",
        subtitle = sprintf(
          "Probability of rolling exactly %d match(es) | Theoretical: %.4f",
          target_matches, theoretical
        ),
        x = "Number of Rounds Simulated",
        y = "Cumulative Sample Probability"
      ) +
      scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(face = "bold"),
        panel.grid.minor = element_blank()
      )
  }
}

#' Plot the outcome frequency distribution
#' @param sim_data data.frame Simulation data
#' @return ggplot Distribution bar plot
#' @export
plot_outcome_distribution <- function(sim_data) {
  if (nrow(sim_data) == 0) {
    ggplot() +
      theme_void() +
      annotate("text", x = 0.5, y = 0.5, label = "No data yet. Run simulations!")
  } else {
    sample_dist <- get_sample_distribution(sim_data)
    theoretical_dist <- data.frame(
      Matches = 0:3,
      Theoretical = unname(CHUCK_A_LUCK_PROBS[as.character(0:3)])
    )

    ggplot(sample_dist, aes(x = factor(Matches, levels = 0:3))) +
      geom_bar(aes(y = Frequency, fill = "Sample Data"), stat = "identity", alpha = 0.8) +
      geom_point(
        data = theoretical_dist, aes(x = factor(Matches), y = Theoretical, color = "Theoretical"),
        size = 4
      ) +
      scale_fill_manual(name = "", values = c("Sample Data" = "#0dcaf0")) +
      scale_color_manual(name = "", values = c("Theoretical" = "#dc3545")) +
      labs(
        title = "Distribution of Matching Dice Outcomes",
        x = "Number of Matches (0, 1, 2, or 3)",
        y = "Relative Frequency"
      ) +
      scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(face = "bold"),
        legend.position = "top"
      )
  }
}

#' Plot Comparison of Confidence Intervals
#' @param p_hat numeric Sample proportion
#' @param n integer Sample size
#' @param conf_level numeric Confidence level
#' @return ggplot Error bar plot
#' @export
plot_ci_comparison <- function(p_hat, n, conf_level = 0.95) {
  if (n == 0) {
    ggplot() +
      theme_void() +
      annotate("text", x = 0.5, y = 0.5, label = "No data yet. Run simulations!")
  } else {
    wald <- calc_wald_ci(p_hat, n, conf_level)
    wilson <- calc_wilson_ci(p_hat, n, conf_level)
    agresti <- calc_agresti_coull_ci(p_hat, n, conf_level)

    df <- data.frame(
      Method = c("Wald (Normal)", "Wilson Score", "Agresti-Coull"),
      Lower = c(wald[1], wilson[1], agresti[1]),
      Upper = c(wald[2], wilson[2], agresti[2]),
      Estimate = rep(p_hat, 3)
    )

    ggplot(df, aes(x = Method, y = Estimate, color = Method)) +
      geom_point(size = 4) +
      geom_errorbar(aes(ymin = Lower, ymax = Upper), width = 0.2, linewidth = 1.2) +
      labs(
        title = "Confidence Intervals Comparison",
        subtitle = sprintf("Sample size: %d | Point estimate: %.4f", n, p_hat),
        y = "Probability Interval"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        legend.position = "none",
        plot.title = element_text(face = "bold"),
        axis.title.x = element_blank()
      )
  }
}

#' Plot CI Behavior as sample size grows
#' @param sim_data data.frame Simulation data
#' @param target_matches integer The match count
#' @param conf_level numeric Confidence level (default 0.95)
#' @return ggplot Ribbon plot
#' @export
plot_ci_behavior <- function(sim_data, target_matches, conf_level = 0.95) {
  if (nrow(sim_data) == 0) {
    ggplot() +
      theme_void() +
      annotate("text", x = 0.5, y = 0.5, label = "No data yet. Run simulations!")
  } else {
    plot_df <- sim_data |>
      mutate(
        CumulativeCount = cumsum(Matches == target_matches),
        SampleProb = CumulativeCount / row_number(),
        n = row_number()
      ) |>
      rowwise() |>
      mutate(
        Wald_L = calc_wald_ci(SampleProb, n, conf_level)[1],
        Wald_U = calc_wald_ci(SampleProb, n, conf_level)[2],
        Wilson_L = calc_wilson_ci(SampleProb, n, conf_level)[1],
        Wilson_U = calc_wilson_ci(SampleProb, n, conf_level)[2],
        Agresti_L = calc_agresti_coull_ci(SampleProb, n, conf_level)[1],
        Agresti_U = calc_agresti_coull_ci(SampleProb, n, conf_level)[2]
      ) |>
      ungroup()

    ggplot(plot_df, aes(x = n)) +
      geom_ribbon(aes(ymin = Wald_L, ymax = Wald_U, fill = "Wald (Normal)"), alpha = 0.2) +
      geom_ribbon(aes(ymin = Wilson_L, ymax = Wilson_U, fill = "Wilson Score"), alpha = 0.2) +
      geom_ribbon(aes(ymin = Agresti_L, ymax = Agresti_U, fill = "Agresti-Coull"), alpha = 0.2) +
      geom_line(aes(y = SampleProb), color = "#2c3e50", linewidth = 0.8) +
      labs(
        title = "Confidence Interval Width vs. Sample Size",
        subtitle = "Uncertainty shrinkage as trials increase",
        x = "Number of Trials",
        y = "Probability Ranges",
        fill = "Method"
      ) +
      scale_fill_brewer(palette = "Set1") +
      theme_minimal(base_size = 14) +
      theme(
        legend.position = "bottom",
        plot.title = element_text(face = "bold")
      )
  }
}

#' Plot House Edge Convergence
#' @param sim_data data.frame Simulation data
#' @param theo_edge numeric Theoretical house edge
#' @return ggplot Convergence plot
#' @export
plot_house_edge_convergence <- function(sim_data, theo_edge) {
  if (nrow(sim_data) == 0) {
    ggplot() +
      theme_void() +
      annotate("text", x = 0.5, y = 0.5, label = "No data yet. Run simulations!")
  } else {
    plot_df <- sim_data |>
      mutate(
        CumulativeProfit = cumsum(NetProfit),
        RunningExpectedValue = CumulativeProfit / row_number(),
        n = row_number()
      )

    ggplot(plot_df, aes(x = n, y = RunningExpectedValue)) +
      geom_line(color = "#e74c3c", linewidth = 0.8) +
      geom_hline(yintercept = theo_edge, linetype = "dashed", color = "#2c3e50") +
      annotate("text", x = 0, y = theo_edge, label = "Theoretical",
               vjust = -1, hjust = 0, color = "#2c3e50") +
      labs(
        title = "House Edge Convergence",
        subtitle = "Stabilization of Expected Value (EV) over total trials",
        x = "Number of Trials",
        y = "Running Net Profit per $1"
      ) +
      theme_minimal(base_size = 14) +
      theme(plot.title = element_text(face = "bold"))
  }
}
