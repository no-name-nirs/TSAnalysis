tabPanel("Загрузка с тикером",
         tags$head(tags$style(
           HTML("
                .shiny-output-error-validation {
                color: #337ab7;
                }
                hr {border-top: 1px solid #000000;}
                ")
           )),
         sidebarLayout(
           sidebarPanel(
             h4("Данные с Yahoo Finance"),
             helpText("После ввода тикера нажмите кнопку загрузки"),
             textInput("symb", "Тикер", "GOOG"),
             bsPopover(id="symb",title="Что это?", content=symb,"right",options = list(container = "body")),
             tags$hr(),
             helpText("Далее укажите необходимые данные и временной промежуток (по умолчанию data.Close) и нажмите кнопку загрузки"),
             selectInput("var_dropdown", "Конкретный ряд", ''),
             dateRangeInput(
               "dates",
               "Временной промежуток",
               start = "2013-01-01",
               end = as.character(Sys.Date())
             ),
             br(),
             actionButton("upload_tick", "Загрузить данные",
                          style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"),
             br(),
             br(),
             span(textOutput("success"), style = "color: #337ab7"),
             tags$hr(),
             helpText("Использовать ряд для дальнейшего анализа?"),
             actionButton("continue_tick_but", "Да, использовать",
                          style = "color: #fff; background-color: #337ab7; border-color: #2e6da4")
           ),
           mainPanel(
             span(textOutput("text1"), style = "color: #337ab7"),
             dygraphOutput("ini_dygraph")
           )
         ))