# Project Architecture

This document describes the architectural design and directory structure of the `chuck-a-luck-simulator` project. It serves as a guide for developers and contributors to understand the core components and their interactions.

## Directory Structure Overview

```text
.
├── .github/                # CI/CD Workflows (GitHub Actions)
├── docs/                   # Project documentation
│   └── ARCHITECTURE.md     # Technical design (this document)
├── dump/                   # Temporary samples and reference material
├── man/                    # Generated help documentation (.Rd files)
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

### 4. Unified Public API

The project follows standard R package conventions. We use **`roxygen2`** to manage the `NAMESPACE`.

- Every function meant for external use is decorated with `@export`.
- Running `make doc` ensures that the `NAMESPACE` and internal documentation are synchronized.

### 5. Automated Quality Control & CI/CD

- **Testing**: A comprehensive suite of unit tests covers logic verification in `tests/testthat/`.
- **Linting & Formatting**: Code is standardized using `styler` and `lintr` to maintain PEP 8-equivalent standards for R.
- **GitHub Actions**: A automated workflow runs lints and tests on every push, ensuring that the main branch remains stable.

## Tools & Dependencies

- **Shiny**: Web framework for interactive simulation.
- **bslib / bsicons**: Modern, Bootstrap-based UI components.
- **data.table**: High-performance data manipulation.
- **ggplot2**: Grammatical visualization engine.
- **DT**: Interactive data table displays.
- **testthat**: Unit testing framework.
- **roxygen2**: Documentation and namespace management.
- **remotes**: Dependency resolution from manifest.
