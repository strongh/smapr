#' View SMAP
#'
#' Starts a Shiny app for viewing SMAP data.
#' @param start
#' @param end
#' @keywords download
#' @export
#' @examples
#' shiny_smap()
shiny_smap <- function() {
  require(shiny)
  require(ggplot2)
  require(threejs)
  shinyApp(
    ui = fluidPage(
      titlePanel("SMAP Viewer"),

      sidebarLayout(
        sidebarPanel(
          helpText("Looking at SMAP soil moisture"),

          dateInput("date", label = h3("Date input"), value = "2015-06-18")
        ),

        mainPanel(
          tabsetPanel(type = "tabs",
                      tabPanel("SMAP map",
                               plotOutput("map")),
                      tabPanel("SMAP Globe",
                               globeOutput("globe"))

          )   )
      )
    ),
    server = function(input, output) {
      output$map <- renderPlot({
        ggplot(read.smap.l3(input$date, dataset.id = "SM_P"), aes(lon, lat)) + geom_raster(aes(fill=soil.moisture))
      })

      output$globe <- renderGlobe({
        df <- read.smap.l3(input$date, dataset.id = "SM_P", reproject = FALSE)

        df$q <- as.numeric(
          cut(df$soil.moisture,
              breaks=quantile(df$soil.moisture, probs=c(0,0.25,0.50,0.75,1)),
              include.lowest=TRUE))
        col = rev(c("#0055ff","#00aaff","#00ffaa","#aaff00"))[df$q]

        globejs(lat = df$lat,
                lon = df$lon,
                atmosphere = TRUE,
                pointsize = 1,
                color = col,
                val =1 / log(df$soil.moisture/(1-df$soil.moisture)))
      })
    }
  )
}
