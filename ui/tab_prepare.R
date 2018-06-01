
tags$style(".continue_transform_but{
            max-width: 100%;
           }")
tabPanel("Подготовка ряда",
         icon = icon("bar-chart"),
         
           sidebarLayout(
           sidebarPanel(
             helpText(
               "Проведите необходимые преобразования, чтобы добиться стационарности ряда"
             ),
             br(),
             actionLink("diff", "Обычное дифференцирование"),
             br(),
             
             actionLink("diff_lag", "Сезонное дифференцирование с лагом"),
             br(),
             actionLink("log", "Обычное логарифмирование"),
             br(),
             actionLink("boxcox", "Преобразование Бокса-Кокса"),
             #br(),
             #actionLink("de_trend", "Удаление тренда"),
             #br(),
             #actionLink("de_season", "Удаление сезонности"),
             br(),
             br(),
             br(),
             actionLink("removeTab", "Отменить последнее преобразование"),
             br(),
             actionLink("removeAll", "Отменить все преобразования"),
             br(),
             tags$hr(),
             numericInput("lag_input", "Лаг для сезонного дифференцирования", 1, min = 1, step = 1),
             tags$hr(),
             helpText(
               "Использовать преобразованные данные (ряд на последней вкладке) для прогнозирования?"
             ),
             actionButton("continue_transform_but", "Да, использовать",
                          style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"),
             bsPopover(id="continue_transform_but",title="Важно", content=continue_transform_but ,"right",options = list(container = "body"))
           ),
          
           mainPanel(tabsetPanel(id = "myTabs",
                                 type = "tabs"))
         ))