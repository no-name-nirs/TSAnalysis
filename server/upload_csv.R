data_file <- reactive({
  # input$file1 will be NULL initially. After the user selects
  # and uploads a file, head of that data file by default,
  # or all rows if selected, will be shown.
  
  req(input$file1)
  
  # when reading semicolon separated files,
  # having a comma separator causes `read.csv` to error
  tryCatch({
    output$text_error_csv <-
      renderText({
        paste("")
      })
    
    df <- read.csv(
      input$file1$datapath,
      header = input$header,
      sep = input$sep,
      quote = input$quote
    )
  },
  error = function(e) {
    output$text_error_csv <-
      renderText({
        paste("Что-то пошло не так, попробуйте еще раз")
      })
    output$success_csv <- renderText({
      paste("Данные не загружены")
    })
  })
})

filename <- reactive({
  # input$file1 will be NULL initially. After the user selects
  # and uploads a file, head of that data file by default,
  # or all rows if selected, will be shown.
  
  req(input$file1)
  
  # when reading semicolon separated files,
  # having a comma separator causes `read.csv` to error
  tryCatch({
    return(input$file1$name)
  },
  error = function(e) {
    output$text_error_csv <-
      renderText({
        paste("Что-то пошло не так, попробуйте еще раз")
      })
    output$success_csv <- renderText({
      paste("Данные не загружены")
    })
  })
})

#заполнение таблицы
output$contents <- renderDataTable({
  if (!is.null(data_file()))
    if (input$disp == "Частично") {
      df <- head(data_file())
    }
  else {
    df <- data_file()
  }
  datatable(data = df,
            options = list(scrollX = TRUE))
})

#формирование выпадающего списка
observe({
  input$file1
  updateSelectInput(
    session,
    "var_select_csv",
    choices = names(data_file())[-1],
    selected = names(data_file())[2]
  )
})

#построение графика
observeEvent(input$var_select_csv, {
  tryCatch({
    output$text_error_csv <-
      renderText({
        paste("")
      })
    
    df <- data_file()
    if (input$var_select_csv != "")
      var_selected <- input$var_select_csv
    else
      var_selected <- 1
    
    df_dates <- AsDateTime(df[, 1])
    #проверка выбираемого ряда на численный тип
    if (!sapply(df[, var_selected], is.numeric))
      stop(e)
    
    df_xts <- xts(df[, var_selected], order.by = df_dates)
    output$csv_dygraph <- renderDygraph({
      if (!is.null(df))
        dygraph(df_xts, main = var_selected) %>% 
        dyRangeSelector() %>% 
        dySeries("V1", label = var_selected, color = "#337ab7")
    })
    
    output$success_csv <- renderText({
      paste(
        "<b>Данные успешно загружены</b>",
        "<br>",
        "<b>Файл:</b> ",
        filename(),
        "<br>",
        "<b>Ряд:</b> ",
        var_selected
      )
    })
  },
  error = function(e) {
    output$success_csv <- renderText({
      paste("Данные не загружены")
    })
    if (!is.null(input$file1))
      output$text_error_csv <-
        renderText({
          paste(
            "Что-то пошло не так, попробуйте еще раз. Проверьте настройки заголовка, разделителя и кавычек. Убедитесь, что выбран числовой ряд."
          )
        })
    else
      output$text_error_csv <-
        renderText({
          paste("")
        })
  })
})

#выбор этого ряда для анализа
observeEvent(input$continue_csv_but, {
  tryCatch({
    df <- data_file()
    if (input$var_select_csv != "")
      var_selected <- input$var_select_csv
    else
      var_selected <- 1
    df_dates <- AsDateTime(df[, 1])
    
    #проверка выбираемого ряда на численный тип
    if (!sapply(df[, var_selected], is.numeric))
      stop(e)
    d <- xts(df[, var_selected], order.by = df_dates)
    
    if (!is.null(d)) {
      freq <- switch(periodicity(d)$scale,
                     daily=365,
                     weekly=52,
                     monthly=12,
                     quarterly=4,
                     yearly=1)
      attr(d, 'frequency') <- freq
      list.clean(ts_data$lambda)  
      list.clean(ts_data$lag) 
      #сохранение ряда в переменную reactiveValues
      ts_data$list[["Исходный ряд"]] <- d
      ts_data$ts_transform <- d
      for(model in models) {
        removeTab("myModels", target = model)
      }
      callModule(tabContentServer, "initial", data = ts_data$list[["Исходный ряд"]])
      showNotification("Успешно, переходите к подготовке ряда", type = 'message')
    }
  },error = function(e) {
    #ts_data$lambda <- NULL
    ts_data$list[["Исходный ряд"]] <- NULL
    showNotification("Что-то пошло не так", type = 'error')
  })
})