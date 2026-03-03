.PHONY: run install format lint test doc check

# Default target
all: run

# Run the R Shiny application
run:
	Rscript -e "shiny::runApp(port=8080)"

# Install necessary R dependencies from DESCRIPTION file
install:
	Rscript -e "if (!requireNamespace('remotes', quietly = TRUE)) install.packages('remotes')"
	Rscript -e "remotes::install_deps(dependencies = TRUE, repos = 'https://cloud.r-project.org')"

# Format R code
format:
	Rscript -e "styler::style_dir('R')"
	Rscript -e "styler::style_file('app.R')"

# Lint R code
lint:
	Rscript -e "lintr::lint_dir()"

# Run tests
test:
	Rscript -e "testthat::test_dir('tests/testthat')"

# Generate documentation and NAMESPACE
doc:
	Rscript -e "roxygen2::roxygenize()"

# Full check before pushing to Git
check: doc format lint test
