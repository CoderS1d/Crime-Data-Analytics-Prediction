# ============================================================================
# Quick Test Run - Minimal Dependencies
# ============================================================================
# This script runs a quick test with minimal packages

cat("\n🚀 Running Quick Test with Sample Data...\n\n")

# Set CRAN mirror
options(repos = c(CRAN = "https://cran.r-project.org/"))

# Check and install only essential packages
essential_packages <- c("dplyr", "ggplot2", "lubridate", "readr")

for (pkg in essential_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("Installing", pkg, "...\n")
    install.packages(pkg, quiet = TRUE)
    library(pkg, character.only = TRUE)
  }
}

library(dplyr)
library(ggplot2)
library(lubridate)
library(readr)

cat("\n✅ Essential packages loaded\n\n")

# Create directories
dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)
dir.create("outputs/plots", showWarnings = FALSE, recursive = TRUE)

# Generate sample data
cat("📊 Generating sample crime data...\n")
set.seed(123)

n_records <- 5000
start_date <- as.Date("2022-01-01")
end_date <- as.Date("2024-10-31")

crime_data <- data.frame(
  id = 1:n_records,
  date = sample(seq(start_date, end_date, by = "day"), n_records, replace = TRUE),
  crime_type = sample(c("THEFT", "BATTERY", "ASSAULT", "BURGLARY", "ROBBERY"),
                     n_records, replace = TRUE,
                     prob = c(0.35, 0.25, 0.15, 0.15, 0.10)),
  latitude = runif(n_records, 41.64, 42.02),
  longitude = runif(n_records, -87.94, -87.52),
  arrest = sample(c(TRUE, FALSE), n_records, replace = TRUE, prob = c(0.25, 0.75)),
  stringsAsFactors = FALSE
)

# Add temporal features
crime_data <- crime_data %>%
  mutate(
    year = year(date),
    month = month(date, label = TRUE),
    month_num = month(date),
    weekday = wday(date, label = TRUE),
    year_month = floor_date(date, "month")
  )

cat("  ✅ Generated", nrow(crime_data), "records\n\n")

# Save data
write_csv(crime_data, "data/processed/crime_data_clean.csv")
cat("💾 Saved to: data/processed/crime_data_clean.csv\n\n")

# Create a simple visualization
cat("📈 Creating visualizations...\n")

# Monthly trends
monthly <- crime_data %>%
  group_by(year_month) %>%
  summarise(count = n(), .groups = 'drop')

p1 <- ggplot(monthly, aes(x = year_month, y = count)) +
  geom_line(color = "#2C3E50", size = 1.2) +
  geom_point(color = "#2C3E50", size = 2) +
  labs(title = "Monthly Crime Trends",
       x = "Month", y = "Number of Crimes") +
  theme_minimal() +
  theme(plot.title = element_text(size = 16, face = "bold"))

ggsave("outputs/plots/test_monthly_trends.png", p1, width = 10, height = 6, dpi = 300)
cat("  ✅ Saved: outputs/plots/test_monthly_trends.png\n")

# Crime type distribution
p2 <- crime_data %>%
  count(crime_type) %>%
  ggplot(aes(x = reorder(crime_type, -n), y = n, fill = crime_type)) +
  geom_col() +
  labs(title = "Crime Type Distribution",
       x = "Crime Type", y = "Count") +
  theme_minimal() +
  theme(plot.title = element_text(size = 16, face = "bold"),
        legend.position = "none")

ggsave("outputs/plots/test_crime_types.png", p2, width = 10, height = 6, dpi = 300)
cat("  ✅ Saved: outputs/plots/test_crime_types.png\n")

# Summary statistics
cat("\n📊 Summary Statistics:\n")
cat("======================\n")
cat("Total crimes:", nrow(crime_data), "\n")
cat("Date range:", as.character(min(crime_data$date)), "to", as.character(max(crime_data$date)), "\n")
cat("Crime types:", paste(unique(crime_data$crime_type), collapse = ", "), "\n")
cat("Arrest rate:", round(mean(crime_data$arrest) * 100, 1), "%\n")

cat("\nTop 5 Crime Types:\n")
print(crime_data %>% count(crime_type, sort = TRUE) %>% head(5))

cat("\n✅ Quick test complete!\n")
cat("\nNext: Run full analysis with: source('run_analysis.R')\n")
cat("(Wait for all packages to finish installing first)\n\n")
