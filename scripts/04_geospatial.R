# ============================================================================
# Geospatial Analysis & Visualization Script
# ============================================================================
# Creates crime heatmaps, hotspot analysis, and interactive maps
# Uses ggmap, leaflet, and sf packages

library(tidyverse)
library(sf)
library(leaflet)
library(leaflet.extras)
library(viridis)
library(RColorBrewer)
library(htmlwidgets)
library(scales)

cat("================================\n")
cat("Geospatial Crime Analysis\n")
cat("================================\n\n")

# ============================================================================
# Load Cleaned Data
# ============================================================================

cat("📥 Loading cleaned crime data...\n")

if (file.exists("data/processed/crime_data_clean.RData")) {
  load("data/processed/crime_data_clean.RData")
} else if (file.exists("data/processed/crime_data_clean.csv")) {
  crime_data_clean <- read_csv("data/processed/crime_data_clean.csv")
} else {
  stop("❌ Cleaned data not found. Please run 01_data_import.R first.")
}

# Filter out invalid coordinates
crime_geo <- crime_data_clean %>%
  filter(!is.na(latitude) & !is.na(longitude)) %>%
  filter(latitude != 0 & longitude != 0)

cat("  ✅ Loaded", nrow(crime_geo), "records with valid coordinates\n\n")

# ============================================================================
# 1. Basic Crime Density Map (Static)
# ============================================================================

cat("🗺️ Creating static density map...\n")

# Calculate center point
center_lat <- median(crime_geo$latitude)
center_lon <- median(crime_geo$longitude)

# Create basic plot
p_density <- ggplot(crime_geo, aes(x = longitude, y = latitude)) +
  stat_density_2d(aes(fill = ..level..), geom = "polygon", alpha = 0.5) +
  scale_fill_viridis_c(option = "plasma") +
  geom_point(alpha = 0.1, size = 0.5, color = "black") +
  coord_fixed(ratio = 1.3) +
  labs(
    title = "Crime Density Heatmap",
    subtitle = paste("Total crimes:", comma(nrow(crime_geo))),
    x = "Longitude",
    y = "Latitude",
    fill = "Density"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12, color = "gray40"),
    axis.title = element_text(size = 12, face = "bold")
  )

ggsave("outputs/plots/13_crime_density_map.png", p_density, 
       width = 10, height = 8, dpi = 300)
cat("  ✅ Saved: outputs/plots/13_crime_density_map.png\n\n")

# ============================================================================
# 2. Crime Hotspot Identification
# ============================================================================

cat("🔥 Identifying crime hotspots...\n")

# Create grid and count crimes per cell
grid_size <- 0.01  # Approximately 1km

crime_grid <- crime_geo %>%
  mutate(
    lat_grid = round(latitude / grid_size) * grid_size,
    lon_grid = round(longitude / grid_size) * grid_size
  ) %>%
  group_by(lat_grid, lon_grid) %>%
  summarise(
    crime_count = n(),
    avg_lat = mean(latitude),
    avg_lon = mean(longitude),
    crime_types = paste(unique(crime_type), collapse = ", "),
    .groups = 'drop'
  ) %>%
  arrange(desc(crime_count))

# Identify top hotspots
top_hotspots <- crime_grid %>%
  head(20)

cat("  Top 10 Crime Hotspots:\n")
cat("  ========================\n")
for (i in 1:min(10, nrow(top_hotspots))) {
  cat(sprintf("  %2d. Location: (%.4f, %.4f) - %d crimes\n", 
              i, top_hotspots$avg_lat[i], top_hotspots$avg_lon[i], 
              top_hotspots$crime_count[i]))
}
cat("\n")

# Plot hotspots
p_hotspots <- ggplot() +
  geom_point(data = crime_geo, 
             aes(x = longitude, y = latitude),
             alpha = 0.1, size = 0.3, color = "gray70") +
  geom_point(data = crime_grid, 
             aes(x = lon_grid, y = lat_grid, size = crime_count, color = crime_count),
             alpha = 0.7) +
  scale_color_viridis_c(option = "inferno", trans = "log10") +
  scale_size_continuous(range = c(1, 15), trans = "log10") +
  coord_fixed(ratio = 1.3) +
  labs(
    title = "Crime Hotspot Analysis",
    subtitle = "Larger circles indicate higher crime concentration",
    x = "Longitude",
    y = "Latitude",
    color = "Crime Count",
    size = "Crime Count"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12, color = "gray40"),
    axis.title = element_text(size = 12, face = "bold"),
    legend.position = "right"
  )

ggsave("outputs/plots/14_crime_hotspots.png", p_hotspots, 
       width = 12, height = 8, dpi = 300)
cat("  ✅ Saved: outputs/plots/14_crime_hotspots.png\n\n")

# ============================================================================
# 3. Interactive Leaflet Map - All Crimes (Sampled)
# ============================================================================

cat("🌍 Creating interactive leaflet map...\n")

# Sample data for performance (leaflet can be slow with large datasets)
sample_size <- min(5000, nrow(crime_geo))
crime_sample <- crime_geo %>% sample_n(sample_size)

cat("  Using", sample_size, "sampled points for interactive map\n")

# Create color palette for crime types
crime_types <- unique(crime_sample$crime_type)
crime_colors <- colorFactor(
  palette = "Set1",
  domain = crime_types
)

# Create base map
map_all_crimes <- leaflet(crime_sample) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  setView(lng = center_lon, lat = center_lat, zoom = 12) %>%
  
  # Add circle markers
  addCircleMarkers(
    lng = ~longitude,
    lat = ~latitude,
    color = ~crime_colors(crime_type),
    radius = 4,
    fillOpacity = 0.6,
    stroke = FALSE,
    popup = ~paste0(
      "<b>Crime Type:</b> ", crime_type, "<br>",
      "<b>Date:</b> ", date, "<br>",
      "<b>Location:</b> ", location_description, "<br>",
      "<b>Arrest:</b> ", ifelse(arrest, "Yes", "No")
    )
  ) %>%
  
  # Add legend
  addLegend(
    position = "bottomright",
    pal = crime_colors,
    values = ~crime_type,
    title = "Crime Type",
    opacity = 0.8
  )

# Save map
saveWidget(map_all_crimes, "outputs/maps/map_01_all_crimes.html", selfcontained = FALSE)
cat("  ✅ Saved: outputs/maps/map_01_all_crimes.html\n\n")

# ============================================================================
# 4. Interactive Heatmap
# ============================================================================

cat("🔥 Creating interactive heatmap...\n")

# Sample more data for heatmap
heatmap_sample <- crime_geo %>% sample_n(min(10000, nrow(crime_geo)))

map_heatmap <- leaflet(heatmap_sample) %>%
  addProviderTiles(providers$CartoDB.DarkMatter) %>%
  setView(lng = center_lon, lat = center_lat, zoom = 11) %>%
  
  # Add heatmap layer
  addHeatmap(
    lng = ~longitude,
    lat = ~latitude,
    intensity = 1,
    blur = 20,
    max = 0.5,
    radius = 15
  ) %>%
  
  # Add controls
  addMeasure(
    position = "bottomleft",
    primaryLengthUnit = "meters",
    primaryAreaUnit = "sqmeters"
  )

saveWidget(map_heatmap, "outputs/maps/map_02_heatmap.html", selfcontained = FALSE)
cat("  ✅ Saved: outputs/maps/map_02_heatmap.html\n\n")

# ============================================================================
# 5. Hotspot Clusters Map
# ============================================================================

cat("📍 Creating hotspot clusters map...\n")

# Use all hotspot grid data
map_hotspots <- leaflet(crime_grid) %>%
  addProviderTiles(providers$OpenStreetMap) %>%
  setView(lng = center_lon, lat = center_lat, zoom = 11) %>%
  
  # Add circle markers sized by crime count
  addCircleMarkers(
    lng = ~lon_grid,
    lat = ~lat_grid,
    radius = ~sqrt(crime_count) / 2,
    color = ~colorQuantile("YlOrRd", crime_count)(crime_count),
    fillOpacity = 0.7,
    stroke = TRUE,
    weight = 1,
    popup = ~paste0(
      "<b>Hotspot Grid Cell</b><br>",
      "<b>Total Crimes:</b> ", crime_count, "<br>",
      "<b>Location:</b> (", round(lat_grid, 4), ", ", round(lon_grid, 4), ")<br>",
      "<b>Crime Types:</b> ", str_trunc(crime_types, 100)
    )
  ) %>%
  
  # Add top 10 hotspots with labels
  addMarkers(
    data = top_hotspots %>% head(10),
    lng = ~lon_grid,
    lat = ~lat_grid,
    popup = ~paste0(
      "<b>🔥 Top Hotspot</b><br>",
      "<b>Crimes:</b> ", crime_count, "<br>",
      "<b>Location:</b> (", round(lat_grid, 4), ", ", round(lon_grid, 4), ")"
    ),
    label = ~paste("Hotspot:", crime_count, "crimes")
  ) %>%
  
  addLegend(
    position = "bottomright",
    pal = colorQuantile("YlOrRd", crime_grid$crime_count),
    values = crime_grid$crime_count,
    title = "Crime Intensity",
    opacity = 0.8
  )

saveWidget(map_hotspots, "outputs/maps/map_03_hotspots.html", selfcontained = FALSE)
cat("  ✅ Saved: outputs/maps/map_03_hotspots.html\n\n")

# ============================================================================
# 6. Crime Type Comparison Maps
# ============================================================================

cat("📊 Creating crime type comparison map...\n")

# Get top 5 crime types
top_5_crimes <- crime_geo %>%
  count(crime_type, sort = TRUE) %>%
  head(5) %>%
  pull(crime_type)

# Filter for top crimes
crime_by_type <- crime_geo %>%
  filter(crime_type %in% top_5_crimes) %>%
  sample_n(min(3000, n()))

# Create color palette
type_colors <- colorFactor(
  palette = brewer.pal(5, "Set1"),
  domain = top_5_crimes
)

map_by_type <- leaflet(crime_by_type) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  setView(lng = center_lon, lat = center_lat, zoom = 11)

# Add layers for each crime type
for (crime in top_5_crimes) {
  crime_subset <- crime_by_type %>% filter(crime_type == crime)
  
  map_by_type <- map_by_type %>%
    addCircleMarkers(
      data = crime_subset,
      lng = ~longitude,
      lat = ~latitude,
      color = type_colors(crime),
      radius = 3,
      fillOpacity = 0.5,
      stroke = FALSE,
      group = crime,
      popup = ~paste0("<b>", crime_type, "</b><br>", date)
    )
}

# Add layers control
map_by_type <- map_by_type %>%
  addLayersControl(
    overlayGroups = top_5_crimes,
    options = layersControlOptions(collapsed = FALSE),
    position = "topright"
  )

saveWidget(map_by_type, "outputs/maps/map_04_by_crime_type.html", selfcontained = FALSE)
cat("  ✅ Saved: outputs/maps/map_04_by_crime_type.html\n\n")

# ============================================================================
# 7. Temporal Geospatial Analysis
# ============================================================================

cat("📅 Analyzing temporal-spatial patterns...\n")

# Recent vs older crimes comparison
cutoff_date <- max(crime_geo$date) - months(6)

recent_crimes <- crime_geo %>%
  filter(date >= cutoff_date) %>%
  sample_n(min(2000, n()))

older_crimes <- crime_geo %>%
  filter(date < cutoff_date) %>%
  sample_n(min(2000, n()))

map_temporal <- leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  setView(lng = center_lon, lat = center_lat, zoom = 11) %>%
  
  # Recent crimes (red)
  addCircleMarkers(
    data = recent_crimes,
    lng = ~longitude,
    lat = ~latitude,
    color = "#E74C3C",
    radius = 3,
    fillOpacity = 0.6,
    stroke = FALSE,
    group = "Recent (Last 6 months)",
    popup = ~paste0("<b>Recent Crime</b><br>", crime_type, "<br>", date)
  ) %>%
  
  # Older crimes (blue)
  addCircleMarkers(
    data = older_crimes,
    lng = ~longitude,
    lat = ~latitude,
    color = "#3498DB",
    radius = 3,
    fillOpacity = 0.6,
    stroke = FALSE,
    group = "Older",
    popup = ~paste0("<b>Older Crime</b><br>", crime_type, "<br>", date)
  ) %>%
  
  # Add layers control
  addLayersControl(
    overlayGroups = c("Recent (Last 6 months)", "Older"),
    options = layersControlOptions(collapsed = FALSE)
  )

saveWidget(map_temporal, "outputs/maps/map_05_temporal_comparison.html", selfcontained = FALSE)
cat("  ✅ Saved: outputs/maps/map_05_temporal_comparison.html\n\n")

# ============================================================================
# 8. Summary Statistics
# ============================================================================

cat("📊 Geospatial Analysis Summary:\n")
cat("================================\n")

cat("Total crimes with coordinates:", comma(nrow(crime_geo)), "\n")
cat("Grid cells analyzed:", nrow(crime_grid), "\n")
cat("Top hotspot crime count:", max(crime_grid$crime_count), "\n")
cat("Average crimes per grid cell:", round(mean(crime_grid$crime_count), 2), "\n")
cat("Median crimes per grid cell:", median(crime_grid$crime_count), "\n\n")

cat("Geographic extent:\n")
cat("  Latitude range:", round(min(crime_geo$latitude), 4), "to", 
    round(max(crime_geo$latitude), 4), "\n")
cat("  Longitude range:", round(min(crime_geo$longitude), 4), "to", 
    round(max(crime_geo$longitude), 4), "\n\n")

# ============================================================================
# Save Geospatial Data
# ============================================================================

cat("💾 Saving geospatial analysis data...\n")

# Save hotspot data
write_csv(crime_grid, "outputs/crime_hotspots.csv")
write_csv(top_hotspots, "outputs/top_hotspots.csv")

# Save to RData
save(crime_geo, crime_grid, top_hotspots, center_lat, center_lon,
     file = "data/processed/geospatial_data.RData")

cat("  ✅ Hotspots: outputs/crime_hotspots.csv\n")
cat("  ✅ Top hotspots: outputs/top_hotspots.csv\n")
cat("  ✅ Spatial data: data/processed/geospatial_data.RData\n")

cat("\n✅ Geospatial analysis complete!\n")
cat("================================\n")

cat("\n📌 Open these maps in your browser:\n")
cat("  - outputs/maps/map_01_all_crimes.html\n")
cat("  - outputs/maps/map_02_heatmap.html\n")
cat("  - outputs/maps/map_03_hotspots.html\n")
cat("  - outputs/maps/map_04_by_crime_type.html\n")
cat("  - outputs/maps/map_05_temporal_comparison.html\n\n")
