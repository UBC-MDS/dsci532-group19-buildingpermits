#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# 


# Load packages 

library(shiny)
library(leaflet)
library(readxl)
library(tidyr)

#load data 
permit_data<- read_excel('/Users/revathypon/DSCI_532/shiny_test/issued-building-permits-cleaned.xlsx')

permit_data <- separate(permit_data, col = geo_point_2d, into= c("Latitude","Longitude"), sep = ", ")

permit_data$Longitude<- as.numeric(permit_data$Longitude)
permit_data$Latitude<- as.numeric(permit_data$Latitude)

filtered_permit_data <- permit_data[permit_data$IssueYear == 2021, ]

# Define UI for application   draws a histogram
ui <- fluidPage("Building Permits",
  tabsetPanel(
    tabPanel("Spatial Visualisaton of Housing Permit",leafletOutput("locations")),
        # Application title
        tabPanel("Neighbhourhood Analysis"),
        
      )
    )

# Define server logic required to draw a histogram
server <- function(input, output) {
  output$locations<-renderLeaflet({
  #adding points on basemap
  locations <- leaflet(data = filtered_permit_data)
  locations<- addTiles(locations)
  locations<- addMarkers(locations, lng=~Longitude, lat=~Latitude)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
