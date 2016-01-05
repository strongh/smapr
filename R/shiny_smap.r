#' View SMAP
#'
#' Starts a Shiny app for viewing SMAP data.
#' @param start
#' @param end
#' @keywords download
#' @export
#' @examples
#' shiny_smap("2015-09-11")
shiny_smap <- function() {
  require(shiny)
  require(ggplot2)
  shinyApp(
    ui = fluidPage(
      titlePanel("SMAP Viewer"),

      sidebarLayout(
        sidebarPanel(
          helpText("Looking at SMAP soil moisture"),

          dateInput("date", label = h3("Date input"), value = "2015-04-24")
        ),

        mainPanel(
          tabsetPanel(type = "tabs",
                      tabPanel("SMAP map",
                               plotOutput("map"))

          )   )
      )
    ),
    server = function(input, output) {
      output$map <- renderPlot({
        ggplot(read.smap.l3(input$date), aes(lon, lat)) + geom_raster(aes(fill=soil.moisture))

      })
    }
  )
}
