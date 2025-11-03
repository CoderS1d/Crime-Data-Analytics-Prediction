# Crime Analytics - Usage Examples & Tips

This document provides practical examples and tips for using the Crime Analytics project.

---

## 🚀 Getting Started

### First Time Setup

```r
# Option 1: Verify everything is set up correctly
source("verify_setup.R")

# Option 2: Follow the quick start guide
source("QUICKSTART.R")

# Option 3: Jump straight into analysis
source("run_analysis.R")
```

---

## 📊 Common Use Cases

### 1. Analyze Your City's Crime Data

```r
# Step 1: Download your city's crime data
# Place the CSV file in: data/raw/my_city_crimes.csv

# Step 2: Modify the data import script
# Open: scripts/01_data_import.R
# Change line ~50 to point to your file:
crime_data <- load_chicago_data(file_path = "data/raw/my_city_crimes.csv")

# Step 3: Run the analysis
source("run_analysis.R")
```

### 2. Focus on Specific Crime Types

```r
# Load the cleaned data
load("data/processed/crime_data_clean.RData")

# Filter for specific crime types
violent_crimes <- crime_data_clean %>%
  filter(crime_type %in% c("ASSAULT", "BATTERY", "ROBBERY", "HOMICIDE"))

# Save filtered data
save(violent_crimes, file = "data/processed/violent_crimes.RData")

# Now modify scripts to use violent_crimes instead of crime_data_clean
```

### 3. Analyze a Specific Time Period

```r
library(tidyverse)
library(lubridate)

# Load data
load("data/processed/crime_data_clean.RData")

# Filter for 2023 only
crimes_2023 <- crime_data_clean %>%
  filter(year == 2023)

# Or last 6 months
recent_crimes <- crime_data_clean %>%
  filter(date >= today() - months(6))

# Run time-series analysis on filtered data
# Modify scripts to use crimes_2023 or recent_crimes
```

### 4. Create Custom Visualizations

```r
library(tidyverse)
library(ggplot2)

# Load data
load("data/processed/crime_data_clean.RData")

# Custom plot: Crime by hour and day of week
crime_data_clean %>%
  filter(!is.na(hour)) %>%
  group_by(hour, weekday) %>%
  summarise(count = n(), .groups = 'drop') %>%
  ggplot(aes(x = hour, y = weekday, fill = count)) +
  geom_tile() +
  scale_fill_viridis_c() +
  labs(title = "Crime Patterns: Hour vs Day of Week",
       x = "Hour of Day", y = "Day of Week", fill = "Crime Count") +
  theme_minimal()

# Save
ggsave("outputs/plots/custom_hourly_weekly.png", width = 12, height = 6, dpi = 300)
```

### 5. Customize the Dashboard

```r
# Open dashboard/app.R and customize:

# Change color scheme
# Line ~370: Change "Set1" to "Dark2" or other palette

# Add new filters
# In sidebar section, add:
sliderInput("crimeThreshold",
            "Min Crimes to Show:",
            min = 1, max = 100, value = 10)

# Modify date range default
# Line ~80: Change start and end dates
```

---

## 🔧 Advanced Techniques

### 1. Compare Different Forecasting Models

```r
library(forecast)
library(prophet)

# Load time-series data
load("data/processed/timeseries_data.RData")

# Create time series
ts_data <- ts(monthly_crimes$crime_count, frequency = 12)

# Try different ARIMA models
model1 <- auto.arima(ts_data)
model2 <- arima(ts_data, order = c(1,1,1), seasonal = c(1,1,1))
model3 <- arima(ts_data, order = c(2,1,2), seasonal = c(1,0,1))

# Compare AIC
AIC(model1)
AIC(model2)
AIC(model3)

# Use the best model for forecasting
best_model <- model1
forecast_result <- forecast(best_model, h = 6)
plot(forecast_result)
```

### 2. Spatial Clustering Analysis

```r
library(sf)
library(dbscan)

# Load geospatial data
load("data/processed/geospatial_data.RData")

# Prepare coordinates
coords <- crime_geo %>%
  select(longitude, latitude) %>%
  as.matrix()

# Run DBSCAN clustering
clusters <- dbscan(coords, eps = 0.01, minPts = 10)

# Add clusters to data
crime_geo$cluster <- clusters$cluster

# Visualize clusters
library(ggplot2)
ggplot(crime_geo, aes(x = longitude, y = latitude, color = factor(cluster))) +
  geom_point(alpha = 0.3) +
  theme_minimal() +
  labs(title = "Crime Clusters (DBSCAN)", color = "Cluster")
```

### 3. Export Results for Presentations

```r
# Create a summary report
library(tidyverse)

# Load all data
load("data/processed/crime_data_clean.RData")
load("data/processed/timeseries_data.RData")
load("data/processed/forecast_models.RData")

# Generate summary statistics
summary_stats <- list(
  total_crimes = nrow(crime_data_clean),
  date_range = paste(min(crime_data_clean$date), "to", max(crime_data_clean$date)),
  most_common_crime = names(sort(table(crime_data_clean$crime_type), decreasing = TRUE)[1]),
  arrest_rate = mean(crime_data_clean$arrest, na.rm = TRUE) * 100,
  next_month_forecast = round(arima_results$forecast[1])
)

# Save to JSON
library(jsonlite)
write_json(summary_stats, "outputs/summary_statistics.json", pretty = TRUE)

# Create a markdown report
sink("outputs/REPORT.md")
cat("# Crime Analysis Report\n\n")
cat("## Summary Statistics\n\n")
cat("- **Total Crimes**: ", summary_stats$total_crimes, "\n")
cat("- **Date Range**: ", summary_stats$date_range, "\n")
cat("- **Most Common Crime**: ", summary_stats$most_common_crime, "\n")
cat("- **Arrest Rate**: ", round(summary_stats$arrest_rate, 1), "%\n")
cat("- **Next Month Forecast**: ", summary_stats$next_month_forecast, " crimes\n")
sink()
```

### 4. Integrate with External Data

```r
# Example: Add weather data correlation
library(tidyverse)
library(lubridate)

# Load crime data
load("data/processed/crime_data_clean.RData")

# Create dummy weather data (replace with real data)
weather_data <- tibble(
  date = seq(min(crime_data_clean$date), max(crime_data_clean$date), by = "day"),
  temperature = rnorm(length(date), mean = 15, sd = 10),
  precipitation = rbinom(length(date), 1, 0.3)
)

# Aggregate crimes by day
daily_crimes <- crime_data_clean %>%
  group_by(date) %>%
  summarise(crime_count = n())

# Join with weather
crime_weather <- daily_crimes %>%
  left_join(weather_data, by = "date")

# Analyze correlation
cor(crime_weather$crime_count, crime_weather$temperature, use = "complete.obs")

# Plot relationship
ggplot(crime_weather, aes(x = temperature, y = crime_count)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm") +
  labs(title = "Crime Count vs Temperature", x = "Temperature (°C)", y = "Crime Count") +
  theme_minimal()
```

---

## 💡 Pro Tips

### Performance Optimization

```r
# Tip 1: Sample large datasets
crime_sample <- crime_data_clean %>%
  sample_frac(0.1)  # Use 10% of data

# Tip 2: Use data.table for large files
library(data.table)
crime_dt <- fread("data/raw/large_crime_file.csv")

# Tip 3: Save intermediate results
save(processed_data, file = "data/processed/intermediate.RData")

# Tip 4: Use parallel processing
library(parallel)
num_cores <- detectCores() - 1
cl <- makeCluster(num_cores)
# ... parallel operations ...
stopCluster(cl)
```

### Visualization Best Practices

```r
# Use consistent color schemes
library(viridis)

# High-quality exports
ggsave("plot.png", width = 12, height = 8, dpi = 300)

# Interactive plots for exploration
library(plotly)
p <- ggplot(data, aes(x, y)) + geom_point()
ggplotly(p)

# Publication-ready theme
library(ggthemes)
ggplot(data, aes(x, y)) +
  geom_line() +
  theme_economist() +
  scale_color_economist()
```

### Dashboard Enhancements

```r
# Add download buttons
downloadButton("downloadPlot", "Download Plot")

# Add progress indicators
withProgress(message = 'Loading data...', {
  # ... code ...
  incProgress(0.5, detail = "Processing...")
  # ... more code ...
})

# Add reactive values for better performance
values <- reactiveValues(data = NULL, filtered = NULL)
```

---

## 🎓 Learning Exercises

### Exercise 1: Compare Two Cities
Download crime data from two different cities and compare their patterns.

### Exercise 2: Predict Crime Types
Build a classification model to predict crime type based on location and time.

### Exercise 3: Optimize Police Patrols
Use hotspot analysis to suggest optimal patrol routes.

### Exercise 4: Social Media Integration
Scrape Twitter for crime mentions and compare with official data.

### Exercise 5: Real-Time Dashboard
Connect to a live API and update the dashboard in real-time.

---

## 📚 Additional Resources

### R Packages Documentation
- tidyverse: https://www.tidyverse.org/
- forecast: https://pkg.robjhyndman.com/forecast/
- prophet: https://facebook.github.io/prophet/
- leaflet: https://rstudio.github.io/leaflet/
- shiny: https://shiny.rstudio.com/

### Crime Data Sources
- Chicago: https://data.cityofchicago.org/
- Los Angeles: https://data.lacity.org/
- New York: https://data.cityofnewyork.us/
- FBI UCR: https://crime-data-explorer.fr.cloud.gov/

### Learning Resources
- R for Data Science: https://r4ds.had.co.nz/
- Forecasting: Principles and Practice: https://otexts.com/fpp3/
- Geocomputation with R: https://geocompr.robinlovelace.net/

---

## 🐛 Troubleshooting Guide

### Issue: "Package not found"
```r
# Solution: Install manually
install.packages("package_name")

# Or use install helper
source("scripts/00_install_packages.R")
```

### Issue: "Cannot open file"
```r
# Solution: Check working directory
getwd()
setwd("path/to/Crime report")

# Or use absolute paths
read_csv("d:/Project/R/Crime report/data/file.csv")
```

### Issue: "Out of memory"
```r
# Solution: Use sampling
crime_data_clean <- crime_data_clean %>% sample_frac(0.1)

# Or increase memory limit (Windows)
memory.limit(size = 8000)
```

### Issue: "Plot not displaying"
```r
# Solution: Save to file instead
ggsave("output.png", plot_object, width = 10, height = 6)

# Or use print()
print(plot_object)
```

### Issue: "Dashboard crashes"
```r
# Solution: Reduce data size in dashboard
data_sample <- crime_data_clean %>% sample_n(1000)

# Or use pagination
options = list(pageLength = 25)
```

---

## 📞 Getting Help

1. **Check Documentation**: README.md, PROJECT_SUMMARY.md
2. **Run Verification**: `source("verify_setup.R")`
3. **Review Error Messages**: Read carefully for clues
4. **Search Online**: Stack Overflow, R community
5. **Check Package Docs**: `?function_name` or `help(package_name)`

---

**Happy Analyzing! 📊🔍**
