#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)

# Define UI for application that draws a histogram
ui <- fluidPage(

    pageWithSidebar(
        headerPanel('Iris k-means clustering'),
        sidebarPanel(
            selectInput('xcol', 'X Variable', names(iris)),
            selectInput('ycol', 'Y Variable', names(iris),
                        selected=names(iris)[[2]]),
            numericInput('clusters', 'Cluster count', 3,
                         min = 1, max = 9)
        ),
        mainPanel(
            plotOutput('plot1')
        )
    )
)

# Define server logic required to draw a histogram
server <- 
    
    function(input, output, session) {
        
        # Combine the selected variables into a new data frame
        selectedData <- reactive({
            iris[, c(input$xcol, input$ycol)]
        })
        
        clusters <- reactive({
            kmeans(selectedData(), input$clusters)
        })
        
        pal <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
                 "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999")
        
        output$plot1 <- renderPlot({
            ggplot(data = selectedData(), aes_string(x = input$xcol, y = input$ycol,
                                                     color=as.factor(clusters()$cluster))) +
                scale_color_manual(values=pal) +
                geom_point(show.legend=FALSE)
        })
        
    }

# Run the application 
shinyApp(ui = ui, server = server)
