# ============================================================================
# Data Import and Cleaning Script
# ============================================================================
# This script handles loading and cleaning crime data
# Supports: Chicago Crime Data, Madison PD, or custom CSV files

library(tidyverse)
library(janitor)
library(lubridate)
library(readr)

cat("================================\n")
cat("Crime Data Import & Cleaning\n")
cat("================================\n\n")

# ============================================================================
# Configuration
# ============================================================================

# Set working directory to project root if needed
# setwd("d:/Project/R/Crime report")

# Create data subdirectories if they don't exist
dir.create("data/raw", showWarnings = FALSE, recursive = TRUE)
dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)

# ============================================================================
# Option 1: Load Chicago Crime Data (from file or API)
# ============================================================================

load_chicago_data <- function(file_path = "data/raw/chicago_crimes.csv", 
                              sample_size = NULL) {
  cat("📥 Loading Chicago crime data...\n")
  
  if (file.exists(file_path)) {
    # Read from local file
    crimes <- read_csv(file_path, 
                      col_types = cols(.default = "c"),
                      show_col_types = FALSE)
    
    # Sample data if specified (for testing with large datasets)
    if (!is.null(sample_size) && nrow(crimes) > sample_size) {
      cat(paste("  Sampling", sample_size, "rows from", nrow(crimes), "total rows\n"))
      crimes <- crimes %>% sample_n(sample_size)
    }
    
  } else {
    cat("  ⚠️ File not found. You can download Chicago data from:\n")
    cat("  https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-Present/ijzp-q8t2\n\n")
    
    # Option to download using RSocrata (if package is available)
    if (require("RSocrata", quietly = TRUE)) {
      cat("  📡 Attempting to download via API (this may take a while)...\n")
      tryCatch({
        crimes <- RSocrata::read.socrata(
          "https://data.cityofchicago.org/resource/ijzp-q8t2.csv?$limit=50000"
        )
        write_csv(crimes, file_path)
        cat("  ✅ Data downloaded and saved to", file_path, "\n")
      }, error = function(e) {
        cat("  ❌ API download failed:", e$message, "\n")
        return(NULL)
      })
    } else {
      return(NULL)
    }
  }
  
  return(crimes)
}

# ============================================================================
# Option 2: Generate Sample Data (for testing)
# ============================================================================

generate_sample_data <- function(n_records = 10000) {
  cat("🔧 Generating sample crime data...\n")
  
  set.seed(123)
  
  # Generate dates spanning 3 years
  start_date <- as.Date("2021-01-01")
  end_date <- as.Date("2024-10-31")
  
  sample_data <- tibble(
    id = 1:n_records,
    date = sample(seq(start_date, end_date, by = "day"), n_records, replace = TRUE),
    primary_type = sample(c("THEFT", "BATTERY", "CRIMINAL DAMAGE", "ASSAULT", 
                           "BURGLARY", "MOTOR VEHICLE THEFT", "ROBBERY", 
                           "DECEPTIVE PRACTICE", "NARCOTICS", "OTHER OFFENSE"),
                         n_records, replace = TRUE,
                         prob = c(0.25, 0.18, 0.12, 0.10, 0.08, 0.08, 0.06, 0.05, 0.04, 0.04)),
    description = "Sample crime description",
    location_description = sample(c("STREET", "RESIDENCE", "APARTMENT", "SIDEWALK",
                                   "PARKING LOT", "RESTAURANT", "SCHOOL", "STORE"),
                                 n_records, replace = TRUE),
    arrest = sample(c(TRUE, FALSE), n_records, replace = TRUE, prob = c(0.25, 0.75)),
    domestic = sample(c(TRUE, FALSE), n_records, replace = TRUE, prob = c(0.15, 0.85)),
    latitude = runif(n_records, 41.64, 42.02),  # Chicago latitude range
    longitude = runif(n_records, -87.94, -87.52), # Chicago longitude range
    district = sample(1:25, n_records, replace = TRUE),
    ward = sample(1:50, n_records, replace = TRUE),
    year = year(date),
    month = month(date),
    day = day(date),
    hour = sample(0:23, n_records, replace = TRUE)
  )
  
  cat("  ✅ Generated", n_records, "sample records\n")
  return(sample_data)
}

# ============================================================================
# Data Cleaning Function
# ============================================================================

clean_crime_data <- function(raw_data) {
  cat("\n🧹 Cleaning crime data...\n")
  
  cleaned_data <- raw_data %>%
    # Clean column names
    clean_names()
  
  # Handle date column based on what exists
  if ("date" %in% names(cleaned_data)) {
    cleaned_data <- cleaned_data %>% mutate(date = as.Date(date))
  } else if ("occurred_date" %in% names(cleaned_data)) {
    cleaned_data <- cleaned_data %>% mutate(date = as.Date(occurred_date))
  } else if ("incident_date" %in% names(cleaned_data)) {
    cleaned_data <- cleaned_data %>% mutate(date = as.Date(incident_date))
  }
  
  cleaned_data <- cleaned_data %>%
    # Remove records with missing dates
    filter(!is.na(date)) %>%
    
    # Extract temporal features
    mutate(
      year = year(date),
      month = month(date, label = TRUE),
      month_num = month(date),
      day = day(date),
      weekday = wday(date, label = TRUE),
      quarter = quarter(date),
      year_month = floor_date(date, "month"),
      week = floor_date(date, "week")
    )
  
  # Handle crime_type column
  if ("primary_type" %in% names(cleaned_data)) {
    cleaned_data <- cleaned_data %>% mutate(crime_type = str_to_title(primary_type))
  } else if ("crime_type" %in% names(cleaned_data)) {
    cleaned_data <- cleaned_data %>% mutate(crime_type = str_to_title(crime_type))
  } else {
    cleaned_data <- cleaned_data %>% mutate(crime_type = "Unknown")
  }
  
  cleaned_data <- cleaned_data %>%
    
    # Clean location data
    mutate(
      latitude = as.numeric(latitude),
      longitude = as.numeric(longitude)
    ) %>%
    
    # Remove invalid coordinates
    filter(
      !is.na(latitude) & !is.na(longitude),
      latitude != 0 & longitude != 0,
      between(latitude, -90, 90),
      between(longitude, -180, 180)
    )
  
  # Handle arrest column
  if ("arrest" %in% names(cleaned_data)) {
    cleaned_data <- cleaned_data %>% mutate(arrest = as.logical(arrest))
  } else {
    cleaned_data <- cleaned_data %>% mutate(arrest = NA)
  }
  
  # Handle domestic column
  if ("domestic" %in% names(cleaned_data)) {
    cleaned_data <- cleaned_data %>% mutate(domestic = as.logical(domestic))
  } else {
    cleaned_data <- cleaned_data %>% mutate(domestic = NA)
  }
  
  cleaned_data <- cleaned_data
  
  cat("  📊 Original records:", nrow(raw_data), "\n")
  cat("  📊 Cleaned records:", nrow(cleaned_data), "\n")
  cat("  📊 Records removed:", nrow(raw_data) - nrow(cleaned_data), "\n")
  
  return(cleaned_data)
}

# ============================================================================
# Main Execution
# ============================================================================

cat("\n🚀 Starting data import process...\n\n")

# Try to load Chicago data first, fall back to sample data
crime_data <- load_chicago_data(sample_size = 50000)  # Limit to 50k for performance

if (is.null(crime_data)) {
  cat("\n📝 Using sample data for demonstration...\n")
  crime_data <- generate_sample_data(n_records = 10000)
}

# Clean the data
crime_data_clean <- clean_crime_data(crime_data)

# Save cleaned data
output_file <- "data/processed/crime_data_clean.csv"
write_csv(crime_data_clean, output_file)
cat("\n💾 Cleaned data saved to:", output_file, "\n")

# Display summary statistics
cat("\n📊 Data Summary:\n")
cat("================================\n")
cat("Date Range:", as.character(min(crime_data_clean$date)), "to", 
    as.character(max(crime_data_clean$date)), "\n")
cat("Total Records:", nrow(crime_data_clean), "\n")
cat("Unique Crime Types:", n_distinct(crime_data_clean$crime_type), "\n")
cat("\nTop 10 Crime Types:\n")
print(crime_data_clean %>% 
      count(crime_type, sort = TRUE) %>% 
      head(10))

cat("\nCrimes by Year:\n")
print(crime_data_clean %>% 
      count(year, sort = TRUE))

cat("\n✅ Data import and cleaning complete!\n")
cat("================================\n")

# Save to R environment for use in other scripts
save(crime_data_clean, file = "data/processed/crime_data_clean.RData")
cat("💾 Data also saved to RData format for faster loading\n\n")
