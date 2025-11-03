# ============================================================================
# Master Script - Run All Crime Analytics
# ============================================================================
# This script runs the entire crime analytics pipeline in sequence
# Run this to execute all analysis steps at once

cat("
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║          CRIME DATA ANALYTICS & PREDICTION PROJECT               ║
║                                                                   ║
║  Time-Series Analysis | Forecasting | Geospatial Visualization   ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
\n")

# ============================================================================
# Configuration
# ============================================================================

# Set working directory to project root if needed
# setwd("d:/Project/R/Crime report")

# Control which scripts to run
RUN_PACKAGE_INSTALL <- TRUE    # Install required packages
RUN_DATA_IMPORT <- TRUE        # Import and clean data
RUN_TIMESERIES <- TRUE         # Time-series analysis
RUN_FORECASTING <- TRUE        # ARIMA and Prophet forecasting
RUN_GEOSPATIAL <- TRUE         # Geospatial analysis and maps
LAUNCH_DASHBOARD <- FALSE      # Launch Shiny dashboard after analysis

# ============================================================================
# Step 0: Package Installation
# ============================================================================

if (RUN_PACKAGE_INSTALL) {
  cat("\n▶ STEP 0: Installing Required Packages\n")
  cat("========================================\n")
  
  tryCatch({
    source("scripts/00_install_packages.R")
    cat("✅ Package installation complete!\n\n")
  }, error = function(e) {
    cat("❌ Error in package installation:", e$message, "\n")
    cat("Please install packages manually and try again.\n\n")
  })
  
  Sys.sleep(2)
}

# ============================================================================
# Step 1: Data Import and Cleaning
# ============================================================================

if (RUN_DATA_IMPORT) {
  cat("\n▶ STEP 1: Data Import and Cleaning\n")
  cat("====================================\n")
  
  start_time <- Sys.time()
  
  tryCatch({
    source("scripts/01_data_import.R")
    
    elapsed <- round(as.numeric(difftime(Sys.time(), start_time, units = "secs")), 2)
    cat("\n✅ Data import complete! (", elapsed, "seconds)\n\n")
  }, error = function(e) {
    cat("❌ Error in data import:", e$message, "\n\n")
    return(NULL)
  })
  
  Sys.sleep(2)
}

# ============================================================================
# Step 2: Time-Series Analysis
# ============================================================================

if (RUN_TIMESERIES) {
  cat("\n▶ STEP 2: Time-Series Analysis\n")
  cat("================================\n")
  
  start_time <- Sys.time()
  
  tryCatch({
    source("scripts/02_time_series_analysis.R")
    
    elapsed <- round(as.numeric(difftime(Sys.time(), start_time, units = "secs")), 2)
    cat("\n✅ Time-series analysis complete! (", elapsed, "seconds)\n\n")
  }, error = function(e) {
    cat("❌ Error in time-series analysis:", e$message, "\n\n")
  })
  
  Sys.sleep(2)
}

# ============================================================================
# Step 3: Forecasting Models
# ============================================================================

if (RUN_FORECASTING) {
  cat("\n▶ STEP 3: Crime Forecasting (ARIMA & Prophet)\n")
  cat("===============================================\n")
  
  start_time <- Sys.time()
  
  tryCatch({
    source("scripts/03_forecasting.R")
    
    elapsed <- round(as.numeric(difftime(Sys.time(), start_time, units = "secs")), 2)
    cat("\n✅ Forecasting complete! (", elapsed, "seconds)\n\n")
  }, error = function(e) {
    cat("❌ Error in forecasting:", e$message, "\n\n")
  })
  
  Sys.sleep(2)
}

# ============================================================================
# Step 4: Geospatial Analysis
# ============================================================================

if (RUN_GEOSPATIAL) {
  cat("\n▶ STEP 4: Geospatial Analysis and Mapping\n")
  cat("===========================================\n")
  
  start_time <- Sys.time()
  
  tryCatch({
    source("scripts/04_geospatial.R")
    
    elapsed <- round(as.numeric(difftime(Sys.time(), start_time, units = "secs")), 2)
    cat("\n✅ Geospatial analysis complete! (", elapsed, "seconds)\n\n")
  }, error = function(e) {
    cat("❌ Error in geospatial analysis:", e$message, "\n\n")
  })
  
  Sys.sleep(2)
}

# ============================================================================
# Summary and Next Steps
# ============================================================================

cat("\n")
cat("╔═══════════════════════════════════════════════════════════════════╗\n")
cat("║                    ANALYSIS COMPLETE! ✨                          ║\n")
cat("╚═══════════════════════════════════════════════════════════════════╝\n\n")

cat("📊 Generated Outputs:\n")
cat("=====================\n\n")

cat("📁 Plots & Visualizations:\n")
cat("   → outputs/plots/01_monthly_trends.png\n")
cat("   → outputs/plots/02_yearly_trends.png\n")
cat("   → outputs/plots/03_seasonal_patterns.png\n")
cat("   → outputs/plots/04_weekday_patterns.png\n")
cat("   → outputs/plots/05_hourly_patterns.png (if available)\n")
cat("   → outputs/plots/06_crime_type_trends.png\n")
cat("   → outputs/plots/07_temporal_heatmap.png\n")
cat("   → outputs/plots/08_arima_forecast.png\n")
cat("   → outputs/plots/09_prophet_forecast.png\n")
cat("   → outputs/plots/10_prophet_components.png\n")
cat("   → outputs/plots/11_model_comparison.png\n")
cat("   → outputs/plots/12_trend_decomposition.png\n")
cat("   → outputs/plots/13_crime_density_map.png\n")
cat("   → outputs/plots/14_crime_hotspots.png\n\n")

cat("🗺️ Interactive Maps:\n")
cat("   → outputs/maps/map_01_all_crimes.html\n")
cat("   → outputs/maps/map_02_heatmap.html\n")
cat("   → outputs/maps/map_03_hotspots.html\n")
cat("   → outputs/maps/map_04_by_crime_type.html\n")
cat("   → outputs/maps/map_05_temporal_comparison.html\n\n")

cat("📄 Data Exports:\n")
cat("   → outputs/arima_forecast.csv\n")
cat("   → outputs/prophet_forecast.csv\n")
cat("   → outputs/crime_hotspots.csv\n")
cat("   → outputs/top_hotspots.csv\n\n")

cat("💾 Processed Data:\n")
cat("   → data/processed/crime_data_clean.csv\n")
cat("   → data/processed/crime_data_clean.RData\n")
cat("   → data/processed/timeseries_data.RData\n")
cat("   → data/processed/forecast_models.RData\n")
cat("   → data/processed/geospatial_data.RData\n\n")

# ============================================================================
# Launch Dashboard (Optional)
# ============================================================================

if (LAUNCH_DASHBOARD) {
  cat("🚀 Launching Interactive Dashboard...\n\n")
  
  if (require("shiny", quietly = TRUE)) {
    tryCatch({
      shiny::runApp("dashboard/app.R")
    }, error = function(e) {
      cat("❌ Error launching dashboard:", e$message, "\n")
      cat("You can launch it manually with: shiny::runApp('dashboard/app.R')\n\n")
    })
  } else {
    cat("⚠️ Shiny package not found. Install it to run the dashboard.\n")
    cat("Run: install.packages('shiny')\n\n")
  }
} else {
  cat("📊 Next Steps:\n")
  cat("==============\n")
  cat("1. View the generated plots in outputs/plots/\n")
  cat("2. Open interactive maps in outputs/maps/ (use your browser)\n")
  cat("3. Launch the Shiny dashboard:\n")
  cat("   library(shiny)\n")
  cat("   runApp('dashboard/app.R')\n\n")
}

cat("════════════════════════════════════════════════════════════════════\n")
cat("For questions or issues, check the README.md file.\n")
cat("════════════════════════════════════════════════════════════════════\n\n")
