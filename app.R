library(shiny)
library(bslib)
library(DT)
library(data.table)

source("R/constants.R")
source("R/simulation.R")
source("R/statistics.R")
source("R/plots.R")

ui <- page_navbar(
  title = "Chuck-a-Luck Statistical Simulator",
  theme = bs_theme(version = 5, bootswatch = "flatly", primary = "#2c3e50"),
  sidebar = sidebar(
    width = 300,
    numericInput("wager_amount", "Wager Amount ($):", value = 1, min = 1, step = 1),
    selectInput("bet_number", "Number to Bet On:", choices = 1:6, selected = 1),
    numericInput("sim_rounds", "Simulated Rounds per click:", value = 100, min = 1, step = 10),
    actionButton("sim_btn", "Simulate Rounds", class = "btn-primary w-100 mb-2"),
    actionButton("reset_btn", "Clear / Restart", class = "btn-outline-danger w-100 mb-4"),
    hr(),
    h5("Project Configuration"),
    selectInput("target_outcome", "Highlight Outcome:",
      choices = list(
        "Rolling Zero Matches" = 0,
        "Rolling One Match" = 1,
        "Rolling Two Matches" = 2,
        "Rolling Three Matches" = 3
      ),
      selected = 2
    ),
    helpText(
      "Select whether you want to focus the specific convergence graphs and statistics on rolling ",
      "exactly 2 matches or 3 matches."
    ),
    accordion(
      accordion_panel(
        "Custom Payout Multipliers",
        numericInput("payout_0", "0 Matches:", value = DEFAULT_PAYOUT_MULTIPLIERS["0"], step = 1),
        numericInput("payout_1", "1 Match:", value = DEFAULT_PAYOUT_MULTIPLIERS["1"], step = 1),
        numericInput("payout_2", "2 Matches:", value = DEFAULT_PAYOUT_MULTIPLIERS["2"], step = 1),
        numericInput("payout_3", "3 Matches:", value = DEFAULT_PAYOUT_MULTIPLIERS["3"], step = 1)
      )
    )
  ),
  nav_panel(
    "Dashboard & Graphs",
    layout_columns(
      col_widths = c(4, 4, 4, 4, 4, 4),
      value_box(
        title = "Current Bankroll", value = textOutput("bankroll_out"),
        showcase = bsicons::bs_icon("cash-coin"), theme = "success"
      ),
      value_box(
        title = "Total Rounds Played", value = textOutput("rounds_out"),
        showcase = bsicons::bs_icon("hash"), theme = "info"
      ),
      value_box(
        title = "Target Matches Occurred", value = textOutput("target_occurred_out"),
        showcase = bsicons::bs_icon("bullseye"), theme = "primary"
      ),
      value_box(
        title = "Sample Win Rate / Theoretical", value = textOutput("win_rate_out"),
        showcase = bsicons::bs_icon("percent"), theme = "warning"
      ),
      value_box(
        title = "Sample House Edge", value = textOutput("house_edge_out"),
        showcase = bsicons::bs_icon("graph-down"), theme = "danger"
      ),
      value_box(
        title = "Theoretical House Edge", value = textOutput("theo_house_edge_out"),
        showcase = bsicons::bs_icon("building"), theme = "secondary"
      )
    ),
    hr(),
    layout_columns(
      col_widths = c(6, 6),
      card(
        card_header(
          "Law of Large Numbers: Convergence Graph",
          tooltip(
            bsicons::bs_icon("info-circle"),
            paste0(
              "Shows how the sample probability converges to the ",
              "theoretical probability as n approaches infinity."
            )
          )
        ),
        plotOutput("plot_lln")
      ),
      card(
        card_header(
          "Distribution of Outcomes",
          tooltip(
            bsicons::bs_icon("info-circle"),
            paste0(
              "Compares actual occurrences to expected occurrences ",
              "if we roll a great number of times."
            )
          )
        ),
        plotOutput("plot_dist")
      )
    ),
    layout_columns(
      col_widths = 12,
      card(
        card_header("Frequentist Estimates for Chosen Outcome"),
        p(strong("Target Outcome: "), textOutput("target_outcome_text", inline = TRUE)),
        tags$ul(
          tags$li(strong("Sample Probability: "), textOutput("sample_prob_out", inline = TRUE)),
          tags$li(strong("Theoretical Probability: "), textOutput("theo_prob_out", inline = TRUE)),
          tags$li(strong("Normal 95% CI (MOE): "), "±", textOutput("moe_out", inline = TRUE)),
          tags$li(strong("Normal 95% CI Range: "), textOutput("ci_out", inline = TRUE)),
          tags$li(strong("Wilson Score 95% CI: "), textOutput("wilson_ci_out", inline = TRUE))
        )
      )
    )
  ),
  nav_panel(
    "Outcome History",
    card(
      card_header("Detailed Round Log"),
      DTOutput("history_table")
    )
  )
)

server <- function(input, output, session) {
  sim_state <- reactiveVal(data.table())
  bankroll <- reactiveVal(1000)

  current_payouts <- reactive({
    c(
      "0" = input$payout_0,
      "1" = input$payout_1,
      "2" = input$payout_2,
      "3" = input$payout_3
    )
  })

  observeEvent(input$sim_btn, {
    new_sims <- simulate_chuck_a_luck(
      input$sim_rounds,
      as.numeric(input$bet_number),
      input$wager_amount,
      current_payouts()
    )

    setDT(new_sims)

    current_sims <- sim_state()
    if (nrow(current_sims) > 0) {
      new_sims[, Round := Round + max(current_sims$Round)]
      # data.table rbindlist is extremely fast for large simulations
      sim_state(rbindlist(list(current_sims, new_sims)))
    } else {
      sim_state(new_sims)
    }

    bankroll(bankroll() + sum(new_sims$NetWin))
  })

  output$wilson_ci_out <- renderText({
    dat <- sim_state()
    n <- nrow(dat)
    if (n == 0) {
      "[0.0000, 0.0000]"
    } else {
      tgt <- as.numeric(input$target_outcome)
      p_hat <- calc_sample_probability(dat, tgt)
      res <- calc_wilson_ci(p_hat, n)
      sprintf(
        "[%s, %s]",
        format(round(res[1], 4), nsmall = 4), format(round(res[2], 4), nsmall = 4)
      )
    }
  })

  observeEvent(input$reset_btn, {
    sim_state(data.table())
    bankroll(1000)
  })

  output$bankroll_out <- renderText({
    sprintf("$%s", format(bankroll(), big.mark = ","))
  })

  output$rounds_out <- renderText({
    format(nrow(sim_state()), big.mark = ",")
  })

  output$target_occurred_out <- renderText({
    dat <- sim_state()
    tgt <- as.numeric(input$target_outcome)
    if (nrow(dat) == 0) {
      "0"
    } else {
      format(sum(dat$Matches == tgt), big.mark = ",")
    }
  })

  output$win_rate_out <- renderText({
    dat <- sim_state()
    if (nrow(dat) == 0) {
      theo_win <- get_theoretical_win_rate(current_payouts())
      sprintf("0.00%% / %.2f%%", theo_win * 100)
    } else {
      sample_win <- calc_win_rate(dat)
      theo_win <- get_theoretical_win_rate(current_payouts())
      sprintf("%.2f%% / %.2f%%", sample_win * 100, theo_win * 100)
    }
  })

  output$house_edge_out <- renderText({
    dat <- sim_state()
    if (nrow(dat) == 0) {
      "0.00%"
    } else {
      edge <- calc_sample_house_edge(dat, input$wager_amount)
      sprintf("%.2f%%", edge * 100)
    }
  })

  output$theo_house_edge_out <- renderText({
    theo_edge <- get_theoretical_house_edge(current_payouts())
    sprintf("%.2f%%", theo_edge * 100)
  })

  output$plot_lln <- renderPlot({
    plot_lln_convergence(sim_state(), as.numeric(input$target_outcome))
  })

  output$plot_dist <- renderPlot({
    plot_outcome_distribution(sim_state())
  })

  output$target_outcome_text <- renderText({
    sprintf("Rolling exactly %s matches of number %s", input$target_outcome, input$bet_number)
  })

  output$sample_prob_out <- renderText({
    p_hat <- calc_sample_probability(sim_state(), as.numeric(input$target_outcome))
    sprintf("%.4f (%.2f%%)", p_hat, p_hat * 100)
  })

  output$theo_prob_out <- renderText({
    theo <- get_theoretical_prob(as.numeric(input$target_outcome))
    sprintf("%.4f (%.2f%%)", theo, theo * 100)
  })

  output$moe_out <- renderText({
    n <- nrow(sim_state())
    if (n == 0) {
      "0.0000"
    } else {
      p_hat <- calc_sample_probability(sim_state(), as.numeric(input$target_outcome))
      moe <- calc_moe_proportion(p_hat, n)
      sprintf("%.4f", moe)
    }
  })

  output$ci_out <- renderText({
    n <- nrow(sim_state())
    if (n == 0) {
      "[0, 0]"
    } else {
      p_hat <- calc_sample_probability(sim_state(), as.numeric(input$target_outcome))
      moe <- calc_moe_proportion(p_hat, n)
      format_confidence_interval(p_hat, moe)
    }
  })

  output$history_table <- renderDT({
    dat <- sim_state()
    if (nrow(dat) == 0) {
      datatable(data.frame("Message" = "No data. Click Simulate!"), options = list(dom = "t"))
    } else {
      dat <- dat |>
        dplyr::mutate(
          NetWin = sprintf("%s$%d", ifelse(NetWin < 0, "-", ""), abs(NetWin))
        ) |>
        dplyr::arrange(dplyr::desc(Round))

      datatable(dat,
        options = list(pageLength = 15, deferRender = TRUE, scrollY = 400),
        rownames = FALSE,
        colnames = c("Round #", "Die 1", "Die 2", "Die 3", "Matches", "Net Payout")
      )
    }
  })
}

shinyApp(ui = ui, server = server)
