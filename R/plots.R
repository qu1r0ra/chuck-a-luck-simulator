library(ggplot2)
library(dplyr)

#' @export
plot_lln_convergence <- function(sim_data, target_matches) {
  if (nrow(sim_data) == 0) {
    ggplot() +
      theme_void() +
      annotate("text", x = 0.5, y = 0.5, label = "No data yet. Run simulations!")
  } else {
    sim_data <- sim_data |>
      mutate(
        CumulativeCount = cumsum(Matches == target_matches),
        SampleProb = CumulativeCount / row_number()
      )

    theoretical <- get_theoretical_prob(target_matches)

    ggplot(sim_data, aes(x = Round, y = SampleProb)) +
      geom_line(color = "#0d6efd", linewidth = 1) +
      geom_hline(yintercept = theoretical, color = "#dc3545", linetype = "dashed", linewidth = 1) +
      labs(
        title = "Law of Large Numbers Convergence",
        subtitle = sprintf(
          "Probability of rolling exactly %d match(es) | Dashed line: Theoretical (%.4f)",
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

#' @export
plot_outcome_distribution <- function(sim_data) {
  if (nrow(sim_data) == 0) {
    ggplot() +
      theme_void() +
      annotate("text", x = 0.5, y = 0.5, label = "No data yet. Run simulations!")
  } else {
    dist_probs <- data.frame(
      Matches = 0:3,
      Theoretical = unname(CHUCK_A_LUCK_PROBS[as.character(0:3)])
    )

    ggplot(sim_data, aes(x = factor(Matches, levels = 0:3))) +
      geom_bar(aes(y = after_stat(count / sum(count)), fill = "Sample Data"), alpha = 0.8) +
      geom_point(
        data = dist_probs, aes(x = factor(Matches), y = Theoretical, color = "Theoretical"),
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
