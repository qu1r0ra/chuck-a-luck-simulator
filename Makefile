.PHONY: run install format

# Default target
all: run

# Run the Shiny application
run:
	Rscript -e "shiny::runApp(port=8080)"

# Install necessary R dependencies
install:
	Rscript -e "install.packages(c('shiny', 'bslib', 'DT', 'ggplot2', 'dplyr', 'styler'), repos='https://cloud.r-project.org')"

# Optional formatting command using the styler package if you want to automatically format your R code
format:
	Rscript -e "styler::style_dir('R')"
	Rscript -e "styler::style_file('app.R')"
