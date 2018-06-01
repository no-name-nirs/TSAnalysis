
#клик на кнопку
dataInput <- eventReactive(input$upload_tick, {
  output$text1 <- renderText({
    paste("")
  })
  output$sucess <- renderText({
    paste("")
  })
  validate(
    need(input$symb, "Введите тикер"),
    need(
      input$dates[1] < input$dates[2],
      "Неправильный временной промежуток. Попробуйте еще раз!"
    )
  )
  tryCatch({
    data <- getSymbols(
      input$symb,
      src = "yahoo",
      from = input$dates[1],
      to = input$dates[2],
      auto.assign = FALSE
    )
    output$text1 <- renderText({
      paste("")
    })
    output$success <- renderText({
      paste("Данные успешно загружены")
    })
    
    var_selected <- names(data)[4]
    updateSelectInput(session,
                      "var_dropdown",
                      choices = names(data),
                      selected = var_selected)
    
    if (input$var_dropdown != "")
      var_selected <- input$var_dropdown
    updateSelectInput(session,
                      "var_dropdown",
                      choices = names(data),
                      selected = var_selected)

    return(data[, var_selected])
    
  },
  error = function(e) {
    ts_data$list[["Исходный ряд"]] <- NULL
    if (input$symb != "")
      output$text1 <-
        renderText({
          paste("Ошибка: ",
                input$symb,
                " - неверный тикер. Попробуйте еще раз!")
        })
    output$success <- renderText({
      paste("Данные не загружены")
    })
    return(NULL)
  })
})

observe({
  input$symb
  output$text1 <- renderText({
    paste("")
  })
  updateSelectInput(session, "var_dropdown", choices = '')
})

observeEvent(input$upload_tick, {
  output$ini_dygraph <- renderDygraph({
    if (!is.null(dataInput()))
      dygraph(dataInput()) %>%
      dySeries(color = "#337ab7")
  })
})

observeEvent(input$continue_tick_but, {
  tryCatch({
    d <- dataInput()
    if (!is.null(d)) {
      freq <- switch(periodicity(d)$scale,
                     daily=365,
                     weekly=52,
                     monthly=12,
                     quarterly=4,
                     yearly=1)
      attr(d, 'frequency') <- freq
      
      #сохранение ряда в переменную reactiveValues
      list.clean(ts_data$lambda)
      list.clean(ts_data$lag)
      ts_data$list[["Исходный ряд"]] <- d
      ts_data$ts_transform <- d
      for(model in models) {
        removeTab("myModels", target = model)
      }
      #заполнение первой вкладки таба преобразований
      callModule(tabContentServer, "initial", data = ts_data$list[["Исходный ряд"]])
      showNotification("Успешно, переходите к подготовке ряда", type = 'message')
    }
  },
  error = function(e){
    #ts_data$lambda <- NULL
    ts_data$list[["Исходный ряд"]] <- NULL
    showNotification("Что-то пошло не так", type = 'error')
  }
  )
})