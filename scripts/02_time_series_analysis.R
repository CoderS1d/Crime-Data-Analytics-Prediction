# ============================================================================
# Time-Series Analysis Script
# ============================================================================
# Analyzes temporal patterns and trends in crime data
# Includes: trend analysis, seasonality, patterns by time period

library(tidyverse)
library(lubridate)
library(scales)
# library(tsibble)  # Optional - not required for basic analysis
# library(feasts)   # Optional - not required for basic analysis

cat("================================\n")
cat("Time-Series Analysis\n")
cat("================================\n\n")

# ============================================================================
# Load Cleaned Data
# ============================================================================

cat("📥 Loading cleaned crime data...\n")

# Load from RData (faster) or CSV
if (file.exists("data/processed/crime_data_clean.RData")) {
  load("data/processed/crime_data_clean.RData")
} else if (file.exists("data/processed/crime_data_clean.csv")) {
  crime_data_clean <- read_csv("data/processed/crime_data_clean.csv")
} else {
  stop("❌ Cleaned data not found. Please run 01_data_import.R first.")
}

cat("  ✅ Loaded", nrow(crime_data_clean), "records\n\n")

# ============================================================================
# 1. Monthly Crime Trends
# ============================================================================

cat("📈 Analyzing monthly trends...\n")

# Aggregate by month
monthly_crimes <- crime_data_clean %>%
  group_by(year_month) %>%
  summarise(
    crime_count = n(),
    arrest_rate = mean(arrest, na.rm = TRUE) * 100,
    .groups = 'drop'
  ) %>%
  arrange(year_month)

# Create monthly trend plot
p1 <- ggplot(monthly_crimes, aes(x = year_month, y = crime_count)) +
  geom_line(color = "#2C3E50", size = 1.2) +
  geom_smooth(method = "loess", se = TRUE, color = "#E74C3C", linetype = "dashed") +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Monthly Crime Trends Over Time",
    subtitle = paste("Period:", min(monthly_crimes$year_month), "to", max(monthly_crimes$year_month)),
    x = "Month",
    y = "Number of Crimes",
    caption = "Red dashed line shows the overall trend"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12, color = "gray40"),
    axis.title = element_text(size = 12, face = "bold")
  )

ggsave("outputs/plots/01_monthly_trends.png", p1, width = 12, height = 6, dpi = 300)
cat("  ✅ Saved: outputs/plots/01_monthly_trends.png\n")

# ============================================================================
# 2. Yearly Crime Trends
# ============================================================================

cat("📊 Analyzing yearly trends...\n")

yearly_crimes <- crime_data_clean %>%
  group_by(year) %>%
  summarise(
    crime_count = n(),
    arrest_rate = mean(arrest, na.rm = TRUE) * 100,
    .groups = 'drop'
  )

p2 <- ggplot(yearly_crimes, aes(x = factor(year), y = crime_count)) +
  geom_col(fill = "#3498DB", alpha = 0.8) +
  geom_text(aes(label = comma(crime_count)), vjust = -0.5, size = 4) +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "Total Crimes by Year",
    x = "Year",
    y = "Number of Crimes"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    axis.title = element_text(size = 12, face = "bold")
  )

ggsave("outputs/plots/02_yearly_trends.png", p2, width = 10, height = 6, dpi = 300)
cat("  ✅ Saved: outputs/plots/02_yearly_trends.png\n")

# ============================================================================
# 3. Seasonal Patterns (by Month of Year)
# ============================================================================

cat("🍂 Analyzing seasonal patterns...\n")

seasonal_crimes <- crime_data_clean %>%
  group_by(month) %>%
  summarise(
    avg_crimes = n() / n_distinct(crime_data_clean$year),
    total_crimes = n(),
    .groups = 'drop'
  ) %>%
  mutate(month = factor(month, levels = month.abb))

p3 <- ggplot(seasonal_crimes, aes(x = month, y = avg_crimes, group = 1)) +
  geom_line(color = "#E67E22", size = 1.5) +
  geom_point(color = "#E67E22", size = 3) +
  geom_area(alpha = 0.3, fill = "#E67E22") +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Average Monthly Crime Patterns (Seasonality)",
    subtitle = "Average crimes per month across all years",
    x = "Month",
    y = "Average Number of Crimes"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12, color = "gray40"),
    axis.title = element_text(size = 12, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave("outputs/plots/03_seasonal_patterns.png", p3, width = 10, height = 6, dpi = 300)
cat("  ✅ Saved: outputs/plots/03_seasonal_patterns.png\n")

# ============================================================================
# 4. Day of Week Patterns
# ============================================================================

cat("📅 Analyzing day-of-week patterns...\n")

weekday_crimes <- crime_data_clean %>%
  group_by(weekday) %>%
  summarise(
    crime_count = n(),
    .groups = 'drop'
  ) %>%
  mutate(
    weekday = factor(weekday, levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")),
    weekend = ifelse(weekday %in% c("Sat", "Sun"), "Weekend", "Weekday")
  )

p4 <- ggplot(weekday_crimes, aes(x = weekday, y = crime_count, fill = weekend)) +
  geom_col(alpha = 0.8) +
  scale_fill_manual(values = c("Weekday" = "#3498DB", "Weekend" = "#E74C3C")) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Crime Distribution by Day of Week",
    x = "Day of Week",
    y = "Number of Crimes",
    fill = "Period"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    axis.title = element_text(size = 12, face = "bold"),
    legend.position = "top"
  )

ggsave("outputs/plots/04_weekday_patterns.png", p4, width = 10, height = 6, dpi = 300)
cat("  ✅ Saved: outputs/plots/04_weekday_patterns.png\n")

# ============================================================================
# 5. Hourly Patterns (if hour data available)
# ============================================================================

if ("hour" %in% names(crime_data_clean)) {
  cat("⏰ Analyzing hourly patterns...\n")
  
  hourly_crimes <- crime_data_clean %>%
    group_by(hour) %>%
    summarise(
      crime_count = n(),
      .groups = 'drop'
    )
  
  p5 <- ggplot(hourly_crimes, aes(x = hour, y = crime_count)) +
    geom_line(color = "#9B59B6", size = 1.5) +
    geom_point(color = "#9B59B6", size = 3) +
    scale_x_continuous(breaks = seq(0, 23, 2)) +
    scale_y_continuous(labels = comma) +
    labs(
      title = "Crime Distribution by Hour of Day",
      subtitle = "24-hour pattern showing peak crime hours",
      x = "Hour of Day (0-23)",
      y = "Number of Crimes"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold"),
      plot.subtitle = element_text(size = 12, color = "gray40"),
      axis.title = element_text(size = 12, face = "bold")
    )
  
  ggsave("outputs/plots/05_hourly_patterns.png", p5, width = 10, height = 6, dpi = 300)
  cat("  ✅ Saved: outputs/plots/05_hourly_patterns.png\n")
}

# ============================================================================
# 6. Crime Type Trends Over Time
# ============================================================================

cat("🔍 Analyzing crime type trends...\n")

# Get top 5 crime types
top_crimes <- crime_data_clean %>%
  count(crime_type, sort = TRUE) %>%
  head(5) %>%
  pull(crime_type)

crime_type_trends <- crime_data_clean %>%
  filter(crime_type %in% top_crimes) %>%
  group_by(year_month, crime_type) %>%
  summarise(crime_count = n(), .groups = 'drop')

p6 <- ggplot(crime_type_trends, aes(x = year_month, y = crime_count, color = crime_type)) +
  geom_line(size = 1.2) +
  scale_y_continuous(labels = comma) +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "Top 5 Crime Types: Trends Over Time",
    x = "Month",
    y = "Number of Crimes",
    color = "Crime Type"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    axis.title = element_text(size = 12, face = "bold"),
    legend.position = "bottom"
  )

ggsave("outputs/plots/06_crime_type_trends.png", p6, width = 12, height = 6, dpi = 300)
cat("  ✅ Saved: outputs/plots/06_crime_type_trends.png\n")

# ============================================================================
# 7. Heatmap: Month vs Year
# ============================================================================

cat("🔥 Creating temporal heatmap...\n")

heatmap_data <- crime_data_clean %>%
  group_by(year, month) %>%
  summarise(crime_count = n(), .groups = 'drop') %>%
  mutate(month = factor(month, levels = month.abb))

p7 <- ggplot(heatmap_data, aes(x = month, y = factor(year), fill = crime_count)) +
  geom_tile(color = "white", size = 0.5) +
  scale_fill_viridis_c(option = "plasma", labels = comma) +
  labs(
    title = "Crime Heatmap: Year vs Month",
    subtitle = "Darker colors indicate higher crime counts",
    x = "Month",
    y = "Year",
    fill = "Crime Count"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12, color = "gray40"),
    axis.title = element_text(size = 12, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "right"
  )

ggsave("outputs/plots/07_temporal_heatmap.png", p7, width = 12, height = 8, dpi = 300)
cat("  ✅ Saved: outputs/plots/07_temporal_heatmap.png\n")

# ============================================================================
# 8. Summary Statistics
# ============================================================================

cat("\n📊 Time-Series Summary Statistics:\n")
cat("================================\n")

# Overall statistics
total_crimes <- nrow(crime_data_clean)
date_range <- max(crime_data_clean$date) - min(crime_data_clean$date)
avg_daily <- total_crimes / as.numeric(date_range)

cat("Total Crimes:", comma(total_crimes), "\n")
cat("Date Range:", as.character(min(crime_data_clean$date)), "to", 
    as.character(max(crime_data_clean$date)), "\n")
cat("Days Covered:", as.numeric(date_range), "\n")
cat("Average Daily Crimes:", round(avg_daily, 2), "\n\n")

# Monthly statistics
cat("Monthly Statistics:\n")
cat("  Average:", round(mean(monthly_crimes$crime_count), 2), "crimes/month\n")
cat("  Median:", round(median(monthly_crimes$crime_count), 2), "crimes/month\n")
cat("  Min:", min(monthly_crimes$crime_count), "crimes/month\n")
cat("  Max:", max(monthly_crimes$crime_count), "crimes/month\n\n")

# Peak periods
peak_month <- seasonal_crimes %>% slice_max(avg_crimes, n = 1)
low_month <- seasonal_crimes %>% slice_min(avg_crimes, n = 1)

cat("Peak Crime Month:", as.character(peak_month$month), 
    "(", round(peak_month$avg_crimes, 2), "avg crimes)\n")
cat("Lowest Crime Month:", as.character(low_month$month), 
    "(", round(low_month$avg_crimes, 2), "avg crimes)\n\n")

# Day of week
peak_day <- weekday_crimes %>% slice_max(crime_count, n = 1)
low_day <- weekday_crimes %>% slice_min(crime_count, n = 1)

cat("Peak Crime Day:", as.character(peak_day$weekday), 
    "(", comma(peak_day$crime_count), "crimes)\n")
cat("Lowest Crime Day:", as.character(low_day$weekday), 
    "(", comma(low_day$crime_count), "crimes)\n\n")

# Save processed time-series data
save(monthly_crimes, yearly_crimes, seasonal_crimes, weekday_crimes,
     file = "data/processed/timeseries_data.RData")
cat("💾 Time-series data saved to: data/processed/timeseries_data.RData\n")

cat("\n✅ Time-series analysis complete!\n")
cat("================================\n")
