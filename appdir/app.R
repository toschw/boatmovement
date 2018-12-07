library(shiny)
library(rgdal)
library(DT)
library(dygraphs)
library(xts)
library(leaflet)

data <- read.csv("data/featuresApp.csv")
map <- readOGR("data/Boater_Joined_2/Boater_Joined_2.shp")

# ui object
elodeaNo <- c("Did not report","Cannot remember")
ui <- fluidPage(
  titlePanel(p("Mapping responses from registered boat owners in Alaska", style="color:#3474A7")),
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "variableselected", label = "Select numeric variable to show in color",
                  list(`Trip frequency`= "freqPre",
                       `Total anual km`="totalKmPre",
                       `Route length in km`="km",
                       `Personal income`="Income",
                       `Average number of passengers`="pax",
                       `Boat owner age`="age",
                       `Annual operating cost`="YrCostPre")),
    
      selectInput(inputId = "selectOutside", label = "Select boaters who were boating outside Alaska",
                  list(`Yes`="Yes",
                       `No`="No"))),
    
    mainPanel(
      leafletOutput(outputId = "map")  #Insert , here if other parts become active 
     
    )
  )
)

# server()
server <- function(input, output){
 
  output$map <- renderLeaflet({
    
    # Add data to map
    map@data <- subset(data, data$freshOutside == input$selectOutside )

     # Create variableplot
    map$variableplot <- as.numeric(map@data[, input$variableselected]) # ADD this to create variableplot
    
    # Create leaflet
    pal <- colorBin("YlOrRd", domain = map$variableplot, bins = 7) # CHANGE map$cases by map$variableplot
    
    labels <- sprintf("%s: %g", map$responseID, map$variableplot) %>% lapply(htmltools::HTML) # CHANGE map$cases by map$variableplot
    
    l <- leaflet(map) %>% addTiles() %>% addProviderTiles("Esri")%>% addPolylines(
      stroke = TRUE, 
      color = ~pal(variableplot), #"green"
      weight = 2,
      opacity = 1.0, 
      fill = FALSE, 
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