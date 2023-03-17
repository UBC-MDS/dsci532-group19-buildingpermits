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
library(DT)

options(shiny.autoreload = TRUE) 

# ==== Load Data ====

# CSV permit data 
permit_data <- read.csv('data/clean/permit_cleaned.csv') 
# Formatting
permit_data$ProjectValue <- as.numeric(permit_data$ProjectValue)
permit_data$YearMonth <- lubridate::ymd(permit_data$YearMonth)

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
ui <- fluidPage(h3("Vancouver Building Permit Explorer"),
                theme = bslib::bs_theme(bootswatch = "flatly"), #flatly
                tabsetPanel(
                  id = 'tabs1',
                  tabPanel("Data Explorer",
                           h4("Explore Building Permit Data"),
                           p("Use the selection options to dynamically filter data shown in the visualizations. Hover cursor over visuals to see more information."),
                           sidebarLayout(
                             sidebarPanel(
                               # select the neighbourhood
                               shinyWidgets::pickerInput(inputId = 'neighbourhood',
                                                         label = 'Select Neighbourhood:',
                                                         choices = sort(unique(permit_data$GeoLocalArea)),
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
                                                         selected = 'Multiple Dwelling',
                                                         options = list(`actions-box` = TRUE,
                                                                        `liveSearch` = TRUE),
                                                         multiple = TRUE),
                               
                               # select the type of work
                               radioButtons(inputId = 'type_of_work',
                                            label = 'Type of Work',
                                            choices = unique(permit_data$TypeOfWork),
                                            selected = c('New Building')),
                               
                               # select the date range
                               dateRangeInput(inputId = 'dateRange',
                                              label = 'Select the range of permit issue dates',
                                              start  = min(permit_data$IssueDate),
                                              end = max(permit_data$IssueDate),
                                              min = min(permit_data$IssueDate),
                                              max = max(permit_data$IssueDate),
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
                               
                              downloadButton("downloadCSV", "Download CSV", class = "small-download-button"),
                              tags$style(HTML("
                                  .small-download-button {
                                    padding: 0.2rem 0.4rem;
                                    font-size: 0.8rem;
                                    line-height: 1.2;
                                  }
                                ")),
                            downloadButton("downloadJSON", "Download JSON", class = "small-download-button")
                            
                             ),
                             mainPanel(
                               fluidRow(
                                 column(12,
                                        leaflet::leafletOutput(outputId = "locations")),
                               ),
                               
                               fluidRow(
                                 tabsetPanel(
                                   id = 'tabs2',
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
                                   ),
                                   tabPanel('Building Permit Data',
                                            DT::DTOutput("table1")),
                                   
                                 ))
                             )
                           )
                  ),
                  tabPanel("Neighbourhood Map",
                           h4("Neighbourhood Summary Map"),
                           p("Use the drop-down to select a summary statistic.  Hover cursor over neighbourhoods to see values."),
                           # Chloropleth map
                           leaflet::leafletOutput(outputId = 'chloropleth',
                                                   width = "100%",
                                                   height = "600px"),
                           absolutePanel(id = "testpanel", class = "panel panel-default", fixed = TRUE,
                                         draggable=TRUE, top = 230, left = "auto", right = -500, bottom = "auto",
                                         width = 800, height = "200",
                                         sidebarPanel(selectInput(inputId = 'statistic',
                                                                  label = 'Summary Statistic Shown:',
                                                                  choices = chlor_ref,
                                                                  selected = chlor_ref[1]
                                                                  )
                                                      )
                                         )
                           )
                )
)


# ==== Server ====
server <- function(input, output, session) {
  
  # ===== Filtered Data ====
  
  # ==== Detailed Summary tab ====

  # need to obtain updated choices for Building Type
  # unique_SUC <- reactive({
  #   filtered_area() |>
  #     tidyr::separate_rows(SpecificUseCategory, sep = ',') |>
  #     dplyr::distinct(SpecificUseCategory)
  # })
  
  # observeEvent(input$neighbourhood, {
  #   updatePickerInput(session,
  #                     inputId = 'specificUse',
  #                     choices = unique_SUC()$SpecificUseCategory,
  #                     selected = unique_SUC()$SpecificUseCategory[1])
  # })
  
  filtered_data <- reactive({ 
    # need to filter the data by the inputs
    filter <- permit_data |> 
      dplyr::filter(GeoLocalArea %in% input$neighbourhood, # neighbourhood filter
                    
                    SpecificUseCategory %in% unique(as.vector(permit_data$SpecificUseCategory[stringr::str_detect(permit_data$SpecificUseCategory, input$specificUse)])),
                    
                    input$dateRange[2] > IssueDate, # date range
                    IssueDate > input$dateRange[1], 
                    
                    input$elapsedDays[2] > PermitElapsedDays, # permit elapsed days
                    PermitElapsedDays > input$elapsedDays[1], 
                    
                    input$projectValue[2] > ProjectValue, # project value
                    ProjectValue > input$projectValue[1],
                    
                    TypeOfWork %in% input$type_of_work # type of work
      )
    validate(
      missing_values(filter)
    )
    
    filter
  })
  
  missing_values <- function(input) {
    if (nrow(input) == 0) {
      "No data is available for the selected inputs. please change inputs to refresh the map and plots"
    } else {
      NULL
    }
  }
  
  # ==== Neighbourhood tab ====
  filtered_data2 <- reactive({
    nbhd_data |>
      # dplyr::filter(stat == input$statistic)
      dplyr::filter(stat == input$statistic)
  })
  
  
  # ==== Visuals ====
  
  # ==== Point Map ====
  output$locations <- leaflet::renderLeaflet({
    
    req(input$neighbourhood)
    req(input$specificUse)
    req(input$type_of_work)
    
    locations <- leaflet::leaflet(data = filtered_data(),options = leafletOptions(attributionControl = FALSE))
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
    
    req(input$neighbourhood)
    req(input$specificUse)
    req(input$type_of_work)
    
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
    
    req(input$neighbourhood)
    req(input$specificUse)
    req(input$type_of_work)
    
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
  
  
  # ==== Filtered Data ====
  #filter data for viewing
  output$table1 <- DT::renderDT({
    
    req(input$neighbourhood)
    req(input$specificUse)
    req(input$type_of_work)
    
    filtered_data()%>% 
      select(PermitNumber, IssueDate, ProjectValue,TypeOfWork,IssueYear,PermitElapsedDays,PermitNumberCreatedDate) |> 
      rename ("Permit No" = "PermitNumber",
              "Issue Date" = "IssueDate",
              "Project Value" = "ProjectValue",
              "Type"= "TypeOfWork",
              "Issue Year" = "IssueYear",
              "Days" = "PermitElapsedDays",
              "Create Date" = "PermitNumberCreatedDate")
  }, rownames = FALSE, options = list(pageLength = 10))
  
  
  # ==== Download Data ====
  #Download filtered data and create csv 
  
  # CSV download handler
  output$downloadCSV <- downloadHandler(
    filename = function() {
      paste("Permit_data-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(filtered_data(), file)
    }
  )
  
  # JSON download handler
  output$downloadJSON <- downloadHandler(
    filename = "Permit_data.json",
    content = function(file) {
      # Convert data to JSON format
      my_data_json <- jsonlite::toJSON(filtered_data())
      # Write JSON to file
      writeLines(my_data_json, file)
    }
  )
  
  
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
        )) |> addLegend(position = "bottomleft", pal = pal, 
                        values = filtered_data2()$value,
                        title = "Statistic Value:",
                        opacity = 0.7) |>
      setView(lng=-123.108456, lat=49.247406, zoom = 12)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
