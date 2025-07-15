# server.R
library(shiny)
library(MyWGCNAResearchProject)
library(plotly)

server <- function(input, output, session) {
  wgcnaRes <- eventReactive(input$runBtn, {
    req(input$exprFile)
    expr <- loadExpressionData(input$exprFile$datapath)
    expr <- filterGenesByVariance(expr, topN = input$topVar)
    norm <- normalizeExpression(expr, method = input$normMethod)
    generateRobustDendrogram(
      exprData    = norm,
      deepSplit   = input$deepSplit,
      minModuleSize  = input$minModSize,
      mergeCutHeight = input$mergeHeight,
      bootstrap   = FALSE
    )
  })
  
  output$dendPlot <- renderPlot({
    req(wgcnaRes())
    # static plot is drawn inside generateRobustDendrogram()
    invisible()
  })
  
  output$dendPlotly <- renderPlotly({
    res <- wgcnaRes()
    plotInteractiveDendrogram(res$geneTree, res$stability)
  })
  
  output$modLegend <- renderUI({
    res <- wgcnaRes()
    cols <- unique(res$moduleColors)
    tags$div(
      lapply(cols, function(col) {
        tags$span(style = paste0("background:", col, ";padding:5px;margin:2px;display:inline-block;"), col)
      })
    )
  })
}
