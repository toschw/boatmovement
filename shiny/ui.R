library(shiny)
library(leaflet)
library(RColorBrewer)

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                selectInput("select","Show tracks of",
                            list(`boats operated outside Alaska before coming to Alaska` = list("NY", "NJ", "CT"),
                                 `boats Operated only in Alaska in 2018` = list(""),
                                 `all boats` = list("British Columbia","Washington","Kansas","Yukon Territories",""),
                                 selected = ""
                            ),
                            
                ),
                checkboxInput("legend", "Show legend", TRUE)
  )
)
