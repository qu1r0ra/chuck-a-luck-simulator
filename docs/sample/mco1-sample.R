library(shiny)
library(ggplot2)
library(dplyr)
library(shinydashboard)

# --- UI Definition ---
ui <- dashboardPage(
  skin = "purple",
  dashboardHeader(title = "Sic Bo Big-Small Simulator"),

  dashboardSidebar(
    # User defines the game math here
    numericInput("p_true", "Theoretical Win Prob (p):", value = 0.4861, min = 0, max = 1, step = 0.01),
    numericInput("conf_level", "Confidence Level:", value = 0.95, min = 0.80, max = 0.99, step = 0.01),
    sliderInput("n_sims", "Simulated Rounds:", min = 1, max = 5000, value = 100),
    actionButton("play", "RUN SIMULATION", icon = icon("play"), class = "btn-success btn-lg"),
    hr(),
    actionButton("reset", "Clear Laboratory", icon = icon("refresh"))
  ),

  dashboardBody(
    fluidRow(
      valueBoxOutput("mle_box", width = 4),
      valueBoxOutput("total_n_box", width = 4),
      valueBoxOutput("error_margin_box", width = 4)
    ),

    fluidRow(
      box(title = "LLN Convergence (Frequentist p-hat)", status = "primary", solidHeader = TRUE,
          plotOutput("convergence_plot", height = 300)),
      box(title = "Interval Coverage Comparison", status = "warning", solidHeader = TRUE,
          plotOutput("ci_plot", height = 300))
    ),

    fluidRow(
      box(title = "Statistical Estimates & Intervals", width = 12,
          tableOutput("stat_summary"))
    )
  )
)

# --- Server Logic ---
server <- function(input, output, session) {

  vals <- reactiveValues(
    history = data.frame(),
    total_success = 0,
    total_n = 0
  )

  observeEvent(input$play, {
    n <- input$n_sims
    p <- input$p_true

    # Generic Bernoulli Trial (Success = 1, Failure = 0)
    outcomes <- rbinom(n, 1, p)

    df_new <- data.frame(
      id = (vals$total_n + 1):(vals$total_n + n),
      result = outcomes
    )

    vals$total_success <- vals$total_success + sum(outcomes)
    vals$total_n <- vals$total_n + n
    vals$history <- rbind(vals$history, df_new)
  })

  observeEvent(input$reset, {
    vals$history <- data.frame()
    vals$total_success <- 0
    vals$total_n <- 0
  })

  # --- Statistical Calculations ---

  output$mle_box <- renderValueBox({
    p_hat <- if(vals$total_n > 0) vals$total_success / vals$total_n else 0
    valueBox(round(p_hat, 4), "Maximum Likelihood Estimate", icon = icon("bullseye"), color = "blue")
  })

  output$total_n_box <- renderValueBox({
    valueBox(vals$total_n, "Total Trials (n)", icon = icon("database"), color = "purple")
  })

  output$convergence_plot <- renderPlot({
    req(nrow(vals$history) > 0)

    df <- vals$history %>%
      mutate(cum_p = cumsum(result) / id)

    ggplot(df, aes(x = id, y = cum_p)) +
      geom_line(color = "steelblue") +
      geom_hline(yintercept = input$p_true, linetype = "dashed", color = "red") +
      labs(x = "Trial Number", y = "Running Proportion (p-hat)") +
      theme_minimal()
  })

  output$stat_summary <- renderTable({
    req(vals$total_n > 0)

    n <- vals$total_n
    x <- vals$total_success
    p_hat <- x / n
    z <- qnorm(1 - (1 - input$conf_level) / 2)

    # 1. Wald Interval
    wald_se <- sqrt(p_hat * (1 - p_hat) / n)
    wald_lower <- p_hat - z * wald_se
    wald_upper <- p_hat + z * wald_se

    # 2. Wilson Score Interval
    denom <- 1 + z^2/n
    center <- (p_hat + z^2/(2*n)) / denom
    spread <- (z * sqrt(p_hat*(1-p_hat)/n + z^2/(4*n^2))) / denom
    wilson_lower <- center - spread
    wilson_upper <- center + spread

    # 3. Agresti-Coull
    n_tilde <- n + z^2
    p_tilde <- (x + z^2/2) / n_tilde
    ac_se <- sqrt(p_tilde * (1 - p_tilde) / n_tilde)
    ac_lower <- p_tilde - z * ac_se
    ac_upper <- p_tilde + z * ac_se

    data.frame(
      Method = c("Wald (Standard)", "Wilson Score", "Agresti-Coull"),
      Lower_Bound = c(wald_lower, wilson_lower, ac_lower),
      Upper_Bound = c(wald_upper, wilson_upper, ac_upper),
      Interval_Width = c(wald_upper-wald_lower, wilson_upper-wilson_lower, ac_upper-ac_lower)
    )
  })


  # Visualizing CI differences
  output$ci_plot <- renderPlot({
    req(vals$total_n > 0)

    # Prepare the data for plotting
    n <- vals$total_n
    x <- vals$total_success
    p_hat <- x / n
    z <- qnorm(1 - (1 - input$conf_level) / 2)

    # Calculations for the three methods
    # 1. Wald
    wald_se <- sqrt(p_hat * (1 - p_hat) / n)

    # 2. Wilson Score
    denom <- 1 + z^2/n
    center <- (p_hat + z^2/(2*n)) / denom
    spread <- (z * sqrt(p_hat*(1-p_hat)/n + z^2/(4*n^2))) / denom

    # 3. Agresti-Coull
    n_tilde <- n + z^2
    p_tilde <- (x + z^2/2) / n_tilde
    ac_se <- sqrt(p_tilde * (1 - p_tilde) / n_tilde)

    # Combine into a plotting data frame
    ci_df <- data.frame(
      Method = factor(c("Wald", "Wilson", "Agresti-Coull"),
                      levels = c("Wald", "Wilson", "Agresti-Coull")),
      Lower = c(p_hat - z * wald_se, center - spread, p_tilde - z * ac_se),
      Upper = c(p_hat + z * wald_se, center + spread, p_tilde + z * ac_se),
      Estimate = c(p_hat, center, p_tilde)
    )

    # Generate the Forest Plot
    ggplot(ci_df, aes(x = Method, y = Estimate, color = Method)) +
      geom_hline(yintercept = input$p_true, linetype = "dashed", color = "red", size = 1) +
      geom_errorbar(aes(ymin = Lower, ymax = Upper), width = 0.3, size = 1.2) +
      geom_point(size = 4) +
      coord_flip() + # Horizontal layout for easier comparison
      labs(title = paste(input$conf_level * 100, "% Confidence Interval Comparison"),
           subtitle = "Red Dashed Line = Theoretical Probability (p)",
           y = "Probability Scale", x = "") +
      theme_minimal() +
      theme(legend.position = "none", text = element_text(size = 14))
  })
}

shinyApp(ui, server)
