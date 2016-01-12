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

          dateInput("date", label = h3("Date input"), value = "2015-06-18"),
          checkboxInput("is.global", "Get global data (over several days)", FALSE),
          selectInput("dataset.id", "SMAP product:",
                      c("Radar + Radiometer, 9km, SM_AP" = "SM_AP",
                        "Radiometer, 36km, SM_P" = "SM_P"), "SM_P")
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
        dataset.id <- input$dataset.id
        df <- if(input$is.global)
          global.smap.l3(input$date, dataset.id = dataset.id, reproject = FALSE)
        else
          read.smap.l3(input$date, dataset.id = dataset.id, reproject = FALSE)
        ggplot(df, aes(lon, lat)) + geom_raster(aes(fill=soil.moisture))
      })

      output$globe <- renderGlobe({
        dataset.id <- input$dataset.id
        df <- if(input$is.global)
          global.smap.l3(input$date, dataset.id = dataset.id, reproject = FALSE)
        else
          read.smap.l3(input$date, dataset.id = dataset.id, reproject = FALSE)

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
