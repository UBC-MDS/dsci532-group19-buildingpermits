# ==== Load packages ====
library(shiny)
library(leaflet)
library(tidyr)
library(shinyWidgets)
library(htmltools)
library(leaflet.extras)
library(leaflet.extras2)
library(sf)
library(bslib)
library(plotly)
library(thematic) 

options(shiny.autoreload = TRUE) 

# ==== Load Data ====

# CSV permit data 
permit_data <- read.csv('data/clean/permit_cleaned.csv') 
# Formatting
permit_data$ProjectValue <- as.numeric(permit_data$ProjectValue)
permit_data$YearMonth <- lubridate::ymd(permit_data$YearMonth)
# unique_SUC <- permit_data |>
#   tidyr::separate_rows(SpecificUseCategory, sep = ",") |>
#   dplyr::distinct(SpecificUseCategory)
# unique_SUC <- sort(unique_SUC$SpecificUseCategory)
# unique_SUC <- tibble('SpecificUseCategory' = unique_SUC)

# Neighbourhood Data 
nbhd_data <- sf::st_read("data/clean/geo_nbhd_summary_long.geojson")


# ==== Housekeeping ====

# Create labels for the permit data point popups
permit_data$label <- paste("<p><b>Permit Number:</b>", permit_data$PermitNumber,
                           "<p><b>Permit Issue Date:</b>", permit_data$IssueDate,
                           "<p><b>Project Value: </b>$", format(round(permit_data$ProjectValue,0), big.mark = ","),
                           "<p><b>Type Of Work:</b>", permit_data$TypeOfWork,
                           "<p><b>Address:</b>", permit_data$Address,
                           "<p><b>Building Category:</b>", permit_data$SpecificUseCategory,
                           "<p><b>Property Use:</b>", permit_data$PropertyUse) 

# Create labels for the neighbourhood map popups
nbhd_data$label <- paste("<p><b>Neighbourhood:</b>", nbhd_data$name,
                         "<p><b>Value:</b>", round(nbhd_data$value, 0))

# Create variable references for filter selection
plot_variable <- c('Cost of project construction ($CAD)' = "ProjectValue", 
                   'Number of days before permit approval' = 'PermitElapsedDays')

# Create variable references for filter selection
plot_group <- c('Neighbourhood' ='GeoLocalArea', 
                'Type of construction project' = 'TypeOfWork')

# Create variable references for chloropleth map
chlor_ref <- c('Building Permit Count' = 'count_permits',
               'Elapsed Days Before Approval: Average' = 'elapsed_days_avg',
               'Elapsed Days Before Approval: 25th Quantile' = 'elapsed_days_25q',
               'Elapsed Days Before Approval: Median' = 'elapsed_days_50q',
               'Elapsed Days Before Approval: 75th Quantile' = 'elapsed_days_75q',
               'Project Value ($): Average' = 'project_value_avg',
               'Project Value ($): 25th Quantile' = 'project_value_25q',
               'Project Value ($): Median' = 'project_value_50q',
               'Project Value ($): 75th Quantile' = 'project_value_75q')


# ==== UI ====
ui <- fluidPage("Building Permits",
                theme = bslib::bs_theme(bootswatch = "flatly"),
                tabsetPanel(
                  tabPanel("Spatial Visualisaton of Housing Permit",
                           sidebarLayout(
                             sidebarPanel(
                               # select the neighbourhood
                               shinyWidgets::pickerInput(inputId = 'neighbourhood',
                                                         label = 'Select Neighbourhood:',
                                                         choices = unique(permit_data$GeoLocalArea),  
                                                         selected = unique(permit_data$GeoLocalArea),
                                                         options = list(`actions-box` = TRUE),
                                                         multiple = T),
                               
                               # select the building type
                               shinyWidgets::pickerInput(inputId = 'specificUse',
                                                         label = 'Select Building Type:',
                                                         choices = c(
                                                           # Common quick-search categories
                                                           'Detached House', 
                                                           'Duplex',
                                                           'Infill',
                                                           'Laneway House', 
                                                           'Micro Dwelling', 
                                                           'Multiple Dwelling', 
                                                           'Rowhouse',
                                                           
                                                           # Specific dwelling categories from the data
                                                           "Duplex w/Secondary Suite",
                                                           "Dwelling Unit",
                                                           "Dwelling Unit w/ Other Use",
                                                           "Freehold Rowhouse",
                                                           "Housekeeping Unit",
                                                           "Infill Multiple Dwelling",
                                                           "Infill Single Detached House",
                                                           "Infill Two-Family Dwelling",
                                                           "Multiple Conv Dwelling w/ Family Suite",
                                                           "Multiple Conv Dwelling w/ Sec Suite",
                                                           "Multiple Conversion Dwelling",
                                                           "Not Applicable",
                                                           "Principal Dwelling Unit w/Lock Off",
                                                           "Residential/Business Unit",
                                                           "Residential Unit Associated w/ an Artist Studio",
                                                           "Rooming House",
                                                           "Secondary Suite",
                                                           "Seniors Supportive/Assisted Housing",
                                                           "Single Detached House",
                                                           "Single Detached House w/Sec Suite",
                                                           "Sleeping Unit",
                                                           "Temporary Modular Housing",
                                                           "1FD on Sites w/ More Than One Principal Building",
                                                           "1FD w/ Family Suite",
                                                           "2FD on Sites w/ Mult Principal Bldg"),
                                                         selected = c(
                                                           # Common inquiry
                                                           'Multiple Dwelling'),
                                                         options = list(`actions-box` = TRUE,
                                                                        `liveSearch` = TRUE),
                                                         multiple = TRUE),
                               
                               # select the type of work
                               shinyWidgets::pickerInput(inputId = 'type_of_work',
                                                         label = 'Type of Work',
                                                         choices = unique(permit_data$TypeOfWork),
                                                         selected = 'New Building',
                                                         options = list(`actions-box` = TRUE),
                                                         multiple = TRUE),
#                               verbatimTextOutput(outputId = "result"),
                               
                               # select the date range
                               dateRangeInput(inputId = 'dateRange',
                                              label = 'Select the range of permit issue dates',
                                              start  = min(permit_data$IssueDate),
                                              end = max(permit_data$IssueDate),
                                              format = "yyyy/mm/dd"),
                               
                               # select the permit elapsed days range
                               sliderInput(inputId = 'elapsedDays',
                                           label = 'Select the range of days to grant the permit (from submission)',
                                           min = min(permit_data$PermitElapsedDays),
                                           max = max(permit_data$PermitElapsedDays),
                                           step = 5,
                                           value = c(min(permit_data$PermitElapsedDays), max(permit_data$PermitElapsedDays))
                               ),
                               
                               # select the project value 
                               sliderInput(inputId = 'projectValue',
                                           label = 'Select the range of project construction costs',
                                           min = min(permit_data$ProjectValue),
                                           max = 250000000, # setting max to 250m so that it's more usable,
                                           step = 5000,
                                           value = c(min(permit_data$ProjectValue), 250000000)
                               ),
                               
                               
                               selectInput(inputId = 'selected_variable', 
                                           label = "Select variable to plot in charts", 
                                           choices= plot_variable,
                                           selected = plot_variable[1]
                               ),
                               
                               
                             ),
                             mainPanel(
                               fluidRow(
                                 column(12,
                                        leaflet::leafletOutput(outputId = "locations")),
                               ),
                               
                               fluidRow(
                                 tabsetPanel(
                                   tabPanel('Histogram of Projects',
                                            plotlyOutput(outputId = "histogram")
                                   ),
                                   tabPanel('Line Charts',
                                            selectInput(inputId = 'category',
                                                        label = 'Show selected variable by',
                                                        choices = plot_group,
                                                        selected = plot_group[1]
                                            ),
                                            plotlyOutput(outputId = 'linechart')
                                   )
                                 ))
                             )
                           )
                  ),
                  tabPanel("Neighbhourhood Analysis",
                           sidebarLayout(
                             # Neighbourhood selection for map
                             sidebarPanel(selectInput(inputId = 'statistic',
                                                      label = 'Show me...',
                                                      choices = chlor_ref, #unique(nbhd_data$stat),
                                                      selected = chlor_ref[1])),
                             # Chloropleth map
                             mainPanel(leaflet::leafletOutput(outputId = 'chloropleth',
                                                              width = "100%",
                                                              height = 500)))),
                )
)


# ==== Server ====
server <- function(input, output, session) {
  
  # ===== Filtered Data ====
  
  # ==== Detailed Summary tab ====
  filtered_data <- reactive({ 
    # need to filter the data by the inputs
    permit_data |> 
      dplyr::filter(GeoLocalArea %in% input$neighbourhood,  # neighbourhood
                    
                    SpecificUseCategory %in% unique(as.vector(permit_data$SpecificUseCategory[stringr::str_detect(permit_data$SpecificUseCategory, input$specificUse)])),
                    
                    input$dateRange[2] > IssueDate, # date range
                    IssueDate > input$dateRange[1], 
                    
                    input$elapsedDays[2] > PermitElapsedDays, # permit elapsed days
                    PermitElapsedDays > input$elapsedDays[1], 
                    
                    input$projectValue[2] > ProjectValue, # project value
                    ProjectValue > input$projectValue[1],
                    
                    TypeOfWork %in% input$type_of_work # type of work
      ) 
  }) 
  
  # ==== Neighbourhood tab ====
  filtered_data2 <- reactive({
    nbhd_data |>
      # dplyr::filter(stat == input$statistic)
      dplyr::filter(stat == input$statistic)
  })
  
  
  # ==== Visuals ====
  
  # ==== Point Map ====
  output$locations <- leaflet::renderLeaflet({
    locations <- leaflet::leaflet(data = filtered_data())
    locations <- locations |> 
      addTiles(group = "Neighbourhood") |> 
      addProviderTiles(providers$Esri.WorldImagery, group = "Satellite View") |>
      addProviderTiles(providers$CartoDB.Positron, group = "Basemap")
    locations <- locations %>%
      addLayersControl(
        baseGroups = c("Basemap","Neighbourhood", "Satellite view"),
        options = layersControlOptions(collapsed = FALSE)
      ) |> addCircleMarkers(lng=~Longitude, 
                       lat=~Latitude,
                       stroke = FALSE, 
                       radius = 4,
                       color = 'black',
                       opacity = 1,
                       fillColor = 'blue',
                       fillOpacity = 0.9,
                       
                       weight = 3,
                       group = 'building locations', 
                       label = lapply(filtered_data()$label, HTML),
                       
                       labelOptions = labelOptions(
                         textsize = "12px"
                       ),
                       clusterOptions = markerClusterOptions(
                         disableClusteringAtZoom = 15,
                         showCoverageOnHover = FALSE,
                         spiderfyOnMaxZoom = FALSE)
      ) 
  })
  
  # ==== Histogram ====
  output$histogram <- renderPlotly({
    
    plot_hist <- ggplot2::ggplot(data = filtered_data(), 
                                 ggplot2::aes_string(y = input$selected_variable)
    ) +
      ggplot2::geom_histogram(fill = "blue",
                              bins = 20,
                              alpha = 0.6,
                              color = 'lightgrey'
      ) +
      ggplot2::scale_y_continuous(labels = scales::comma) +
      ggplot2::labs(x = 'Project Count by Bin', y = names(plot_variable[which(plot_variable == input$selected_variable)])) +
      ggplot2::theme_classic()
    
    plotly::ggplotly(plot_hist, tooltip = 'count')
    
    
  })
  
  # ==== Line Chart ====
  output$linechart <- renderPlotly({
    # generate line charts
    plotly::ggplotly( 
      ggplot2::ggplot(data = filtered_data(),
                      ggplot2::aes_string(x = 'YearMonth',
                                          y = input$selected_variable,
                                          color = input$category)) +
        ggplot2::geom_line(stat = 'summary', fun = mean) +
        ggplot2::scale_y_continuous(labels = scales::comma) +
        ggplot2::theme_classic() +
        ggplot2::theme(legend.position = 'none',
                       axis.title.y = element_text(margin = margin(t = 0, r = 14, b = 0, l = 0))) +
        ggplot2::facet_wrap(~filtered_data()[[input$category]]) +
        ggplot2::labs(x = names(plot_group[which(plot_group == input$category)]), 
                      y = names(plot_variable[which(plot_variable == input$selected_variable)]))
    )
    
  })
  
  # ==== Chloropleth Map ====
  output$chloropleth <- leaflet::renderLeaflet({
    
    # Create color palette
    pal <- leaflet::colorNumeric("Blues",
                                 domain = filtered_data2()$value)
    
    # Create reactive map
    filtered_data2() |>
      leaflet::leaflet() |>
      addProviderTiles(providers$CartoDB.Positron) |>
      addPolygons(
        fillColor = ~pal(value),
        weight = 2,
        opacity = 1,
        color = "white",
        fillOpacity = 0.7,
        label = lapply(filtered_data2()$label, HTML),
        labelOptions = labelOptions(textsize = "12px"),
        highlightOptions = highlightOptions(
          weight = 4,
          color = "black",
          fillOpacity = 0.7,
          bringToFront = TRUE
        )) |> addLegend(position = "bottomright", pal = pal, 
    values = filtered_data2()$value,
    title = "Number of Units",
    labFormat = labelFormat(suffix = " units"),
    opacity = 0.7)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
