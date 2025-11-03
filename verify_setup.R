# ============================================================================
# Project Verification Script
# ============================================================================
# This script checks that all files are in place and packages can be loaded

cat("╔═══════════════════════════════════════════════════════════════════╗\n")
cat("║          Crime Analytics Project - Setup Verification            ║\n")
cat("╚═══════════════════════════════════════════════════════════════════╝\n\n")

# Initialize counters
passed <- 0
failed <- 0

# ============================================================================
# Check 1: Directory Structure
# ============================================================================

cat("✓ Checking directory structure...\n")

required_dirs <- c(
  "data",
  "data/raw",
  "data/processed",
  "scripts",
  "outputs",
  "outputs/plots",
  "outputs/maps",
  "dashboard"
)

for (dir in required_dirs) {
  if (dir.exists(dir)) {
    cat("  ✅", dir, "\n")
    passed <- passed + 1
  } else {
    cat("  ❌", dir, "- MISSING\n")
    failed <- failed + 1
  }
}

cat("\n")

# ============================================================================
# Check 2: Required Scripts
# ============================================================================

cat("✓ Checking script files...\n")

required_scripts <- c(
  "scripts/00_install_packages.R",
  "scripts/01_data_import.R",
  "scripts/02_time_series_analysis.R",
  "scripts/03_forecasting.R",
  "scripts/04_geospatial.R",
  "scripts/download_data.R",
  "dashboard/app.R",
  "run_analysis.R",
  "QUICKSTART.R",
  "README.md"
)

for (script in required_scripts) {
  if (file.exists(script)) {
    cat("  ✅", script, "\n")
    passed <- passed + 1
  } else {
    cat("  ❌", script, "- MISSING\n")
    failed <- failed + 1
  }
}

cat("\n")

# ============================================================================
# Check 3: Core Packages (Optional Check)
# ============================================================================

cat("✓ Checking core R packages...\n")
cat("  (Packages will be installed when running analysis scripts)\n\n")

core_packages <- c(
  "tidyverse",
  "forecast",
  "prophet",
  "leaflet",
  "shiny"
)

installed_count <- 0
missing_packages <- c()

for (pkg in core_packages) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    cat("  ✅", pkg, "- installed\n")
    installed_count <- installed_count + 1
    passed <- passed + 1
  } else {
    cat("  ⚠️ ", pkg, "- not installed (will be installed automatically)\n")
    missing_packages <- c(missing_packages, pkg)
  }
}

cat("\n")

if (length(missing_packages) > 0) {
  cat("  ℹ️  Missing packages will be installed when you run:\n")
  cat("     source('scripts/00_install_packages.R')\n\n")
}

# ============================================================================
# Check 4: R Version
# ============================================================================

cat("✓ Checking R version...\n")
r_version <- as.numeric(R.version$major) + as.numeric(R.version$minor) / 10

cat("  Current R version:", R.version$major, ".", R.version$minor, "\n")

if (r_version >= 4.0) {
  cat("  ✅ R version is compatible (>= 4.0)\n")
  passed <- passed + 1
} else {
  cat("  ⚠️  R version is older than 4.0. Consider updating.\n")
  cat("     Project may still work but some features might be limited.\n")
}

cat("\n")

# ============================================================================
# Check 5: Working Directory
# ============================================================================

cat("✓ Checking working directory...\n")
wd <- getwd()
cat("  Current directory:", wd, "\n")

if (grepl("Crime report", wd, ignore.case = TRUE)) {
  cat("  ✅ Working directory appears correct\n")
  passed <- passed + 1
} else {
  cat("  ⚠️  Working directory might not be the project root\n")
  cat("     Consider setting it to the 'Crime report' folder\n")
}

cat("\n")

# ============================================================================
# Check 6: Data Files (Optional)
# ============================================================================

cat("✓ Checking for data files...\n")

if (length(list.files("data/raw", pattern = "\\.csv$")) > 0) {
  cat("  ✅ CSV files found in data/raw/\n")
  cat("     Files:", paste(list.files("data/raw", pattern = "\\.csv$"), collapse = ", "), "\n")
  passed <- passed + 1
} else {
  cat("  ℹ️  No CSV files in data/raw/\n")
  cat("     Sample data will be generated automatically\n")
}

cat("\n")

# ============================================================================
# Summary
# ============================================================================

cat("═══════════════════════════════════════════════════════════════════\n")
cat("                      VERIFICATION SUMMARY\n")
cat("═══════════════════════════════════════════════════════════════════\n\n")

total <- passed + failed
success_rate <- round((passed / total) * 100, 1)

cat("Total checks:", total, "\n")
cat("Passed:", passed, "✅\n")
cat("Failed:", failed, "❌\n")
cat("Success rate:", success_rate, "%\n\n")

if (failed == 0 || success_rate >= 90) {
  cat("🎉 PROJECT SETUP VERIFIED! 🎉\n\n")
  cat("Your project is ready to use!\n\n")
  cat("Next steps:\n")
  cat("  1. Run: source('run_analysis.R')\n")
  cat("  2. Or follow QUICKSTART.R for step-by-step instructions\n\n")
} else if (success_rate >= 70) {
  cat("⚠️  PROJECT MOSTLY READY\n\n")
  cat("Some components are missing but the project should still work.\n")
  cat("Review the failed checks above and fix if needed.\n\n")
} else {
  cat("❌ PROJECT SETUP INCOMPLETE\n\n")
  cat("Several components are missing. Please:\n")
  cat("  1. Ensure you're in the correct directory\n")
  cat("  2. Check that all files were created properly\n")
  cat("  3. Re-run the project setup if needed\n\n")
}

# ============================================================================
# Quick Action Menu
# ============================================================================

if (interactive() && (failed == 0 || success_rate >= 90)) {
  cat("═══════════════════════════════════════════════════════════════════\n\n")
  cat("🚀 Would you like to start now?\n\n")
  cat("1. Yes - Run full analysis with sample data\n")
  cat("2. Download real crime data first\n")
  cat("3. Install packages only\n")
  cat("4. Show QUICKSTART guide\n")
  cat("5. Exit\n\n")
  
  choice <- readline(prompt = "Enter your choice (1-5): ")
  
  if (choice == "1") {
    cat("\n🚀 Starting full analysis...\n\n")
    Sys.sleep(1)
    source("run_analysis.R")
    
  } else if (choice == "2") {
    cat("\n📡 Opening data download helper...\n\n")
    Sys.sleep(1)
    source("scripts/download_data.R")
    
  } else if (choice == "3") {
    cat("\n📦 Installing packages...\n\n")
    Sys.sleep(1)
    source("scripts/00_install_packages.R")
    
  } else if (choice == "4") {
    cat("\n📖 Loading quick start guide...\n\n")
    Sys.sleep(1)
    source("QUICKSTART.R")
    
  } else {
    cat("\n✅ Setup verified! You're ready to begin.\n")
    cat("Run 'source(\"run_analysis.R\")' when ready.\n\n")
  }
}

cat("═══════════════════════════════════════════════════════════════════\n")
cat("For detailed documentation, see README.md and PROJECT_SUMMARY.md\n")
cat("═══════════════════════════════════════════════════════════════════\n\n")
