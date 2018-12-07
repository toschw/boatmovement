#Cerating shiny app with instructions found at https://paula-moraga.github.io/tutorial-shiny-spatial
#this file creates the Shiny app and from here the app is launched by clicking Run App in upper right of R Studio editor 

library(shiny)
library(rgdal)
library(DT)
library(dygraphs)
library(xts)
library(leaflet)

#_________________________________________________________________________________
#Read data
#We only need to read the data once so we write this code at the beginning of app.R outside the server() function. 
#By doing this, the code is not unnecessarily run more than once and the performance of the app is not decreased.

library(rgdal)
data <- read.csv("data/features.csv")
map <- readOGR("data/Boater_Joined_2/Boater_Joined_2.shp")


#_________________________________________________________________________________
#User interface or called ui object
ui <- fluidPage(
  titlePanel(p("Mapping responses from a survey with Alaska's registered boat owners, 2018", style="color:#3474A7")),
  sidebarLayout(
    sidebarPanel(
      p("Made with", a("Shiny", href = "http://shiny.rstudio.com"), "."),
      img(src = "imageShiny.png", width = "70px", height = "70px")),
    mainPanel(
      leafletOutput(outputId = "map"),
      #dygraphOutput(outputId = "timetrend"),
      DTOutput(outputId = "table")
    )
  )
)

#_________________________________________________________________________________
#Now we can add output
#input is a list-like object that stores the current values of the objects in the app. 
#output is a list-like object that stores instructions for building the R objects in the app. 
#Each element of output contains the output of a render*() function.
# server()
server <- function(input, output){
  output$table <- renderDT(data)
  
  #output$timetrend <- renderDygraph({
    
    #dataxts <- NULL
    #ounties <- unique(data$county)
    #for(l in 1:length(counties)){
     # datacounty <- data[data$county == counties[l],]
      #dd <- xts(datacounty[, "cases"], as.Date(paste0(datacounty$year,"-01-01")))
      #dataxts <- cbind(dataxts, dd)
    #}
    #colnames(dataxts) <- counties
    
    #dygraph(dataxts) %>% dyHighlight(highlightSeriesBackgroundAlpha = 0.2)-> d1
    
   # d1$x$css = "
   # .dygraph-legend > span {display:none;}
   # .dygraph-legend > span.highlight { display: inline; }
   # "
   # d1
 # })
  
  output$map <- renderLeaflet({
    
    # Add data to map
    #datafiltered <- data[which(data$primaryPur == "Sport Fishing"), ]
    #ordercounties <- match(map@data$responseID, datafiltered$responseID)
   # map@data <- datafiltered[ordercounties, ]
    map@data <- data
    # Create leaflet
    pal <- colorBin("YlOrRd", domain = map$LenghtKM, bins = 7)
    
    labels <- sprintf("%s: %g", map$responseID, map$LenghtKM) %>% lapply(htmltools::HTML)
    
    l <- leaflet(map) %>% addTiles() %>% addProviderTiles("Esri")%>% addPolylines(
      stroke = TRUE, 
      color = "green", 
      weight = 2,
      opacity = 1.0, 
      fill = FALSE, 
      fillColor = ~pal(LenghtKM),
      fillOpacity = 0.4, 
      label = labels) %>%
      leaflet::addLegend(pal = pal, values = ~LenghtKM, opacity = 0.7, title = NULL)
    # write leaflet::addLegend to avoid Error object '.xts_chob' not found
  })
}

# shinyApp()
shinyApp(ui = ui, server = server)