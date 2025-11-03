# ============================================================================
# Data Download Helper Script
# ============================================================================
# This script helps you download crime data from various sources

library(tidyverse)

cat("╔═══════════════════════════════════════════════════════════════════╗\n")
cat("║                  Crime Data Download Helper                       ║\n")
cat("╚═══════════════════════════════════════════════════════════════════╝\n\n")

# Create data directories
dir.create("data/raw", showWarnings = FALSE, recursive = TRUE)

# ============================================================================
# Function: Download Chicago Crime Data via API
# ============================================================================

download_chicago_crimes <- function(limit = 50000, output_file = "data/raw/chicago_crimes.csv") {
  cat("📡 Downloading Chicago Crime Data...\n")
  cat("   Limit:", limit, "records\n")
  cat("   This may take several minutes...\n\n")
  
  if (!require("RSocrata", quietly = TRUE)) {
    cat("⚠️  RSocrata package not installed.\n")
    cat("   Installing now...\n")
    install.packages("RSocrata")
  }
  
  library(RSocrata)
  
  tryCatch({
    # Download data from Chicago Data Portal
    url <- paste0("https://data.cityofchicago.org/resource/ijzp-q8t2.csv?$limit=", limit)
    
    crimes <- read.socrata(url)
    
    # Save to CSV
    write_csv(crimes, output_file)
    
    cat("✅ Successfully downloaded", nrow(crimes), "records\n")
    cat("💾 Saved to:", output_file, "\n\n")
    
    return(crimes)
  }, error = function(e) {
    cat("❌ Error downloading data:", e$message, "\n")
    cat("   Try downloading manually from:\n")
    cat("   https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-Present/ijzp-q8t2\n\n")
    return(NULL)
  })
}

# ============================================================================
# Function: Download Recent Chicago Crimes (Last 1 Year)
# ============================================================================

download_recent_chicago <- function(output_file = "data/raw/chicago_crimes_recent.csv") {
  cat("📡 Downloading Recent Chicago Crime Data (Last 12 months)...\n\n")
  
  if (!require("RSocrata", quietly = TRUE)) {
    install.packages("RSocrata")
  }
  
  library(RSocrata)
  
  # Calculate date one year ago
  one_year_ago <- format(Sys.Date() - 365, "%Y-%m-%dT%H:%M:%S")
  
  tryCatch({
    # Query for recent data only
    url <- paste0(
      "https://data.cityofchicago.org/resource/ijzp-q8t2.csv?",
      "$where=date>'", one_year_ago, "'&$limit=500000"
    )
    
    crimes <- read.socrata(url)
    write_csv(crimes, output_file)
    
    cat("✅ Downloaded", nrow(crimes), "records from the last year\n")
    cat("💾 Saved to:", output_file, "\n\n")
    
    return(crimes)
  }, error = function(e) {
    cat("❌ Error:", e$message, "\n\n")
    return(NULL)
  })
}

# ============================================================================
# Data Source Information
# ============================================================================

cat("📊 Available Data Sources:\n")
cat("===========================\n\n")

cat("1. Chicago Crime Data (2001-Present)\n")
cat("   • URL: https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-Present/ijzp-q8t2\n")
cat("   • Size: ~8 million records\n")
cat("   • Format: CSV, JSON, API\n")
cat("   • Update: Daily\n")
cat("   • Download: download_chicago_crimes(limit = 50000)\n\n")

cat("2. Madison Crime Reports\n")
cat("   • URL: https://data-cityofmadison.opendata.arcgis.com/\n")
cat("   • Format: CSV, GeoJSON\n")
cat("   • Manual download required\n\n")

cat("3. Los Angeles Crime Data\n")
cat("   • URL: https://data.lacity.org/Public-Safety/Crime-Data-from-2020-to-Present/2nrs-mtv8\n")
cat("   • Size: ~700k records\n")
cat("   • Format: CSV, API\n\n")

cat("4. New York City Crime Data\n")
cat("   • URL: https://data.cityofnewyork.us/Public-Safety/NYPD-Complaint-Data-Current-Year-To-Date-/5uac-w243\n")
cat("   • Format: CSV, API\n\n")

cat("5. San Francisco Crime Data\n")
cat("   • URL: https://data.sfgov.org/Public-Safety/Police-Department-Incident-Reports-2018-to-Present/wg3w-h783\n")
cat("   • Format: CSV, API\n\n")

# ============================================================================
# Interactive Download Menu
# ============================================================================

cat("\n🎯 Quick Actions:\n")
cat("==================\n\n")

if (interactive()) {
  cat("What would you like to do?\n\n")
  cat("1. Download Chicago crimes (50,000 records) - RECOMMENDED\n")
  cat("2. Download Chicago crimes (last 12 months)\n")
  cat("3. Download Chicago crimes (100,000 records)\n")
  cat("4. Show manual download instructions\n")
  cat("5. Exit\n\n")
  
  choice <- readline(prompt = "Enter your choice (1-5): ")
  
  if (choice == "1") {
    cat("\n")
    download_chicago_crimes(limit = 50000)
    cat("✨ Data ready! Now run: source('run_analysis.R')\n\n")
    
  } else if (choice == "2") {
    cat("\n")
    download_recent_chicago()
    cat("✨ Data ready! Now run: source('run_analysis.R')\n\n")
    
  } else if (choice == "3") {
    cat("\n")
    download_chicago_crimes(limit = 100000)
    cat("✨ Data ready! Now run: source('run_analysis.R')\n\n")
    
  } else if (choice == "4") {
    cat("\n📝 Manual Download Instructions:\n")
    cat("=================================\n\n")
    
    cat("For Chicago Data:\n")
    cat("1. Go to: https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-Present/ijzp-q8t2\n")
    cat("2. Click 'Export' button\n")
    cat("3. Choose 'CSV' format\n")
    cat("4. Save file to: data/raw/chicago_crimes.csv\n\n")
    
    cat("For Other Cities:\n")
    cat("1. Visit your city's open data portal\n")
    cat("2. Search for 'crime' or 'police incidents'\n")
    cat("3. Download as CSV\n")
    cat("4. Save to: data/raw/[cityname]_crimes.csv\n")
    cat("5. Update file path in scripts/01_data_import.R\n\n")
    
  } else {
    cat("\nℹ️  You can manually run download functions:\n")
    cat("   download_chicago_crimes(limit = 50000)\n")
    cat("   download_recent_chicago()\n\n")
  }
  
} else {
  cat("Run this script interactively to use the download menu.\n")
  cat("Or call functions directly:\n")
  cat("  download_chicago_crimes(limit = 50000)\n")
  cat("  download_recent_chicago()\n\n")
}

# ============================================================================
# Expected Data Format
# ============================================================================

cat("📋 Expected Data Format:\n")
cat("=========================\n\n")

cat("Your crime data CSV should have these columns (names may vary):\n\n")

cat("Required:\n")
cat("  ✓ date (or incident_date, occurred_date)\n")
cat("  ✓ latitude (numeric)\n")
cat("  ✓ longitude (numeric)\n")
cat("  ✓ crime_type (or primary_type, offense)\n\n")

cat("Optional but recommended:\n")
cat("  • arrest (TRUE/FALSE)\n")
cat("  • domestic (TRUE/FALSE)\n")
cat("  • location_description\n")
cat("  • district, beat, ward\n")
cat("  • year, month (will be generated if missing)\n\n")

cat("Example CSV structure:\n")
cat("  date,primary_type,latitude,longitude,arrest,domestic\n")
cat("  2024-01-15,THEFT,41.8781,-87.6298,FALSE,FALSE\n")
cat("  2024-01-16,BATTERY,41.8919,-87.6051,TRUE,TRUE\n\n")

cat("═════════════════════════════════════════════════════════════════\n")
cat("Note: If no data file is provided, the project will generate\n")
cat("      sample data automatically for demonstration purposes.\n")
cat("═════════════════════════════════════════════════════════════════\n\n")
