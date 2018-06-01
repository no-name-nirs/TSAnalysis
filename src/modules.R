#создание dygraphs
dyOutput <- function(id) {
  ns <- NS(id)
  tagList(dygraphOutput(ns("dyGr")))
}

dyOutputServer <- function(input, output, session, data) {
  output$dyGr <- renderDygraph({
    tryCatch({
      dygraph(data) %>%
        dySeries(color = "#337ab7")
    }, error = function(e) {
      return()
      print(e)
      showNotification("Что-то пошло не так", type = "error")
    })
    
  })
}

# ------ панель преобразования  -------------------------------------------------
#новая панель при подготовки ряда
tabContent <- function(id) {
  ns <- NS(id)
  tagList(
    br(),
    wellPanel(
      h4(tags$b("Критерии для проверки стационарности")),
      htmlOutput(ns("criter"))
      ),
    column(
      6,
      h4(tags$b("Результат")),
      br(),
      dyOutput(ns("gr")),
      br(),
      h4(tags$b("Тренд")),
      br(),
      dyOutput(ns("trend")),
      br(),
      br()
    ),
    column(
      6,
      h4(tags$b("Сезонность")),
      br(),
      dyOutput(ns("seasonal")),
      br(),
      h4(tags$b("Остатки")),
      br(),
      dyOutput(ns("random")),
      br(),
      br()
    ),
    h4(tags$b(
      "Автокорреляция и частичная автокорреляция"
    )),
    br(),
    plotOutput(ns("acf_pacf"))
    
  )
}

tabContentServer <- function(input, output, session, data1, transform = "null", smth = "null") {
  dec <- reactive({
    d <- decompose.xts(data1)
  })
  
  callModule(dyOutputServer, "gr", data = data1)
  callModule(dyOutputServer, "trend", data = dec()$trend)
  callModule(dyOutputServer, "seasonal", data = dec()$seasonal)
  callModule(dyOutputServer, "random", data = dec()$random)
  output$acf_pacf <- renderPlot({
    plot_acf_pacf(data1)
  })
  output$criter <- renderUI({
    str1 <-
      paste("Критерий Дики-Фуллера: p-value = ",
            adf.test(data1)$p.value)
    str2 <-
      paste("Критерий KPSS: p-value = ", kpss.test(data1)$p.value)
    if (transform == "boxcox")
      str3 <- paste("Оптимальное преобразование при лямбда = ", smth)
    else if (transform == "diff_lag")
      str3 <- paste("lag = ", smth)
    else str3 <- paste("")  
      
    HTML(paste(str1, str2, str3, sep = '<br/>'))
  })
}

# ------------------------------------------------------------------


#---------    создание табов моделей    ----------------------------
#новая панель при подготовки ряда
tabModel <- function(id) {
  ns <- NS(id)
  tagList(
    br(),
    h4(tags$b("График реальных и предсказанных значений")),
    dygraphOutput(ns("graph")),
    #br(),
    #h4(tags$b("Информация по модели")),
    #wellPanel(htmlOutput(ns("summary"))),
    br(),
    h4(tags$b("Оценка качества")),
    dataTableOutput(ns("metrics")),
    br(),
    h4(tags$b("Остатки")),
    dyOutput(ns("resid")),
    br(),
    br()
  )
}

#model - просто название модели string
tabModelServer <- function(input, output, session, data, model_name, ts_data) {
  if (!is.null(data)) {
    data <- data
    
    train <- split_ts(data)$train
    test <- split_ts(data)$test
    freq <- split_ts(data)$freq
    
    pred <- model_switch(train, test, freq, model_name)$pred
    model1 <- model_switch(train, test, freq, model_name)$model
    #обратные преобразования к реальным значениям
    pred <- unboxcox(pred, ts_data$lambda)
    pred <- undiff(ts_data$list[["Исходный ряд"]], pred, ts_data$lag)
    
    
    pred_data <- data.frame(date = index(test),
                            Forecast = pred$mean,
                            Hi_80 = pred$upper[,2],
                            Lo_80 = pred$lower[,2])
    pred_data_xts <- xts(pred_data[,-1], order.by = pred_data[,1])
    fitted_data <- data.frame(date = index(train), Fitted = pred$fitted)
    fitted_data_xts <- xts(fitted_data[,-1], order.by = fitted_data[,1])
    
    data_combined_xts <- cbind(ts_data$list[["Исходный ряд"]], fitted_data_xts, pred_data_xts)
    colnames(data_combined_xts)[1] <- "Временной ряд"
    colnames(data_combined_xts)[2] <- "Модель на обучающей выборке"
    colnames(data_combined_xts)[3] <- "Модель на тестовой выборке"
    colnames(data_combined_xts)[4] <- "Верхняя граница 95% дов. инт."
    colnames(data_combined_xts)[5] <- "Нижняя граница 95% дов. инт."
    
    
    output$graph <- renderDygraph({
      dygraph(data_combined_xts)
    })
    
    output$metrics <- renderDataTable({
      myAccuracy <- accuracy(pred)
      
      myAccuracy <- as.data.frame(as.table(myAccuracy))
      
      myAccuracy <- myAccuracy %>%
        select(metric = Var2, value = Freq) %>%
        mutate(value = round(value, 3))
    })
    
    resid_data <- data.frame(date = index(train), resid = pred$residuals)
    resid_data_xts <- xts(resid_data[,-1], order.by = resid_data[,1])
    
    callModule(dyOutputServer, "resid", data = resid_data_xts)
  }
  else {
    showNotification("Ошибка: загрузите, пожалуйста, данные", type = "error")
  }
  
}
#---------------------------------------------------------------------------