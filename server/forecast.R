observeEvent(input$getModels, {
  tryCatch({
    data <- ts_data$ts_transform
    withProgress(message = 'Построение моделей',
                 value = 0, {
                   for (i in 1:length(models)) {
                     model <- models[i]
                     appendTab("myModels",
                               tabPanel(model,
                                        tabModel(model)))
                     callModule(tabModelServer,
                                model,
                                data = data,
                                model_name = model,
                                ts_data = ts_data)
                     
                     incProgress(1 / length(models), detail = paste("Строится модель ", i))
                     Sys.sleep(0.1)
                   }
                 })
  },
  error = function(e) {
    print(e)
    showNotification("Что-то пошло не так", type = "error")
  }
  )
  
})
