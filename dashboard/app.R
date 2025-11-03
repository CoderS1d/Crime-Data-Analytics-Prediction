# ============================================================================
# Crime Analytics Shiny Dashboard
# ============================================================================
# Interactive dashboard for crime data visualization and exploration
# Combines time-series, forecasting, and geospatial analysis

library(shiny)
library(shinydashboard)
library(tidyverse)
library(lubridate)
library(leaflet)
library(leaflet.extras)
library(plotly)
library(DT)
library(scales)
library(viridis)

# ============================================================================
# Load Data
# ============================================================================

# Load all processed data
if (file.exists("../data/processed/crime_data_clean.RData")) {
  load("../data/processed/crime_data_clean.RData")
} else {
  stop("Data not found. Please run analysis scripts first.")
}

if (file.exists("../data/processed/timeseries_data.RData")) {
  load("../data/processed/timeseries_data.RData")
}

if (file.exists("../data/processed/forecast_models.RData")) {
  load("../data/processed/forecast_models.RData")
}

if (file.exists("../data/processed/geospatial_data.RData")) {
  load("../data/processed/geospatial_data.RData")
}

# ============================================================================
# UI Definition
# ============================================================================

ui <- dashboardPage(
  
  # Dashboard Header
  dashboardHeader(
    title = "Crime Analytics Dashboard",
    titleWidth = 300
  ),
  
  # Sidebar
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Time Series", tabName = "timeseries", icon = icon("chart-line")),
      menuItem("Forecasting", tabName = "forecast", icon = icon("crystal-ball")),
      menuItem("Geospatial", tabName = "geospatial", icon = icon("map")),
      menuItem("Crime Types", tabName = "crimetypes", icon = icon("list")),
      menuItem("Data Explorer", tabName = "data", icon = icon("table")),
      
      hr(),
      
      # Filters
      h4("Filters", style = "padding-left: 15px; color: white;"),
      
      dateRangeInput("dateRange",
                     "Date Range:",
                     start = min(crime_data_clean$date),
                     end = max(crime_data_clean$date),
                     min = min(crime_data_clean$date),
                     max = max(crime_data_clean$date)),
      
      selectInput("crimeType",
                  "Crime Type:",
                  choices = c("All" = "all", unique(crime_data_clean$crime_type)),
                  selected = "all"),
      
      checkboxInput("arrestOnly",
                    "Arrests Only",
                    value = FALSE),
      
      actionButton("resetFilters", "Reset Filters", 
                   icon = icon("refresh"),
                   class = "btn-warning",
                   style = "margin-left: 15px; margin-top: 10px;")
    )
  ),
  
  # Dashboard Body
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .content-wrapper { background-color: #ecf0f5; }
        .small-box { border-radius: 5px; }
        .box { border-radius: 5px; }
      "))
    ),
    
    tabItems(
      
      # ============================================================
      # OVERVIEW TAB
      # ============================================================
      tabItem(tabName = "overview",
        fluidRow(
          valueBoxOutput("totalCrimes", width = 3),
          valueBoxOutput("avgDaily", width = 3),
          valueBoxOutput("arrestRate", width = 3),
          valueBoxOutput("topCrime", width = 3)
        ),
        
        fluidRow(
          box(
            title = "Monthly Crime Trends",
            status = "primary",
            solidHeader = TRUE,
            width = 8,
            plotlyOutput("overviewTrend", height = 300)
          ),
          box(
            title = "Crime Distribution",
            status = "info",
            solidHeader = TRUE,
            width = 4,
            plotlyOutput("crimeDistribution", height = 300)
          )
        ),
        
        fluidRow(
          box(
            title = "Geographic Overview",
            status = "success",
            solidHeader = TRUE,
            width = 12,
            leafletOutput("overviewMap", height = 400)
          )
        )
      ),
      
      # ============================================================
      # TIME SERIES TAB
      # ============================================================
      tabItem(tabName = "timeseries",
        fluidRow(
          box(
            title = "Monthly Crime Trends",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("monthlyTrend", height = 350)
          )
        ),
        
        fluidRow(
          box(
            title = "Seasonal Patterns",
            status = "warning",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("seasonalPattern", height = 300)
          ),
          box(
            title = "Day of Week Patterns",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("weekdayPattern", height = 300)
          )
        ),
        
        fluidRow(
          box(
            title = "Yearly Comparison",
            status = "success",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("yearlyComparison", height = 300)
          ),
          box(
            title = "Crime Type Trends",
            status = "danger",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("crimeTypeTrends", height = 300)
          )
        )
      ),
      
      # ============================================================
      # FORECASTING TAB
      # ============================================================
      tabItem(tabName = "forecast",
        fluidRow(
          valueBoxOutput("forecastNext", width = 4),
          valueBoxOutput("trendDirection", width = 4),
          valueBoxOutput("peakMonth", width = 4)
        ),
        
        fluidRow(
          box(
            title = "6-Month Crime Forecast (ARIMA)",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("arimaForecast", height = 350)
          )
        ),
        
        fluidRow(
          box(
            title = "Prophet Forecast with Components",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("prophetForecast", height = 350)
          )
        ),
        
        fluidRow(
          box(
            title = "Forecast Comparison Table",
            status = "warning",
            solidHeader = TRUE,
            width = 12,
            DTOutput("forecastTable")
          )
        )
      ),
      
      # ============================================================
      # GEOSPATIAL TAB
      # ============================================================
      tabItem(tabName = "geospatial",
        fluidRow(
          valueBoxOutput("totalHotspots", width = 4),
          valueBoxOutput("highestHotspot", width = 4),
          valueBoxOutput("geoSpread", width = 4)
        ),
        
        fluidRow(
          box(
            title = "Interactive Crime Map",
            status = "primary",
            solidHeader = TRUE,
            width = 8,
            leafletOutput("crimeMap", height = 500),
            checkboxInput("showHeatmap", "Show Heatmap Layer", value = FALSE)
          ),
          box(
            title = "Top Crime Hotspots",
            status = "danger",
            solidHeader = TRUE,
            width = 4,
            DTOutput("hotspotTable", height = 500)
          )
        )
      ),
      
      # ============================================================
      # CRIME TYPES TAB
      # ============================================================
      tabItem(tabName = "crimetypes",
        fluidRow(
          box(
            title = "Crime Type Distribution",
            status = "primary",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("crimeTypeBar", height = 400)
          ),
          box(
            title = "Crime Type Proportions",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("crimeTypePie", height = 400)
          )
        ),
        
        fluidRow(
          box(
            title = "Crime Type by Time Period",
            status = "warning",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("crimeTypeTime", height = 350)
          )
        ),
        
        fluidRow(
          box(
            title = "Arrest Rates by Crime Type",
            status = "success",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("arrestRates", height = 300)
          )
        )
      ),
      
      # ============================================================
      # DATA EXPLORER TAB
      # ============================================================
      tabItem(tabName = "data",
        fluidRow(
          box(
            title = "Crime Data Table",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            DTOutput("dataTable"),
            downloadButton("downloadData", "Download Filtered Data", 
                          class = "btn-success")
          )
        ),
        
        fluidRow(
          box(
            title = "Summary Statistics",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            verbatimTextOutput("summaryStats")
          )
        )
      )
    )
  )
)

# ============================================================================
# Server Logic
# ============================================================================

server <- function(input, output, session) {
  
  # ============================================================================
  # Reactive Data Filtering
  # ============================================================================
  
  filteredData <- reactive({
    data <- crime_data_clean %>%
      filter(date >= input$dateRange[1] & date <= input$dateRange[2])
    
    if (input$crimeType != "all") {
      data <- data %>% filter(crime_type == input$crimeType)
    }
    
    if (input$arrestOnly) {
      data <- data %>% filter(arrest == TRUE)
    }
    
    return(data)
  })
  
  # Reset filters
  observeEvent(input$resetFilters, {
    updateDateRangeInput(session, "dateRange",
                         start = min(crime_data_clean$date),
                         end = max(crime_data_clean$date))
    updateSelectInput(session, "crimeType", selected = "all")
    updateCheckboxInput(session, "arrestOnly", value = FALSE)
  })
  
  # ============================================================================
  # OVERVIEW TAB - Value Boxes
  # ============================================================================
  
  output$totalCrimes <- renderValueBox({
    valueBox(
      comma(nrow(filteredData())),
      "Total Crimes",
      icon = icon("exclamation-triangle"),
      color = "red"
    )
  })
  
  output$avgDaily <- renderValueBox({
    days <- as.numeric(difftime(input$dateRange[2], input$dateRange[1], units = "days"))
    avg <- round(nrow(filteredData()) / max(days, 1), 1)
    valueBox(
      avg,
      "Avg Crimes/Day",
      icon = icon("calendar"),
      color = "yellow"
    )
  })
  
  output$arrestRate <- renderValueBox({
    rate <- mean(filteredData()$arrest, na.rm = TRUE) * 100
    valueBox(
      paste0(round(rate, 1), "%"),
      "Arrest Rate",
      icon = icon("handcuffs"),
      color = "green"
    )
  })
  
  output$topCrime <- renderValueBox({
    top <- filteredData() %>%
      count(crime_type, sort = TRUE) %>%
      slice(1) %>%
      pull(crime_type)
    valueBox(
      top,
      "Most Common",
      icon = icon("list"),
      color = "blue"
    )
  })
  
  # ============================================================================
  # OVERVIEW TAB - Plots
  # ============================================================================
  
  output$overviewTrend <- renderPlotly({
    data <- filteredData() %>%
      group_by(year_month) %>%
      summarise(count = n(), .groups = 'drop')
    
    plot_ly(data, x = ~year_month, y = ~count, type = 'scatter', mode = 'lines+markers',
            line = list(color = '#3498DB', width = 2),
            marker = list(color = '#3498DB', size = 6)) %>%
      layout(xaxis = list(title = "Month"),
             yaxis = list(title = "Crime Count"),
             hovermode = 'x unified')
  })
  
  output$crimeDistribution <- renderPlotly({
    data <- filteredData() %>%
      count(crime_type, sort = TRUE) %>%
      head(10)
    
    plot_ly(data, labels = ~crime_type, values = ~n, type = 'pie',
            textinfo = 'label+percent',
            marker = list(colors = viridis(10))) %>%
      layout(showlegend = FALSE)
  })
  
  output$overviewMap <- renderLeaflet({
    data <- filteredData() %>% sample_n(min(2000, n()))
    
    leaflet(data) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addCircleMarkers(
        lng = ~longitude,
        lat = ~latitude,
        radius = 3,
        fillOpacity = 0.5,
        stroke = FALSE,
        color = '#E74C3C'
      )
  })
  
  # ============================================================================
  # TIME SERIES TAB
  # ============================================================================
  
  output$monthlyTrend <- renderPlotly({
    data <- filteredData() %>%
      group_by(year_month) %>%
      summarise(count = n(), .groups = 'drop')
    
    plot_ly(data, x = ~year_month, y = ~count, type = 'scatter', mode = 'lines',
            fill = 'tozeroy',
            line = list(color = '#2C3E50', width = 2),
            fillcolor = 'rgba(44, 62, 80, 0.3)') %>%
      layout(xaxis = list(title = "Month"),
             yaxis = list(title = "Crime Count"),
             hovermode = 'x unified')
  })
  
  output$seasonalPattern <- renderPlotly({
    data <- filteredData() %>%
      group_by(month) %>%
      summarise(count = n(), .groups = 'drop') %>%
      mutate(month = factor(month, levels = month.abb))
    
    plot_ly(data, x = ~month, y = ~count, type = 'bar',
            marker = list(color = '#E67E22')) %>%
      layout(xaxis = list(title = "Month"),
             yaxis = list(title = "Total Crimes"))
  })
  
  output$weekdayPattern <- renderPlotly({
    data <- filteredData() %>%
      group_by(weekday) %>%
      summarise(count = n(), .groups = 'drop') %>%
      mutate(weekday = factor(weekday, levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")))
    
    plot_ly(data, x = ~weekday, y = ~count, type = 'bar',
            marker = list(color = '#3498DB')) %>%
      layout(xaxis = list(title = "Day of Week"),
             yaxis = list(title = "Total Crimes"))
  })
  
  output$yearlyComparison <- renderPlotly({
    data <- filteredData() %>%
      group_by(year) %>%
      summarise(count = n(), .groups = 'drop')
    
    plot_ly(data, x = ~year, y = ~count, type = 'bar',
            marker = list(color = '#16A085')) %>%
      layout(xaxis = list(title = "Year"),
             yaxis = list(title = "Total Crimes"))
  })
  
  output$crimeTypeTrends <- renderPlotly({
    top_crimes <- filteredData() %>%
      count(crime_type, sort = TRUE) %>%
      head(5) %>%
      pull(crime_type)
    
    data <- filteredData() %>%
      filter(crime_type %in% top_crimes) %>%
      group_by(year_month, crime_type) %>%
      summarise(count = n(), .groups = 'drop')
    
    plot_ly(data, x = ~year_month, y = ~count, color = ~crime_type,
            type = 'scatter', mode = 'lines',
            colors = 'Set1') %>%
      layout(xaxis = list(title = "Month"),
             yaxis = list(title = "Crime Count"),
             hovermode = 'x unified')
  })
  
  # ============================================================================
  # FORECASTING TAB
  # ============================================================================
  
  output$forecastNext <- renderValueBox({
    if (exists("arima_results")) {
      next_month <- round(arima_results$forecast[1])
      valueBox(
        comma(next_month),
        "Next Month Forecast",
        icon = icon("calendar-plus"),
        color = "purple"
      )
    }
  })
  
  output$trendDirection <- renderValueBox({
    if (exists("monthly_crimes") && nrow(monthly_crimes) > 6) {
      recent <- tail(monthly_crimes$crime_count, 6)
      trend <- ifelse(mean(tail(recent, 3)) > mean(head(recent, 3)), "Increasing", "Decreasing")
      color <- ifelse(trend == "Increasing", "red", "green")
      valueBox(
        trend,
        "Recent Trend",
        icon = icon(ifelse(trend == "Increasing", "arrow-up", "arrow-down")),
        color = color
      )
    }
  })
  
  output$peakMonth <- renderValueBox({
    if (exists("arima_results")) {
      peak_idx <- which.max(arima_results$forecast)
      peak_month <- format(arima_results$date[peak_idx], "%b %Y")
      valueBox(
        peak_month,
        "Forecast Peak Month",
        icon = icon("chart-line"),
        color = "orange"
      )
    }
  })
  
  output$arimaForecast <- renderPlotly({
    if (exists("arima_results") && exists("monthly_crimes")) {
      historical <- monthly_crimes %>%
        mutate(type = "Historical")
      
      forecast <- arima_results %>%
        mutate(type = "Forecast") %>%
        rename(year_month = date, crime_count = forecast)
      
      plot_ly() %>%
        add_lines(data = historical, x = ~year_month, y = ~crime_count,
                  name = "Historical", line = list(color = '#2C3E50')) %>%
        add_lines(data = forecast, x = ~year_month, y = ~crime_count,
                  name = "Forecast", line = list(color = '#E74C3C', dash = 'dash')) %>%
        add_ribbons(data = forecast, x = ~year_month,
                    ymin = ~lower_80, ymax = ~upper_80,
                    name = "80% CI", fillcolor = 'rgba(231, 76, 60, 0.2)',
                    line = list(width = 0)) %>%
        layout(xaxis = list(title = "Month"),
               yaxis = list(title = "Crime Count"),
               hovermode = 'x unified')
    }
  })
  
  output$prophetForecast <- renderPlotly({
    if (exists("prophet_results") && exists("monthly_crimes")) {
      historical <- monthly_crimes %>%
        mutate(type = "Historical")
      
      forecast <- prophet_results %>%
        mutate(type = "Forecast") %>%
        rename(year_month = date, crime_count = forecast)
      
      plot_ly() %>%
        add_lines(data = historical, x = ~year_month, y = ~crime_count,
                  name = "Historical", line = list(color = '#2C3E50')) %>%
        add_lines(data = forecast, x = ~year_month, y = ~crime_count,
                  name = "Prophet Forecast", line = list(color = '#3498DB', dash = 'dash')) %>%
        add_ribbons(data = forecast, x = ~year_month,
                    ymin = ~lower_80, ymax = ~upper_80,
                    name = "80% CI", fillcolor = 'rgba(52, 152, 219, 0.2)',
                    line = list(width = 0)) %>%
        layout(xaxis = list(title = "Month"),
               yaxis = list(title = "Crime Count"),
               hovermode = 'x unified')
    }
  })
  
  output$forecastTable <- renderDT({
    if (exists("arima_results") && exists("prophet_results")) {
      bind_rows(
        arima_results %>% select(Month = date, Model = model, Forecast = forecast),
        prophet_results %>% select(Month = date, Model = model, Forecast = forecast)
      ) %>%
        mutate(
          Month = format(Month, "%b %Y"),
          Forecast = round(Forecast)
        ) %>%
        datatable(options = list(pageLength = 12, dom = 't'))
    }
  })
  
  # ============================================================================
  # GEOSPATIAL TAB
  # ============================================================================
  
  output$totalHotspots <- renderValueBox({
    if (exists("crime_grid")) {
      high_crime_areas <- crime_grid %>% filter(crime_count > quantile(crime_count, 0.75))
      valueBox(
        nrow(high_crime_areas),
        "High-Crime Areas",
        icon = icon("fire"),
        color = "red"
      )
    }
  })
  
  output$highestHotspot <- renderValueBox({
    if (exists("top_hotspots")) {
      valueBox(
        comma(top_hotspots$crime_count[1]),
        "Highest Hotspot",
        icon = icon("exclamation-circle"),
        color = "orange"
      )
    }
  })
  
  output$geoSpread <- renderValueBox({
    data <- filteredData()
    lat_range <- max(data$latitude) - min(data$latitude)
    lon_range <- max(data$longitude) - min(data$longitude)
    area <- round(lat_range * lon_range * 111 * 111)  # Approx km²
    valueBox(
      paste0(area, " km²"),
      "Geographic Spread",
      icon = icon("expand"),
      color = "blue"
    )
  })
  
  output$crimeMap <- renderLeaflet({
    data <- filteredData() %>% sample_n(min(3000, n()))
    
    leaflet(data) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addCircleMarkers(
        lng = ~longitude,
        lat = ~latitude,
        radius = 3,
        fillOpacity = 0.6,
        stroke = FALSE,
        color = '#E74C3C',
        popup = ~paste0("<b>", crime_type, "</b><br>", date)
      )
  })
  
  output$hotspotTable <- renderDT({
    if (exists("top_hotspots")) {
      top_hotspots %>%
        head(20) %>%
        select(Latitude = lat_grid, Longitude = lon_grid, Crimes = crime_count) %>%
        mutate(
          Latitude = round(Latitude, 4),
          Longitude = round(Longitude, 4)
        ) %>%
        datatable(options = list(pageLength = 20, dom = 't'),
                 rownames = TRUE)
    }
  })
  
  # ============================================================================
  # CRIME TYPES TAB
  # ============================================================================
  
  output$crimeTypeBar <- renderPlotly({
    data <- filteredData() %>%
      count(crime_type, sort = TRUE) %>%
      head(15)
    
    plot_ly(data, x = ~n, y = ~reorder(crime_type, n), type = 'bar',
            orientation = 'h',
            marker = list(color = viridis(nrow(data)))) %>%
      layout(xaxis = list(title = "Count"),
             yaxis = list(title = ""))
  })
  
  output$crimeTypePie <- renderPlotly({
    data <- filteredData() %>%
      count(crime_type, sort = TRUE) %>%
      head(10)
    
    plot_ly(data, labels = ~crime_type, values = ~n, type = 'pie',
            textposition = 'inside',
            textinfo = 'label+percent',
            marker = list(colors = viridis(10))) %>%
      layout(showlegend = TRUE)
  })
  
  output$crimeTypeTime <- renderPlotly({
    top_crimes <- filteredData() %>%
      count(crime_type, sort = TRUE) %>%
      head(5) %>%
      pull(crime_type)
    
    data <- filteredData() %>%
      filter(crime_type %in% top_crimes) %>%
      count(crime_type, month) %>%
      mutate(month = factor(month, levels = month.abb))
    
    plot_ly(data, x = ~month, y = ~n, color = ~crime_type,
            type = 'bar',
            colors = 'Set1') %>%
      layout(barmode = 'stack',
             xaxis = list(title = "Month"),
             yaxis = list(title = "Crime Count"))
  })
  
  output$arrestRates <- renderPlotly({
    data <- filteredData() %>%
      group_by(crime_type) %>%
      summarise(
        arrest_rate = mean(arrest, na.rm = TRUE) * 100,
        total = n(),
        .groups = 'drop'
      ) %>%
      filter(total > 50) %>%
      arrange(desc(arrest_rate)) %>%
      head(15)
    
    plot_ly(data, x = ~arrest_rate, y = ~reorder(crime_type, arrest_rate),
            type = 'bar', orientation = 'h',
            marker = list(color = ~arrest_rate,
                         colorscale = 'RdYlGn',
                         showscale = TRUE,
                         colorbar = list(title = "Rate %"))) %>%
      layout(xaxis = list(title = "Arrest Rate (%)"),
             yaxis = list(title = ""))
  })
  
  # ============================================================================
  # DATA EXPLORER TAB
  # ============================================================================
  
  output$dataTable <- renderDT({
    filteredData() %>%
      select(Date = date, Type = crime_type, Location = location_description,
             Arrest = arrest, Latitude = latitude, Longitude = longitude) %>%
      head(1000) %>%
      datatable(
        options = list(
          pageLength = 25,
          scrollX = TRUE,
          dom = 'Bfrtip'
        ),
        filter = 'top',
        rownames = FALSE
      )
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("crime_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write_csv(filteredData(), file)
    }
  )
  
  output$summaryStats <- renderPrint({
    data <- filteredData()
    cat("=== Crime Data Summary ===\n\n")
    cat("Total Records:", nrow(data), "\n")
    cat("Date Range:", as.character(min(data$date)), "to", as.character(max(data$date)), "\n")
    cat("Unique Crime Types:", n_distinct(data$crime_type), "\n")
    cat("Arrest Rate:", paste0(round(mean(data$arrest, na.rm = TRUE) * 100, 2), "%"), "\n\n")
    cat("Top 5 Crime Types:\n")
    print(data %>% count(crime_type, sort = TRUE) %>% head(5))
  })
}

# ============================================================================
# Run Application
# ============================================================================

shinyApp(ui = ui, server = server)
