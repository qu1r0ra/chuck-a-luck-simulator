# Chuck-a-Luck Simulator: Self Context

## Project Status

- **Game**: Chuck-a-Luck (Bird Cage)
- **Selection**: User chooses a target match count (0, 1, 2, or 3).
- **Simulation**: Functional RNG engine using `data.table` for performance.
- **LLN Trace**: Functional convergence plot displaying full data trace.
- **CIs Implemented**: Wald (Normal), Wilson Score, Agresti-Coull.
- **Visual Analysis**:
  - "Dashboard & Graphs" tab for overall performance.
  - "Confidence Analysis" tab for interval comparison and shrinkage over time.
  - "Outcome History" for raw logs.
- **MLE**: Explicitly labeled and calculated as sample proportion.

## Recent Tasks Completed (per SPECS.md)

- Upgrade DESCRIPTION with R (>= 4.1.0) requirement, ByteCompile: true, and Roxygen Markdown support.
- Fully document theoretical parameters (Expected Value, House Edge) with exact summation formulas.
- Delineate reactive logic dependency graph in `architecture.md`.
- Extract "Historical Distribution" logic into dedicated `get_sample_distribution` function in `statistics.R`.
- Standardize `.gitignore` and `Makefile` for clean, professional PDF builds (removed build junk).
- Added sample technical report (`docs/sample/report.pdf`) as a reference for LaTeX-based documentation.
- Created `docs/design/` directory for project planning; restructured `report_plan.md` to match visual-weighted sample structure (removed conclusion).

## Statistical Methodology

- **Wald**: $\hat{p} \pm z\sqrt{\frac{\hat{p}(1-\hat{p})}{n}}$
- **Agresti-Coull**: Plus-four adjustment for 95% CI.
- **Wilson**: Efficient for rare events like rolling 3 matches ($1/216$).
- **Theoretical Probabilities**: Calculated using Binomial Distribution $B(3, 1/6)$.

## Performance

- **Visual Analysis**: All plots utilize the **full simulation dataset** for maximum precision.
- **DataTable Capping**: The "Detailed Round Log" table is capped at the **last 1,000 rounds** to maintain browser performance.
- **Reactive Efficiency**: Parameters like `target_outcome` trigger specific re-renders without re-simulating the entire dataset.
