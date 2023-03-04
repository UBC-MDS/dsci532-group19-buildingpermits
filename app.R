# Load packages 
library(shiny)
library(leaflet)
library(tidyr)
library(shinyWidgets)
library(htmltools)
library(leaflet.extras)
library(sf)
library(bslib)

options(shiny.autoreload = TRUE)

#load data 
permit_data <- read.csv('data/permit_cleaned.csv') |> dplyr::filter(stringr::str_detect(PropertyUse, "Dwelling Uses"))
permit_data <- separate(permit_data, col = geo_point_2d, into= c("Latitude","Longitude"), sep = ", ")
permit_data$Longitude <- as.numeric(permit_data$Longitude)
permit_data$Latitude <- as.numeric(permit_data$Latitude)
permit_data$ProjectValue <- as.numeric(permit_data$ProjectValue)
permit_data$YearMonth <- lubridate::ym(permit_data$YearMonth)
permit_data$label <- paste("<p> Permit Number:", permit_data$PermitNumber,
                          "<p> Permit Issue Date:", permit_data$IssueDate,
                          "<p> Project Value: $", permit_data$ProjectValue,
                          "<p> Type Of Work:", permit_data$TypeOfWork,
                          "<p> Address:", permit_data$Address,
                          "<p> Category:", permit_data$SpecificUseCategory,
                          "<p> Property Use:", permit_data$PropertyUse) 

# these two are for the variable name in the charts, they're needed
plot_variable <- c('Cost of project construction ($CAD)' = "ProjectValue", 
                  'Number of days before permit approval' = 'PermitElapsedDays')

# these two are for the variable name in the charts, they're needed
plot_group <- c('Neighbourhood' ='GeoLocalArea', 
                  'Type of construction project' = 'TypeOfWork')

# Define UI for application   draws a histogram
ui <- fluidPage("Building Permits",
                theme = bslib::bs_theme(bootswatch = "flatly"),
                tabsetPanel(
                  tabPanel("Spatial Visualisaton of Housing Permit",
                           sidebarLayout(
                             sidebarPanel(
                                          # select the neighbourhood
                                          shinyWidgets::pickerInput(inputId = 'neighbourhood',
                                                                    label = 'select the neighbourhood:',
                                                                    choices = unique(permit_data$GeoLocalArea),  
                                                                    selected = unique(permit_data$GeoLocalArea),
                                                                    options = list(`actions-box` = TRUE),
                                                                    multiple = T),
                                          
                                          # select the building type
                                          shinyWidgets::pickerInput(inputId = 'specificUse',
                                                                    label = 'Select the building type:',
                                                                    choices = c('Multiple Dwelling', 'Rowhouse', 'Duplex', 'Detached House', 'Laneway House', 'Temporary Modular Housing', 'Micro Dwelling'),
                                                                    selected = 'Multiple Dwelling',
                                                                    options = list(`actions-box` = TRUE),
                                                                    multiple = TRUE),
                                          
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
                                                      max = 250000000, # setting max to 250m so that it's mroe usable
                                                      value = c(min(permit_data$ProjectValue), 250000000)
                                          ),
                                          
                                          # select the type of work
                                          shinyWidgets::pickerInput(inputId = 'type_of_work',
                                                                    label = 'Type of Work',
                                                                    choices = unique(permit_data$TypeOfWork),
                                                                    selected = 'New Building',
                                                                    options = list(`actions-box` = TRUE),
                                                                    multiple = TRUE)
                             ),
                             mainPanel(
                               fluidRow(
                                 column(12,
                                        leaflet::leafletOutput(outputId = "locations")),
                               ),
                               
                               fluidRow(
                                 column(6,
                                        selectInput(inputId = 'selected_variable', 
                                                    label = "Select variable to plot", 
                                                    choices= plot_variable,
                                                    selected = plot_variable[1]
                                                    
                                        ),
                                        plotOutput(outputId = "histogram")
                                        
                                 ),
                                 
                                 column(6,
                                        selectInput(inputId = 'category',
                                                    label = 'Show selected variable by',
                                                    choices = plot_group,
                                                    selected = plot_group[1]
                                        ),
                                        plotOutput(outputId = 'linechart'))
                               )
                             )
                           )
                  ),
                  tabPanel("Neighbhourhood Analysis"),
                )
)


# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
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
  
  
  output$locations <- leaflet::renderLeaflet({
    #adding points on basemap
    locations <- leaflet::leaflet(data = filtered_data())
    locations <- locations |> 
      addProviderTiles(providers$Stamen.Toner) |> 
      addCircleMarkers(lng=~Longitude, lat=~Latitude,stroke = FALSE, fillOpacity = 0.6,
                       color = 'pink',
                       weight = 3,
                       group = 'building locations', 
                       label = lapply(filtered_data()$label, HTML)
      )
  })
  
  
  
  output$histogram <- renderPlot({
    # adding histogram
    
    ggplot2::ggplot(data = filtered_data(), 
                    ggplot2::aes_string(y = input$selected_variable)
    ) +
      ggplot2::geom_histogram(fill = "pink",
                              bins = 25,
                              alpha = 0.6,
                              color = 'lightgrey'
      ) +
      ggplot2::scale_y_continuous(labels = scales::comma) +
      ggplot2::labs(x = 'Project Count by Bin', y = names(plot_variable[which(plot_variable == input$selected_variable)])) +
      ggplot2::theme_classic() 
      
  })
  
  output$linechart <- renderPlot({
    # generate timeline charts

    ggplot2::ggplot(data = filtered_data(),
                    ggplot2::aes_string(x = 'YearMonth',
                                 y = input$selected_variable,
                                 color = input$selected_variable)) +
      ggplot2::geom_line(stat = 'summary', fun = sum) +
      ggplot2::scale_y_continuous(labels = scales::comma) +
      ggplot2::theme_classic() +
      ggplot2::theme(legend.position = 'none') +
      ggplot2::facet_wrap(~filtered_data()[[input$category]]) +
      ggplot2::labs(x = names(plot_group[which(plot_group == input$category)]), 
                    y = names(plot_variable[which(plot_variable == input$selected_variable)]))
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
