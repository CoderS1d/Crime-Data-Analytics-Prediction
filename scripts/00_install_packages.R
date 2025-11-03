# ============================================================================
# Package Installation Script for Crime Data Analytics Project
# ============================================================================
# This script installs all required R packages for the crime analytics project
# Run this once before executing other scripts

cat("================================\n")
cat("Crime Analytics - Package Setup\n")
cat("================================\n\n")

# Set CRAN mirror
options(repos = c(CRAN = "https://cran.r-project.org/"))

# Function to install packages if not already installed
install_if_missing <- function(packages) {
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      cat(paste("Installing", pkg, "...\n"))
      install.packages(pkg, dependencies = TRUE)
    } else {
      cat(paste(pkg, "is already installed.\n"))
    }
  }
}

# Core data manipulation packages
cat("\n📦 Installing Core Data Packages...\n")
core_packages <- c(
  "tidyverse",      # Data manipulation and visualization
  "janitor",        # Data cleaning
  "lubridate",      # Date/time handling
  "data.table"      # Fast data processing
)
install_if_missing(core_packages)

# Time-series packages
cat("\n📈 Installing Time-Series Packages...\n")
ts_packages <- c(
  "tsibble",        # Time-series tibbles
  "forecast",       # ARIMA and forecasting
  "fable",          # Modern forecasting framework
  "feasts",         # Feature extraction and statistics
  "prophet"         # Facebook Prophet
)
install_if_missing(ts_packages)

# Geospatial packages
cat("\n🗺️ Installing Geospatial Packages...\n")
geo_packages <- c(
  "sf",             # Simple features for spatial data
  "leaflet",        # Interactive maps
  "leaflet.extras", # Additional leaflet features
  "ggmap",          # Static maps
  "viridis",        # Color palettes
  "RColorBrewer"    # Color schemes
)
install_if_missing(geo_packages)

# Dashboard packages
cat("\n📊 Installing Dashboard Packages...\n")
dashboard_packages <- c(
  "shiny",          # Interactive web apps
  "shinydashboard", # Dashboard layout
  "flexdashboard",  # Flexible dashboards
  "DT",             # Interactive tables
  "plotly",         # Interactive plots
  "shinythemes"     # Shiny themes
)
install_if_missing(dashboard_packages)

# Additional utility packages
cat("\n🔧 Installing Utility Packages...\n")
utility_packages <- c(
  "scales",         # Scale functions for visualization
  "gridExtra",      # Arrange multiple plots
  "knitr",          # Dynamic report generation
  "readr",          # Fast CSV reading
  "readxl",         # Excel file reading
  "jsonlite"        # JSON handling
)
install_if_missing(utility_packages)

# Optional: RSocrata for Chicago data
cat("\n🌐 Installing Optional Data Access Packages...\n")
optional_packages <- c(
  "RSocrata"        # Access open data portals
)
install_if_missing(optional_packages)

# Verify installation
cat("\n✅ Verifying Installation...\n")
all_packages <- c(core_packages, ts_packages, geo_packages, 
                  dashboard_packages, utility_packages, optional_packages)

missing <- c()
for (pkg in all_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    missing <- c(missing, pkg)
  }
}

if (length(missing) == 0) {
  cat("\n✨ All packages installed successfully!\n")
  cat("You can now run the analysis scripts.\n\n")
} else {
  cat("\n⚠️ The following packages failed to install:\n")
  cat(paste(missing, collapse = ", "), "\n")
  cat("\nPlease install them manually using:\n")
  cat(paste0("install.packages(c('", paste(missing, collapse = "', '"), "'))\n\n"))
}

cat("================================\n")
cat("Setup Complete!\n")
cat("================================\n")
