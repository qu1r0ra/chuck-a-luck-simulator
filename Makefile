.PHONY: all run install format lint test doc check

# Default entry point
all: run

# Boot up the Shiny web server
run:
	Rscript -e "shiny::runApp(port=8080)"

# Fetch all project requirements and R helpers
install:
	Rscript -e "if (!requireNamespace('remotes', quietly = TRUE)) install.packages('remotes')"
	Rscript -e "remotes::install_deps(dependencies = TRUE, repos = 'https://cloud.r-project.org')"

# Format core logic files and the main app
format:
	Rscript -e "styler::style_dir('R')"
	Rscript -e "styler::style_file('app.R')"

# Audit code quality against R standards
lint:
	Rscript -e "lintr::lint_dir()"

# Run full test suite with summary reporter
test:
	Rscript -e "testthat::test_dir('tests/testthat', reporter = 'summary')"

# Process roxygen2 tags and build the PDF manual in docs/reports/
doc:
	Rscript -e "roxygen2::roxygenize()"
	mkdir -p docs/reports
	R CMD Rd2pdf . --output=docs/reports/manual.pdf --force

# Run the complete verification lifecycle (format, lint, test, doc)
check: format lint test doc

# Remove the generated PDF manual
clean:
	rm -rf docs/reports/manual.pdf
