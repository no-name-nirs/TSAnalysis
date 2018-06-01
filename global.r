library(shiny)

#libraries for ui
library(data.table)
library(dygraphs)
library(shinyBS)


#libraries for server
library(quantmod)
library(devtools)
#library(shinypod) #devtools::install_github("ijlyttle/shinypod")
#library(shinyjs)
#library(dplyr)
library(DT)

#библиотека для преобразования времени и даты
library(flipTime) #devtools::install_github("Displayr/flipTime")

library(ggplot2)
library(forecast)
library(plotly)
library(ggfortify)
library(tseries)
library(gridExtra)
library(docstring)
library(readr)
library(here)
library(stats)
library(rlist)
library(bimixt)
library(stringi)
library(tstools)
library(nnfor)
library(tseries)


encoding = "utf-8"
#Sys.setlocale("LC_CTYPE","russian")
#следующая строка позволяет вводить тексты с буквой "я"
#в отличие от строки выше
Sys.setlocale("LC_ALL", "Russian_Russia.20866")

#для амазона
library(aws.s3)

# Yo, don't share this stuff!
Sys.setenv("AWS_ACCESS_KEY_ID" = "AKIAILKMZFVIP52F5TZA",
           "AWS_SECRET_ACCESS_KEY" = "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")
aws_bucket <- "tsanalysis1"

# These are functions that we'll use to access and edit the data
save_db <- function(dat, bucket=aws_bucket){
  dat <- dat
  if(exists("mydata")) dat <- rbind(mydata$x, dat)
  s3save(dat, bucket=bucket, object="data.Rda")
}
load_db <- function(){
  s3load("data.Rda", aws_bucket)
  return(dat)
}

source(file.path("server", "all_sessions.R"), local = TRUE, encoding = "utf-8")
source(file.path("src", "help_functions.R"), local = TRUE, encoding = "utf-8")
source(file.path("src", "modules.R"), local = TRUE, encoding = "utf-8")
source(file.path("src", "models.R"), local = TRUE, encoding = "utf-8")

