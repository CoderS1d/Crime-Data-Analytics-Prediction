# ============================================================================
# QUICK START GUIDE
# ============================================================================
# Use this script to quickly get started with the Crime Analytics project

cat("
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║              CRIME ANALYTICS - QUICK START GUIDE                  ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
\n")

cat("This guide will help you set up and run the crime analytics project.\n\n")

# ============================================================================
# Step-by-Step Instructions
# ============================================================================

cat("📋 QUICK START STEPS:\n")
cat("======================\n\n")

cat("OPTION 1: Run Everything Automatically\n")
cat("---------------------------------------\n")
cat("Simply execute the master script:\n\n")
cat('  source("run_analysis.R")\n\n')
cat("This will:\n")
cat("  ✓ Install all required packages\n")
cat("  ✓ Generate sample data (or load your data)\n")
cat("  ✓ Perform time-series analysis\n")
cat("  ✓ Create forecasting models\n")
cat("  ✓ Generate geospatial visualizations\n")
cat("  ✓ Produce all plots and maps\n\n")

cat("OPTION 2: Run Step-by-Step\n")
cat("--------------------------\n")
cat("Execute each script individually:\n\n")

cat("1. Install packages:\n")
cat('   source("scripts/00_install_packages.R")\n\n')

cat("2. Import and clean data:\n")
cat('   source("scripts/01_data_import.R")\n\n')

cat("3. Perform time-series analysis:\n")
cat('   source("scripts/02_time_series_analysis.R")\n\n')

cat("4. Build forecasting models:\n")
cat('   source("scripts/03_forecasting.R")\n\n')

cat("5. Create geospatial visualizations:\n")
cat('   source("scripts/04_geospatial.R")\n\n')

cat("6. Launch interactive dashboard:\n")
cat('   library(shiny)\n')
cat('   runApp("dashboard/app.R")\n\n')

# ============================================================================
# Using Your Own Data
# ============================================================================

cat("📊 USING YOUR OWN CRIME DATA:\n")
cat("==============================\n\n")

cat("The project supports crime data from various sources.\n")
cat("Your data should have these columns:\n\n")

cat("Required columns:\n")
cat("  • date or incident_date (Date format)\n")
cat("  • latitude (numeric)\n")
cat("  • longitude (numeric)\n")
cat("  • crime_type or primary_type (text)\n\n")

cat("Optional columns:\n")
cat("  • arrest (TRUE/FALSE)\n")
cat("  • domestic (TRUE/FALSE)\n")
cat("  • location_description (text)\n")
cat("  • district, ward, etc. (numeric/text)\n\n")

cat("To use your data:\n")
cat('1. Place your CSV file in: data/raw/\n')
cat('2. Modify the file path in: scripts/01_data_import.R\n')
cat('3. Update the column names if needed\n\n')

# ============================================================================
# Data Sources
# ============================================================================

cat("🌐 RECOMMENDED DATA SOURCES:\n")
cat("=============================\n\n")

cat("1. Chicago Crime Data:\n")
cat("   URL: https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-Present/ijzp-q8t2\n")
cat("   Format: CSV download or API access\n\n")

cat("2. Madison Police Department:\n")
cat("   URL: https://data-cityofmadison.opendata.arcgis.com/\n")
cat("   Format: CSV or GeoJSON\n\n")

cat("3. Your City's Open Data Portal:\n")
cat("   Many cities provide crime data through open data portals\n")
cat("   Search for: '[Your City] open data crime'\n\n")

cat("4. Sample Data:\n")
cat("   The project includes a sample data generator for testing\n")
cat("   It creates realistic crime data automatically\n\n")

# ============================================================================
# Package Requirements
# ============================================================================

cat("📦 REQUIRED R PACKAGES:\n")
cat("========================\n\n")

required_packages <- c(
  "tidyverse", "janitor", "lubridate", "data.table",
  "tsibble", "forecast", "fable", "feasts", "prophet",
  "sf", "leaflet", "leaflet.extras", "viridis", "RColorBrewer",
  "shiny", "shinydashboard", "flexdashboard", "DT", "plotly", "shinythemes",
  "scales", "gridExtra", "knitr", "readr", "readxl", "jsonlite"
)

cat("All packages will be installed automatically when you run:\n")
cat('source("scripts/00_install_packages.R")\n\n')

cat("Or install them manually:\n")
cat('install.packages(c(\n')
for (i in 1:length(required_packages)) {
  cat('  "', required_packages[i], '"', sep = "")
  if (i < length(required_packages)) cat(",\n") else cat("\n")
}
cat('))\n\n')

# ============================================================================
# Troubleshooting
# ============================================================================

cat("🔧 TROUBLESHOOTING:\n")
cat("====================\n\n")

cat("Issue: Package installation fails\n")
cat("Solution: Install packages one at a time and check for errors\n")
cat('         Try: install.packages("package_name", dependencies = TRUE)\n\n')

cat("Issue: Data file not found\n")
cat("Solution: Check file path and ensure data is in data/raw/ folder\n")
cat('         The script will generate sample data if no file is found\n\n')

cat("Issue: Out of memory errors\n")
cat("Solution: Use data sampling in 01_data_import.R\n")
cat('         Set sample_size parameter (e.g., sample_size = 10000)\n\n')

cat("Issue: Dashboard won't launch\n")
cat("Solution: Ensure all analysis scripts have been run first\n")
cat('         Check that processed data files exist in data/processed/\n\n')

cat("Issue: Maps not displaying\n")
cat("Solution: Open HTML files directly in a web browser\n")
cat('         Files are located in outputs/maps/\n\n')

# ============================================================================
# Quick Test
# ============================================================================

cat("🧪 QUICK TEST:\n")
cat("===============\n\n")

cat("To verify your setup, run this quick test:\n\n")

cat("# Test 1: Check working directory\n")
cat('getwd()\n\n')

cat("# Test 2: Check if key packages are installed\n")
cat('library(tidyverse)\n')
cat('library(forecast)\n')
cat('library(leaflet)\n')
cat('library(shiny)\n\n')

cat("# Test 3: Run with sample data\n")
cat('source("run_analysis.R")\n\n')

cat("If all tests pass, you're ready to go! 🚀\n\n")

# ============================================================================
# Support
# ============================================================================

cat("📞 NEED HELP?\n")
cat("==============\n\n")

cat("1. Check README.md for detailed documentation\n")
cat("2. Review script comments for specific issues\n")
cat("3. Ensure all file paths are correct for Windows\n")
cat("4. Verify data format matches expected structure\n\n")

cat("═════════════════════════════════════════════════════════════════\n")
cat("Ready to start? Run: source('run_analysis.R')\n")
cat("═════════════════════════════════════════════════════════════════\n\n")

# ============================================================================
# Interactive Menu (Optional)
# ============================================================================

if (interactive()) {
  cat("\n🎯 Would you like to start the analysis now?\n\n")
  cat("1. Yes - Run full analysis with sample data\n")
  cat("2. No - I'll run it manually later\n")
  cat("3. Install packages only\n\n")
  
  choice <- readline(prompt = "Enter your choice (1-3): ")
  
  if (choice == "1") {
    cat("\n🚀 Starting full analysis...\n\n")
    source("run_analysis.R")
  } else if (choice == "3") {
    cat("\n📦 Installing packages...\n\n")
    source("scripts/00_install_packages.R")
  } else {
    cat("\n✅ Setup complete! Run 'source(\"run_analysis.R\")' when ready.\n\n")
  }
}
