# app.R — entry point
library(shiny)
library(MyWGCNAResearchProject)

# Source UI and server
source(system.file("shiny/ui.R", package = "MyWGCNAResearchProject"), local = TRUE)
source(system.file("shiny/server.R", package = "MyWGCNAResearchProject"), local = TRUE)

# Launch
shinyApp(ui = ui, server = server)
