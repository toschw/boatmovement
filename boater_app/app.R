library(shiny)
library(rgdal)
library(DT)
library(dygraphs)
library(xts)
library(leaflet)
library(geojsonio)
library(dplyr)
library(ggplot2)

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

# server()
server <- function(input, output){
 
  output$histogram <- renderPlot({
    dataHisto <- NULL
    dataHisto <- select(data,input$variableselected)
     d <- as.numeric(dataHisto[,1])
     hist(d, main="Histogram for selected variable") 
  
      })
  
  output$map <- renderLeaflet({
    
    # Add data to map
    filterData <- select(data, input$variableselected,responseID)
    map@data <- filterData

     # Create variableplot
    map$variableplot <- as.numeric(map@data[, input$variableselected]) # ADD this to create variableplot
    
    # Create leaflet
    pal <- colorBin("YlOrRd", domain = map$variableplot, bins =5,  alpha = FALSE, na.color = "#808080", reverse=T) # CHANGE map$cases by map$variableplot
    
    labels <- sprintf("%s: %g", map$responseID, map$variableplot) %>% lapply(htmltools::HTML) # CHANGE map$cases by map$variableplot
    
    l <- leaflet(map) %>% 
      addTiles() %>% addProviderTiles("Esri")%>% addPolylines(
      stroke = TRUE, 
      color = ~pal(variableplot), #"green"
      weight = 2,
      opacity = 1.0, 
      fill = FALSE,
     # dashArray = "3",
     # fillColor =  ~pal(variableplot),
      fillOpacity = 0.2, 
      smoothFactor = 3,
      noClip=TRUE,
      label = labels) %>%
      leaflet::addLegend(pal = pal, values = ~variableplot, opacity = 0.7, title = NULL)
  })
}

# shinyApp()
shinyApp(ui = ui, server = server)