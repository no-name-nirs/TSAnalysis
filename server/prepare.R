appendTab("myTabs",
          tabPanel("Исходный ряд",
                   tabContent("initial")))

#-----  diff ------ +
tabIndexDiff <- reactiveVal(0)
observeEvent(input$diff, {
  tabIndexDiff(tabIndexDiff() + 1)
  
  tab_name <- paste0("diff_", toString(isolate(tabIndexDiff())))
  
  previous_data <- list.last(isolate(ts_data$list))
  current_data <- na.omit(diff(previous_data))
  
  ts_data$list[[tab_name]] <- current_data
  ts_data$lag[[tab_name]] <- 1
  print(ts_data$lag)
  appendTab("myTabs",
            tabPanel(tab_name,
                     tabContent(tab_name)))
  callModule(tabContentServer, tab_name, data = current_data)
})

#-----  diff_lag ------ +
tabIndexDiffLag <- reactiveVal(0)
observeEvent(input$diff_lag, {
  if (!is.null(input$lag_input)) {
    tryCatch({
      tabIndexDiffLag(tabIndexDiffLag() + 1)
      
      tab_name <-
        paste0("diff_lag_", toString(isolate(tabIndexDiffLag())))
      
      previous_data <- list.last(isolate(ts_data$list))
      current_data <-
        na.omit(diff(previous_data, lag = input$lag_input))
      
      ts_data$list[[tab_name]] <- current_data
      ts_data$lag[[tab_name]] <- input$lag_input
      print(ts_data$lag)
      appendTab("myTabs",
                tabPanel(tab_name,
                         tabContent(tab_name)))
      callModule(tabContentServer, tab_name, data = current_data, transform = "diff_lag", smth = input$lag_input)
    },
    error = function(e) {
      showNotification("Что-то пошло не так, попробуйте снова", type = "error")
    })
  }
  else {
    showNotification("Проверьте правильность введеного лага", type = "error")
  }
})

#-----  log ------ +
tabIndexLog <- reactiveVal(0)
observeEvent(input$log, {
  tabIndexLog(tabIndexLog() + 1)
  
  tab_name <- paste0("log_", toString(isolate(tabIndexLog())))
  
  previous_data <- list.last(isolate(ts_data$list))
  current_data <- na.omit(log(previous_data))
  
  ts_data$list[[tab_name]] <- current_data
  
  #частный случай бокса-кокса
  ts_data$lambda[[tab_name]] <- 0
  print(ts_data$lambda)
  appendTab("myTabs",
            tabPanel(tab_name,
                     tabContent(tab_name)))
  callModule(tabContentServer, tab_name, data = current_data)
})

#-----  boxcox ------ +
tabIndexBoxCox <- reactiveVal(0)
observeEvent(input$boxcox, {
  tabIndexBoxCox(tabIndexBoxCox() + 1)
  
  tab_name <- paste0("boxcox_", toString(isolate(tabIndexBoxCox())))
  
  previous_data <- list.last(isolate(ts_data$list))
  lambda <- BoxCox.lambda(previous_data)
  current_data <- na.omit(BoxCox(previous_data, lambda = lambda))
  
  ts_data$list[[tab_name]] <- current_data
  ts_data$lambda[[tab_name]] <- lambda
  print(ts_data$lambda)
  appendTab("myTabs",
            tabPanel(tab_name,
                     tabContent(tab_name)))
  callModule(tabContentServer, tab_name, data = current_data, transform = "boxcox", smth = lambda)
})

#-----  de_trend ------ +
tabIndexTrend <- reactiveVal(0)
observeEvent(input$de_trend, {
  tabIndexTrend(tabIndexTrend() + 1)
  
  tab_name <- paste0("de_trend_", toString(isolate(tabIndexTrend())))
  
  #удаление тренда
  previous_data <- list.last(isolate(ts_data$list))
  dec <- decompose.xts(previous_data)
  current_data <- na.omit(previous_data - dec$trend)
  
  ts_data$list[[tab_name]] <- current_data
  
  appendTab("myTabs",
            tabPanel(tab_name,
                     tabContent(tab_name)))
  callModule(tabContentServer, tab_name, data = current_data)
})

#-----  de_season ------ +
tabIndexSeason <- reactiveVal(0)
observeEvent(input$de_season, {
  tabIndexSeason(tabIndexSeason() + 1)
  
  tab_name <- paste0("de_season_", toString(isolate(tabIndexSeason())))
  
  #удаление сезонности
  previous_data <- list.last(isolate(ts_data$list))
  dec <- decompose.xts(previous_data)
  current_data <- na.omit(previous_data - dec$seasonal)
  
  ts_data$list[[tab_name]] <- current_data
  
  appendTab("myTabs",
            tabPanel(tab_name,
                     tabContent(tab_name)))
  callModule(tabContentServer, tab_name, data = current_data)
})

#отмена последнего преобразования
observeEvent(input$removeTab, {
  if (length(ts_data$list) > 1) {
    #название последнего преобразования
    last_tab_name <- list.last(list.names(ts_data$list))
    #удаление последнего преобразования из листа
    ts_data$list[length(ts_data$list)] <- NULL
    if (stri_sub(last_tab_name, 1, 6) == "boxcox") {
      ts_data$lambda[[last_tab_name]] <- NULL
    }
    if (stri_sub(last_tab_name, 1, 3) == "log") {
      ts_data$lambda[[last_tab_name]] <- NULL
    }
    if (stri_sub(last_tab_name, 1, 8) == "diff_lag") {
      ts_data$lag[[last_tab_name]] <- NULL
    }
    if (stri_sub(last_tab_name, 1, 4) == "diff") {
      ts_data$lag[[last_tab_name]] <- NULL
    }
    #визуальное удаление последней вкладки
    removeTab("myTabs", target = last_tab_name)
  }
})


#отмена всех преобразований
observeEvent(input$removeAll, {
  if (length(ts_data$list) > 1) {
    #названия всех вкладок
    tab_names <- list.names(ts_data$list)
    #удалить все кроме исходного
    ts_data$list[-1] <- NULL
    ts_data$lambda <- NULL
    ts_data$lag <- NULL
    print(ts_data$lambda)
    print(ts_data$lag)
    #визуальное удаление всех вкладок кроме первой
    for(tab in tab_names[-1]) {
      removeTab("myTabs", target = tab)
    }
  }
})

#при изменении ряда (загрузки нового) удаляются все вкладки
observeEvent(list(input$continue_tick_but, input$continue_csv_but),  
             {
  if (length(isolate(ts_data$list)) > 1) {
    #названия всех вкладок
    tab_names <- list.names(isolate(ts_data$list))
    #удалить все кроме исходного
    ts_data$list[-1] <- NULL
    ts_data$lambda <- NULL
    ts_data$lag <- NULL
    #визуальное удаление всех вкладок кроме первой
    for(tab in tab_names[-1]) {
      removeTab("myTabs", target = tab)
    }
  }
})

#сохранение преобразованного ряда
observeEvent(input$continue_transform_but, {
  tryCatch({
    print(ts_data$ts_transform)
      ts_data$ts_transform <- isolate(list.last(ts_data$list))
      #print("-------")
      #print(ts_data$ts_transform)
      for(model in models) {
        removeTab("myModels", target = model)
      }
      showNotification("Данные успешно преобразованы, переходите к прогнозированию", type = 'message')
  },
  error = function(e){
    showNotification("Что-то пошло не так, попробуйте еще раз", type = 'error')
  }
  )
})


