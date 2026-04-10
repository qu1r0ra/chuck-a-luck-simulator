# Technical Report Implementation Plan: Chuck-a-Luck Simulator

This plan outlines the structure and content for the final technical report, transitioning the `chuck-a-luck-simulator` project from a development phase to a formal academic delivery.

## 1. Structural Outline (adapted from `main.tex`)

The report will follow a 4-section structure, keeping it concise (3-5 pages) and visual-heavy, as per the reference `report.pdf`.

### Section 1: Introduction

- **Context**: Define Chuck-a-Luck (Bird Cage) and its role in probabilistic inquiry.
- **Objective**: Transitioning the game from a gambling activity into a controlled statistical laboratory.

### Section 2: Theoretical Probability & The House Advantage

- **Outcome Definition**:
  - Definition of "Matches" (0, 1, 2, or 3) on three independent 6-sided dice.
- **Theoretical Probability Table**:
  - Detailed table showing: Outcome (Matches), Dice Combinations (e.g., $1 \times 5 \times 5 \times 3$), Total Combinations ($6^3 = 216$), and Probability ($P(X=x)$).
- **The House Advantage**:
  - Calculation of Expected Value and House Edge (7.87% vs. 3.70% for variant).

### Section 3: Computational Framework & Shiny Architecture

This section describes the application environment and its reactive components.

- **UI Component Design**:
  - **Sidebar Control Plane**: Inputs for chosen number and simulation parameters (Trial Count).
  - **Dashboard Body**: Reactive display containers (`valueBox`, `plotOutput`).
- **[Figure 1: Application Overview]**: Screenshot of the dashboard in its initial or running state.

### Section 4: Statistical Methodology & Results

- **Maximum Likelihood Estimation**:
  - Derival of $\hat{p} = X/n$.
- **The Law of Large Numbers (LLN)**:
  - **[Figure 2: LLN Trace]**: Convergence plot of $\hat{p}$ against the theoretical constant.
  - Discussion of stabilization as $n \to \infty$.
- **Confidence Intervals**:
  - **Wald (Standard) Interval**: $\hat{p} \pm z \sqrt{\frac{\hat{p}(1-\hat{p})}{n}}$
  - **Wilson Score Interval**: $\frac{\hat{p} + \frac{z^2}{2n} \pm z \sqrt{\frac{\hat{p}(1-\hat{p})}{n} + \frac{z^2}{4n^2}}}{1 + \frac{z^2}{n}}$
  - **Agresti-Coull Interval**: The "Plus-Four" improvement.
- **Visual Analysis**:
  - **[Figure 3: CI Performance]**: Side-by-side comparison.
  - **[Figure 4: Interval Behavior Over N]**: Ribbon plot showing shrinkage.

### Section 5: Simulation Performance & AI Integration

- **Computational Efficiency**:
  - Brief note on the vectorized `data.table` engine allowing for high-fidelity simulations ($N > 10^6$) with minimal latency.
- **AI Citation & Usage**:
  - Formal citation of the AI assistant (Antigravity/Gemini) used for code optimization, documentation drafting (GitHub-flavored LaTeX standardization), and statistical verification.

---

## 2. To-Do List

1. [x] **Plan Creation**: Initial outline drafted in `report_plan.md`.
2. [ ] **Bibliography Update**: Update `references.bib` with citations for "Dice Play", "Wizard of Odds", and "Taboga (2021)".
3. [ ] **LaTeX Header Update**: Modify `main.tex` title and authors to match the Chuck-a-Luck project.
4. [ ] **Content Implementation**: Populate `main.tex` with the specific mathematical derivations from `architecture.md`.
5. [ ] **Assets/Screenshots**: (User Action) Take screenshots of the Shiny App and place them in `docs/reports/assets/figures/`.
6. [ ] **Final Render**: Execute LaTeX compilation (e.g., `pdflatex main.tex`) to produce the final PDF.

---

## 3. Mathematical Formula Map (for LaTeX)

| Topic               | Formula                                                                                                           |
| :------------------ | :---------------------------------------------------------------------------------------------------------------- |
| **Binomial PMF**    | `P(X=x) = \binom{3}{x} p^x (1-p)^{3-x}`                                                                           |
| **MLE Proportion**  | `\hat{p} = \frac{X}{n}`                                                                                           |
| **Wilson Interval** | `\frac{\hat{p} + \frac{z^2}{2n} \pm z \sqrt{\frac{\hat{p}(1-\hat{p})}{n} + \frac{z^2}{4n^2}}}{1 + \frac{z^2}{n}}` |
| **Expected Value**  | `E[X] = \sum_{i=0}^{3} P(X=i) \cdot \text{Payout}_i`                                                              |
