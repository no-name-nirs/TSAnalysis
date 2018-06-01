#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#library(quantmod)



shinyServer(function(input, output, session) {
  #переменная для передачи данных
  ts_data <- reactiveValues(list = list("Исходный ряд" = NULL), lambda = list(), lag = list())
  
  
  source(file.path("server", "upload_ticker.R"),
         local = TRUE,
         encoding = "utf-8")$value
  source(file.path("server", "upload_csv.R"),
         local = TRUE,
         encoding = "utf-8")$value
  source(file.path("server", "prepare.R"),
         local = TRUE,
         encoding = "utf-8")$value
  source(file.path("server", "forecast.R"),
         local = TRUE,
         encoding = "utf-8")$value

})
