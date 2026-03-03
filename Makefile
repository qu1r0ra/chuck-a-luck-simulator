.PHONY: run install format lint

# Default target
all: run

# Run the R Shiny application
run:
	Rscript -e "shiny::runApp(port=8080)"

# Install necessary R dependencies
install:
	Rscript -e "install.packages(c('bsicons', 'bslib', 'data.table', 'dplyr', 'DT', 'ggplot2', 'shiny', 'styler', 'lintr', 'testthat'), repos='https://cloud.r-project.org')"

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
