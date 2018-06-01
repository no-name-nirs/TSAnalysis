tabPanel("Прогнозирование",
         icon = icon("line-chart"),
         sidebarLayout(sidebarPanel(
           helpText(
             "Если вы загрузили новые данные или провели преобразования ряда, то нажмите кнопку ниже"
           ),
           br(),
           actionButton("getModels", "Построить модели",
                        style = "color: #fff; background-color: #337ab7; border-color: #2e6da4")
         ),
         
         
         mainPanel(tabsetPanel(id = "myModels",
                               type = "tabs"
                              ))
         ))