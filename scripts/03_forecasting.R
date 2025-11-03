# ============================================================================
# Crime Forecasting Script
# ============================================================================
# Implements ARIMA and Prophet models to forecast crime trends
# Generates 6-month forecasts with confidence intervals

library(tidyverse)
library(lubridate)
library(forecast)
library(prophet)
library(scales)
# library(tsibble)  # Not needed for this analysis

cat("================================\n")
cat("Crime Forecasting Models\n")
cat("================================\n\n")

# ============================================================================
# Load Data
# ============================================================================

cat("📥 Loading time-series data...\n")

if (file.exists("data/processed/timeseries_data.RData")) {
  load("data/processed/timeseries_data.RData")
} else {
  stop("❌ Time-series data not found. Please run 02_time_series_analysis.R first.")
}

cat("  ✅ Loaded monthly crime data\n\n")

# ============================================================================
# Prepare Data for Forecasting
# ============================================================================

cat("📊 Preparing data for forecasting...\n")

# Convert to time series object for ARIMA
ts_data <- ts(monthly_crimes$crime_count, 
              start = c(year(min(monthly_crimes$year_month)), 
                       month(min(monthly_crimes$year_month))),
              frequency = 12)

cat("  Time series period:", start(ts_data), "to", end(ts_data), "\n")
cat("  Total observations:", length(ts_data), "\n\n")

# ============================================================================
# Model 1: ARIMA Forecasting
# ============================================================================

cat("🔮 Building ARIMA model...\n")

# Automatic ARIMA model selection
arima_model <- auto.arima(ts_data,
                          seasonal = TRUE,
                          stepwise = TRUE,
                          approximation = FALSE,
                          trace = FALSE)

cat("  ARIMA Model:", capture.output(arima_model)[1], "\n")

# Generate 6-month forecast
forecast_horizon <- 6
arima_forecast <- forecast(arima_model, h = forecast_horizon)

cat("  ✅ Generated", forecast_horizon, "month forecast\n")

# Extract forecast results
arima_results <- data.frame(
  date = seq(max(monthly_crimes$year_month) + months(1), 
             by = "month", 
             length.out = forecast_horizon),
  forecast = as.numeric(arima_forecast$mean),
  lower_80 = as.numeric(arima_forecast$lower[, 1]),
  upper_80 = as.numeric(arima_forecast$upper[, 1]),
  lower_95 = as.numeric(arima_forecast$lower[, 2]),
  upper_95 = as.numeric(arima_forecast$upper[, 2]),
  model = "ARIMA"
)

# Plot ARIMA forecast
p_arima <- autoplot(arima_forecast) +
  labs(
    title = "ARIMA Crime Forecast (6 Months)",
    subtitle = paste("Model:", capture.output(arima_model)[1]),
    x = "Time",
    y = "Number of Crimes"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 11, color = "gray40"),
    axis.title = element_text(size = 12, face = "bold")
  )

ggsave("outputs/plots/08_arima_forecast.png", p_arima, width = 12, height = 6, dpi = 300)
cat("  ✅ Saved: outputs/plots/08_arima_forecast.png\n\n")

# Model diagnostics
cat("  Model Diagnostics:\n")
cat("    AIC:", round(AIC(arima_model), 2), "\n")
cat("    BIC:", round(BIC(arima_model), 2), "\n")
accuracy_arima <- accuracy(arima_model)
cat("    RMSE:", round(accuracy_arima[, "RMSE"], 2), "\n")
cat("    MAPE:", round(accuracy_arima[, "MAPE"], 2), "%\n\n")

# ============================================================================
# Model 2: Facebook Prophet
# ============================================================================

cat("🔮 Building Prophet model...\n")

# Prepare data for Prophet (requires 'ds' and 'y' columns)
prophet_data <- monthly_crimes %>%
  select(ds = year_month, y = crime_count)

# Build Prophet model
prophet_model <- prophet(prophet_data,
                        yearly.seasonality = TRUE,
                        weekly.seasonality = FALSE,
                        daily.seasonality = FALSE,
                        seasonality.mode = 'multiplicative')

cat("  ✅ Model trained successfully\n")

# Create future dataframe
future <- make_future_dataframe(prophet_model, 
                               periods = forecast_horizon, 
                               freq = 'month')

# Generate forecast
prophet_forecast <- predict(prophet_model, future)

cat("  ✅ Generated", forecast_horizon, "month forecast\n")

# Extract forecast results for new months only
prophet_results <- prophet_forecast %>%
  tail(forecast_horizon) %>%
  select(date = ds, forecast = yhat, lower_80 = yhat_lower, upper_80 = yhat_upper) %>%
  mutate(
    lower_95 = forecast - 1.96 * (upper_80 - forecast) / 1.28,
    upper_95 = forecast + 1.96 * (upper_80 - forecast) / 1.28,
    model = "Prophet"
  )

# Plot Prophet forecast
p_prophet <- plot(prophet_model, prophet_forecast) +
  labs(
    title = "Prophet Crime Forecast (6 Months)",
    subtitle = "Black dots: Historical data | Blue line: Forecast | Shaded area: Uncertainty interval",
    x = "Date",
    y = "Number of Crimes"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 11, color = "gray40"),
    axis.title = element_text(size = 12, face = "bold")
  )

ggsave("outputs/plots/09_prophet_forecast.png", p_prophet, width = 12, height = 6, dpi = 300)
cat("  ✅ Saved: outputs/plots/09_prophet_forecast.png\n")

# Plot Prophet components
p_prophet_components <- prophet_plot_components(prophet_model, prophet_forecast)
ggsave("outputs/plots/10_prophet_components.png", p_prophet_components, width = 12, height = 8, dpi = 300)
cat("  ✅ Saved: outputs/plots/10_prophet_components.png\n\n")

# ============================================================================
# Compare Models
# ============================================================================

cat("📊 Comparing model forecasts...\n")

# Combine forecasts
all_forecasts <- bind_rows(arima_results, prophet_results)

# Create comparison plot
historical_data <- monthly_crimes %>%
  mutate(model = "Historical") %>%
  select(date = year_month, forecast = crime_count, model)

comparison_plot <- ggplot() +
  # Historical data
  geom_line(data = historical_data, 
            aes(x = date, y = forecast), 
            color = "black", size = 1) +
  # ARIMA forecast
  geom_line(data = filter(all_forecasts, model == "ARIMA"),
            aes(x = date, y = forecast, color = "ARIMA"), 
            size = 1.2) +
  geom_ribbon(data = filter(all_forecasts, model == "ARIMA"),
              aes(x = date, ymin = lower_80, ymax = upper_80),
              alpha = 0.2, fill = "#E74C3C") +
  # Prophet forecast
  geom_line(data = filter(all_forecasts, model == "Prophet"),
            aes(x = date, y = forecast, color = "Prophet"), 
            size = 1.2) +
  geom_ribbon(data = filter(all_forecasts, model == "Prophet"),
              aes(x = date, ymin = lower_80, ymax = upper_80),
              alpha = 0.2, fill = "#3498DB") +
  scale_color_manual(values = c("ARIMA" = "#E74C3C", "Prophet" = "#3498DB")) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Comparison: ARIMA vs Prophet Forecasts",
    subtitle = "6-month crime forecast with 80% confidence intervals",
    x = "Date",
    y = "Number of Crimes",
    color = "Model"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12, color = "gray40"),
    axis.title = element_text(size = 12, face = "bold"),
    legend.position = "top"
  )

ggsave("outputs/plots/11_model_comparison.png", comparison_plot, width = 12, height = 6, dpi = 300)
cat("  ✅ Saved: outputs/plots/11_model_comparison.png\n\n")

# ============================================================================
# Forecast Summary
# ============================================================================

cat("📈 6-Month Forecast Summary:\n")
cat("================================\n\n")

cat("ARIMA Forecasts:\n")
arima_summary <- arima_results %>%
  mutate(
    date = format(date, "%b %Y"),
    forecast = comma(round(forecast)),
    ci_80 = paste0("[", comma(round(lower_80)), " - ", comma(round(upper_80)), "]")
  ) %>%
  select(Month = date, Forecast = forecast, `80% CI` = ci_80)
print(arima_summary, row.names = FALSE)

cat("\n\nProphet Forecasts:\n")
prophet_summary <- prophet_results %>%
  mutate(
    date = format(date, "%b %Y"),
    forecast = comma(round(forecast)),
    ci_80 = paste0("[", comma(round(lower_80)), " - ", comma(round(upper_80)), "]")
  ) %>%
  select(Month = date, Forecast = forecast, `80% CI` = ci_80)
print(prophet_summary, row.names = FALSE)

# Calculate total forecast
total_arima <- sum(arima_results$forecast)
total_prophet <- sum(prophet_results$forecast)

cat("\n\nTotal Forecasted Crimes (6 months):\n")
cat("  ARIMA:", comma(round(total_arima)), "\n")
cat("  Prophet:", comma(round(total_prophet)), "\n")
cat("  Difference:", comma(round(abs(total_arima - total_prophet))), "\n\n")

# ============================================================================
# Export Forecasts
# ============================================================================

cat("💾 Saving forecast results...\n")

# Save forecasts
write_csv(arima_results, "outputs/arima_forecast.csv")
write_csv(prophet_results, "outputs/prophet_forecast.csv")

# Save models and forecasts to RData
save(arima_model, arima_forecast, arima_results,
     prophet_model, prophet_forecast, prophet_results,
     file = "data/processed/forecast_models.RData")

cat("  ✅ ARIMA forecast: outputs/arima_forecast.csv\n")
cat("  ✅ Prophet forecast: outputs/prophet_forecast.csv\n")
cat("  ✅ Models saved: data/processed/forecast_models.RData\n")

cat("\n✅ Forecasting complete!\n")
cat("================================\n")

# ============================================================================
# Additional Analysis: Trend Decomposition
# ============================================================================

cat("\n📊 Performing trend decomposition...\n")

# Decompose time series
decomp <- decompose(ts_data, type = "multiplicative")

# Plot decomposition
png("outputs/plots/12_trend_decomposition.png", width = 12, height = 8, units = "in", res = 300)
plot(decomp, col = "#2C3E50", lwd = 2)
dev.off()

cat("  ✅ Saved: outputs/plots/12_trend_decomposition.png\n")

cat("\n✨ All forecasting analysis complete!\n")
