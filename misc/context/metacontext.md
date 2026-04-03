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

- [x] Create visualization of CI behavior (ribbon shrinkage) over growing sample size.
- [x] Explicitly document/visualize MLE.
- [x] Add mathematical derivation to architecture.md.
- [x] Integrate PDF manual generation into 'make doc' with output to 'docs/reports/'.

## Statistical Methodology

- **Wald**: $\hat{p} \pm z\sqrt{\frac{\hat{p}(1-\hat{p})}{n}}$
- **Agresti-Coull**: Plus-four adjustment for 95% CI.
- **Wilson**: Efficient for rare events like rolling 3 matches ($1/216$).
- **Theoretical Probabilities**: Calculated using Binomial Distribution $B(3, 1/6)$.

## Performance

- **Visual Analysis**: All plots (LLN Trace, CI Comparison, CI Behavior) utilize the **full simulation dataset** for maximum precision.
- **DataTable Capping**: The "Detailed Round Log" table is capped at the **last 1,000 rounds** to maintain browser performance during large data rendering.
