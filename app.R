# Load packages 
library(shiny)
library(leaflet)
library(readxl)
library(tidyr)
library(shinyWidgets)

#load data 
permit_data<- read.csv('data/permit_cleaned.csv') |> dplyr::filter(stringr::str_detect(PropertyUse, "Dwelling Uses"))
permit_data <- separate(permit_data, col = geo_point_2d, into= c("Latitude","Longitude"), sep = ", ")
permit_data$Longitude<- as.numeric(permit_data$Longitude)
permit_data$Latitude<- as.numeric(permit_data$Latitude)

# Define UI for application   draws a histogram
ui <- fluidPage("Building Permits",
  tabsetPanel(
      tabPanel("Spatial Visualisaton of Housing Permit",
        sidebarLayout(
          sidebarPanel(width = 2,
            
            # select the neighbourhood
            shinyWidgets::pickerInput(inputId = 'neighbourhood',
                        label = 'select the neighbourhood:',
                        choices = unique(permit_data$GeoLocalArea),  
                        selected = unique(permit_data$GeoLocalArea),
                        options = list(`actions-box` = TRUE),
                        multiple = T),
            
            # select the building type
            shinyWidgets::pickerInput(inputId = 'buildingType',
                        label = 'Select the building type:',
                        choices = unique(permit_data$SpecificUseCategory), # need to fix this, make it a better list
                        # choices = c("Multiple Dwelling", "Laneway House"), # need to fix this, make it a better list
                        selected = 'Multiple Dwelling',
                        options = list(`actions-box` = TRUE),
                        multiple = T),
          
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
   
            # select the permit elapsed days range
            sliderInput(inputId = 'projectValue',
                          label = 'Select the range of project construction costs',
                          min = min(permit_data$ProjectValue),
                          max = max(permit_data$ProjectValue),
                          value = c(min(permit_data$ProjectValue), max(permit_data$ProjectValue))
                           ),
          ),
          mainPanel(
            fluidRow(
              column(6,
                    leaflet::leafletOutput(outputId = "locations")),
                    
              column(6,
                     selectInput('selected_variable', 
                                 "Select variable to plot", 
                                 choices=c('Cost of project construction' = "ProjectValue", 
                                           'Number of days before permit approval' = 'PermitElapsedDays'),
                                 selected = 'Cost of project construction'
                                 
                                ),
                     plotOutput(outputId = "histogram")
                    
              )
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
                    
                    SpecificUseCategory %in% input$buildingType, # building type
                    
                    input$dateRange[2] > IssueDate, # date range
                    IssueDate > input$dateRange[1], 
                    
                    input$elapsedDays[2] > PermitElapsedDays, # permit elapsed days
                    PermitElapsedDays > input$elapsedDays[1], 
                    
                    input$projectValue[2] > ProjectValue, # project value
                    ProjectValue > input$projectValue[1]) 
  }) 
  

  output$locations <- leaflet::renderLeaflet({
    #adding points on basemap
    locations <- leaflet::leaflet(data = filtered_data())
    locations <- leaflet::addTiles(locations)
    locations <- leaflet::addMarkers(locations, lng=~Longitude, lat=~Latitude)
  })
  
  
  
  output$histogram <- renderPlot({
    # adding histogram
    
    ggplot2::ggplot(data = filtered_data(), 
                   ggplot2::aes(x = filtered_data()[[input$selected_variable]])
                    ) +
        ggplot2::geom_histogram(ggplot2::aes(y = ..density..),
                     fill = "grey",
                     color = "blue",
                     bins = 50,
                     alpha = 0.3
                    ) +
        ggplot2::scale_x_continuous(labels = scales::comma)
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
