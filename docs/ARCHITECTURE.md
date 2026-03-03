# Architecture: Chuck-a-Luck Statistical Simulator

This document outlines the architectural decisions and design patterns used in the Chuck-a-Luck simulator.

## 1. Core Logic & Data Management

The application uses a modular structure to separate simulation logic, statistical analysis, and data visualization.

- **`data.table` for High Performance**: To support large-scale simulations (millions of rounds) without performance degradation, the application uses `data.table` for its reactive simulation state. `data.table`'s memory efficiency and vectorized operations (like `rbindlist`) ensure that the UI remains responsive even as data grows.
- **Vectorized Simulation**: The simulation engine in `R/simulation.R` uses R's vectorized `sample()` and logical operations to generate thousands of rounds simultaneously, rather than using slow loops.

## 2. Statistical Methodology

- **Wilson Score Interval**: We use the Wilson Score Interval for calculating 95% confidence intervals for proportions. This was chosen over the standard Wald (Normal) approximation because it provides better coverage and accuracy when:
  - The probability is very low (e.g., rolling 3 matches: $1/216 \approx 0.0046$).
  - The sample size is small.
- **Law of Large Numbers (LLN)**: The app is designed to empirically demonstrate LLN. The convergence graph shows the cumulative sample probability approaching the theoretical value as $N$ increases.
- **Namespace Management**: To ensure robustness, we use explicit namespacing (e.g., `stats::qnorm`) and maintain a `R/constants.R` file for global variables and shared theoretical values.

## 3. Frontend Architecture

- **Shiny & bslib**: Built with R Shiny using the `bslib` package for a modern, responsive user interface.
- **Reactive Design**: The application uses `reactiveVal` for simulation state and bankroll, ensuring that all UI elements (value boxes, plots, and tables) update atomically when new simulations are run.
- **Modular Scripts**:
  - `constants.R`: Ground truth for probabilities and shared constants.
  - `simulation.R`: The core RNG engine.
  - `statistics.R`: Analytical logic and CI calculations.
  - `plots.R`: `ggplot2` visualization templates.

## 4. Development & CI Lifecycle

- **Dependency Management**: The `DESCRIPTION` file serves as the project's manifest. We use the `remotes` package (via `make install`) to ensure all developers and CI environments are synchronized.
- **Automated Documentation**: We use `roxygen2` to manage the `NAMESPACE` and generate `.Rd` help files. Running `make doc` ensures that the public API exports are always up to date.
- **Unit Testing**: The project includes a comprehensive suite of tests in `tests/testthat/`, validating both simulation results and statistical accuracy.
- **Continuous Integration**: GitHub Actions is configured to run lints and tests on every push, ensuring that changes don't break core statistical logic or UI functionality.
