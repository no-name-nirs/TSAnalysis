#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#library(shiny)
#library(data.table)
#library(dygraphs)
#library(shinyBS)

shinyUI(navbarPage(
  title = "Исследование временных рядов",
  navbarMenu(
    title = "Загрузка данных",
    source(file.path("ui", "tab_upload_ticker.R"), local = TRUE, encoding = "utf-8")$value,
    source(file.path("ui", "tab_upload_csv.R"), local = TRUE, encoding = "utf-8")$value
    ),
  source(file.path("ui", "tab_prepare.R"), local = TRUE, encoding = "utf-8")$value,
  source(file.path("ui", "tab_forecast.R"), local = TRUE, encoding = "utf-8")$value
))
