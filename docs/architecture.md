# Project Architecture

This document describes the architectural design and directory structure of the `chuck-a-luck-simulator` project. It serves as a guide for developers and contributors to understand the core components and their interactions.

## Directory Structure Overview

```text
.
├── .github/                # CI/CD Workflows (GitHub Actions)
├── docs/                   # Project documentation and reports
│   ├── architecture.md     # Technical design (this document)
│   ├── math/               # Mathematical derivation notes
│   ├── reports/            # Generated PDF manuals and analysis
│   ├── sample/             # Reference code samples
│   └── specs/              # Formal project specifications
├── dump/                   # Temporary samples and reference material
├── man/                    # Generated help documentation (.Rd files)
├── misc/                   # Project context and personal notes
├── tests/                  # Unit testing suite
│   ├── testthat/           # Core component tests
│   └── testthat.R          # Test entry point
├── R/                      # Core logic modules
│   ├── constants.R         # Shared theoretical values and global variables
│   ├── plots.R             # Visualization logic (ggplot2)
│   ├── simulation.R        # RNG engine (vectorized dice rolls)
│   └── statistics.R        # Analytical functions and CI calculations
├── app.R                   # Main Shiny application (UI and Server)
├── DESCRIPTION             # Project manifest and dependency management
├── LICENSE                 # MIT License details
├── Makefile                # Unified development entry points
└── NAMESPACE               # Generated package exports
```

## Core Design Principles

### 1. High-Performance Data Handling

To support simulations of up to millions of rounds without UI lag, the project leverages **`data.table`**.

- **Memory Efficiency**: Uses fast, in-place modifications and optimized row-binding (`rbindlist`).
- **Reactive State**: The main simulation history is stored as a `data.table` within a Shiny `reactiveVal`.
- **UI Performance**: To ensure smooth browser interaction with large simulations, the front-end round log is capped at the last 1,000 observations while allowing plots to remain fully granular.

### 2. Statistical Robustness (Wilson Score Interval)

We prioritize mathematical accuracy over simple approximations.

- Unlike the standard Wald (Normal) confidence interval, we implement the **Wilson Score Interval**.
- This is critical for Chuck-a-Luck because the probability of rolling 3 matches ($1/216$) is small, and the sample size $N$ can vary. The Wilson interval provides more reliable coverage in these edge cases.

### 3. Modular Architecture

The logic is strictly decoupled to ensure maintainability:

- **`simulation.R`**: Stateless RNG logic that mimics the game mechanics.
- **`statistics.R`**: Pure analytical functions that take simulation data and return metrics.
- **`plots.R`**: Reusable plotting templates.
- **`app.R`**: Minimalist orchestration of UI and reactive server logic.

### 4. Reactive Logic & Data Flow

The Shiny application follows a hierarchical reactive pattern centered around the simulation state:

1. **State Management**: The core data is stored in `sim_state`, a `reactiveVal` containing a `data.table`. This choice ensures that all downstream outputs (plots, tables, metrics) update automatically whenever new rounds are simulated.
2. **Simulation Trigger**: The `input$sim_btn` (Simulate) observer calls `simulate_chuck_a_luck()`, performs an in-place update of the `Round` counter, and appends the new data to the existing `sim_state` using `rbindlist()`.
3. **Reactive Dependency Chain**:
   - **Dashboard Metrics**: `value_box` outputs (Bankroll, Win Rate, House Edge) react directly to changes in `sim_state()`.
   - **Visualizations**: All `renderPlot` calls depend on `sim_state()`. The **LLN Trace** and **CI Behavior** plots recompute cumulative values on-the-fly to ensure full-data precision.
   - **Outcome History**: The `DT` table uses a reactive subset (the last 1,000 rounds) to maintain rendering performance while still reacting to every new simulation.
4. **Parameter Isolation**: Choice of `target_outcome` or `bet_number` triggers re-rendering of outcome-specific plots (LLN Trace) without requiring a re-simulation of the underlying data.

### 5. Unified Public API

The project follows standard R package conventions. We use **`roxygen2`** to manage the `NAMESPACE`.

- Every function meant for external use is decorated with `@export`.
- Running `make doc` ensures that the `NAMESPACE` and internal documentation are synchronized, with the visual manual ending up in `docs/reports/`.

### 6. Automated Quality Control & CI/CD

- **Testing**: A comprehensive suite of unit tests covers logic verification in `tests/testthat/`.
- **Linting & Formatting**: Code is standardized using `styler` and `lintr` to maintain PEP 8-equivalent standards for R.
- **GitHub Actions**: A automated workflow runs lints and tests on every push, ensuring that the main branch remains stable.

## Statistical Methodology

The simulator implements a rigorous frequentist framework to study the success probability $p$ of chosen game outcomes.

### 1. Maximum Likelihood Estimation (MLE)

For a binomial outcome (e.g., rolling exactly $k$ matches), the **Maximum Likelihood Estimate** for the probability of success is simply the observed sample proportion:

$$\hat{p} = \frac{X}{n}$$

where $X$ is the count of successful outcomes and $n$ is the total number of rounds. In our application, this is labeled as the **MLE (Sample Probability)**.

### 2. Confidence Intervals (CI)

To quantify the uncertainty of the MLE estimate, we provide a comparison of three distinct frequentist intervals:

- **Wald (Normal) Interval:** The standard approximation based on the Normal distribution. While computationally simple, it can produce "impossible" values (outside [0, 1]) and fails for small $n$ or extreme probabilities.
  - **Formula**: $\hat{p} \pm z \sqrt{\frac{\hat{p}(1-\hat{p})}{n}}$
- **Wilson Score Interval:** A more robust method that centers the interval correctly and provides better coverage for rare events. It is the preferred method for this simulator due to the low probability of rolling 3 matches ($1/216$).
  - **Formula**: $\frac{\hat{p} + \frac{z^2}{2n} \pm z \sqrt{\frac{\hat{p}(1-\hat{p})}{n} + \frac{z^2}{4n^2}}}{1 + \frac{z^2}{n}}$
- **Agresti-Coull Interval:** Often called the "plus-four" interval, it improves the Wald interval by adding pseudo-counts (effectively 2 successes and 2 failures for 95% confidence).
  - **Formula**: $\tilde{p} \pm z \sqrt{\frac{\tilde{p}(1-\tilde{p})}{\tilde{n}}}$ where $\tilde{n} = n + z^2$ and $\tilde{p} = \frac{X + z^2/2}{\tilde{n}}$

### 3. Convergence & the Law of Large Numbers

The simulation generates a **Convergence Trace** that plots the running proportion of successes ($\hat{p}$) against the fixed **Theoretical Probability** ($p_{theoretical}$). This visually demonstrates the **Law of Large Numbers (LLN)**: as $n$ approaches infinity, the sample probability converges to the theoretical average.

### 4. Mathematical Derivation

The theoretical probability of rolling exactly $x$ matches $(x \in \{0, 1, 2, 3\})$ for a chosen number $b$ on three fair 6-sided dice is derived using the Binomial Distribution $B(n=3, p=1/6)$:

$$P(X=x) = \binom{3}{x} \left(\frac{1}{6}\right)^x \left(\frac{5}{6}\right)^{3-x}$$

- **$P(0)$**: $1 \cdot (1/216) \cdot 125 = 125/216 \approx 57.87\%$
- **$P(1)$**: $3 \cdot (1/6) \cdot (25/36) = 75/216 \approx 34.72\%$
- **$P(2)$**: $3 \cdot (1/36) \cdot (5/6) = 15/216 \approx 6.94\%$
- **$P(3)$**: $1 \cdot (1/216) \cdot 1 = 1/216 \approx 0.46\%$

### 5. Expected Value & House Edge

The **Theoretical House Edge** is the mathematical advantage the game operator maintains over the player, calculated as the negative of the **Expected Value ($E[X]$)** of a \$1 wager:

$$E[X] = \sum_{i=0}^{3} P(X=i) \cdot \text{Payout}_i$$

For the standard payout structure ($-1, 1, 2, 3$):
$$E[X] = \left(\frac{125}{216} \cdot -1\right) + \left(\frac{75}{216} \cdot 1\right) + \left(\frac{15}{216} \cdot 2\right) + \left(\frac{1}{216} \cdot 3\right) = -\frac{17}{216} \approx -7.87\%$$

The **House Edge** is therefore **7.87%**.

### 6. Theoretical Win Rate

The **Theoretical Win Rate** is the probability that a player rolls at least one match ($X \geq 1$):

$$P(X \geq 1) = P(1) + P(2) + P(3) = 1 - P(0) = \frac{91}{216} \approx 42.13\%$$

## Tools & Dependencies

- **Shiny**: Web framework for interactive simulation.
- **bslib / bsicons**: Modern, Bootstrap-based UI components.
- **data.table**: High-performance data manipulation.
- **ggplot2**: Grammatical visualization engine.
- **DT**: Interactive data table displays.
- **testthat**: Unit testing framework.
- **roxygen2**: Documentation and namespace management.
- **remotes**: Dependency resolution from manifest.
