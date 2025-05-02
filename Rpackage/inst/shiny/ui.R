# ui.R
library(shiny)
library(plotly)

ui <- fluidPage(
  titlePanel("Robust WGCNA Explorer"),
  sidebarLayout(
    sidebarPanel(
      fileInput("exprFile", "Upload Expression CSV", accept = ".csv"),
      selectInput("normMethod", "Normalize using:", choices = c("log2", "vst")),
      sliderInput("topVar", "Top N variable genes:", min = 1000, max = 20000, value = 10000, step = 1000),
      actionButton("runBtn", "Run WGCNA"),
      hr(),
      numericInput("deepSplit", "Tree cut deepSplit (0–4):", value = 2, min = 0, max = 4),
      numericInput("minModSize", "Min module size:", value = 30, min = 5, max = 200),
      numericInput("mergeHeight", "Module merge height:", value = 0.25, min = 0, max = 1, step = 0.05)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Dendrogram", plotOutput("dendPlot")),
        tabPanel("Interactive", plotlyOutput("dendPlotly")),
        tabPanel("Module Colors", uiOutput("modLegend"))
      )
    )
  )
)
