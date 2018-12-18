library(shiny)
library(rgdal)
library(DT)
library(dygraphs)
library(xts)
library(leaflet)
library(geojsonio)

data <- read.csv("data/featuresApp.csv")
#map <- readOGR("data/Boater_Joined_2/Boater_Joined_2.shp")
map <- geojsonio::geojson_read("data/map.geojson", what = "sp")

# ui object

ui <- fluidPage(
  titlePanel(p("Mapping responses from registered boat owners in Alaska about their 2018 trips", style="color:#3474A7")),
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "variableselected", label = "Select variable to show on map",
                  list(`Trip frequency`= "freqPre",
                       `Total annual km`="totalKmPre",
                       `Route length in km`="km",
                       `Personal income`="Income",
                       `Average number of passengers`="pax",
                       `Boat owner age`="age",
                       `Annual operating cost`="YrCostPre"))),
    
    mainPanel(
      leafletOutput(outputId = "map"),  #Insert, here if other parts become active
      plotOutput(outputId = "histogram")
    )
  )
)