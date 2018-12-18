# server()
server <- function(input, output){
  
  output$histogram <- renderPlot({
    dataHisto <- NULL
    dataHisto <- select(data,input$variableselected)
    xname <- input$variableselected
    hist(dataHisto, main="Histogram for selected variable") 
    
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
    
    l <- leaflet(map) %>% addTiles() %>% addProviderTiles("Esri")%>% addPolylines(
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