tabPanel(
  "Загрузка CSV-файла",
  tags$head(tags$style(
    HTML(
      "
      .shiny-output-error-validation {
      color: #337ab7;
      }
      hr {border-top: 1px solid #000000;}
      "
    )
    )),
  sidebarLayout(
    sidebarPanel(
      helpText("Столбец с датой и временем сделайте в файле первым"),
      fileInput(
        "file1",
        "Выберите CSV-файл",
        multiple = FALSE,
        accept = c("text/csv",
                   "text/comma-separated-values,text/plain",
                   ".csv")
      ),
      helpText("Скачать данные можно, например, ",
        a("здесь",     
          href="https://fred.stlouisfed.org/series/LNU03000000"
          )),
      tags$hr(),
      
      #есть ли header
      checkboxInput("header", "Есть ли заголовок в файле?", TRUE),
      
      #разделитель
      radioButtons(
        "sep",
        "Разделитель",
        choices = c(
          "Запятая" = ",",
          "Точка с запятой" = ";",
          "Табуляция" = "\t"
        ),
        selected = ","
      ),
      
      #кавычки
      radioButtons(
        "quote",
        "Вид кавычек",
        choices = c(
          "Нет" = "",
          "Двойные" = '"',
          "Одинарные" = "'"
        ),
        selected = '"'
      ),
      
      tags$hr(),
      
      #Просмотр файла
      radioButtons(
        "disp",
        "Просмотр файла",
        choices = c(Частично  = "Частично",
                            Полностью  = "Полностью"),
        selected = "Частично"
      ),
      tags$hr(),
      #Выбор конкретного ряда
      selectInput("var_select_csv", "Выберите один ряд", ''),
      br(),
      span(htmlOutput("success_csv"), style = "color: #337ab7"),
      tags$hr(),
      helpText("Использовать ряд для дальнейшего анализа?"),
      actionButton("continue_csv_but", "Да, использовать",
                   style = "color: #fff; background-color: #337ab7; border-color: #2e6da4")
    ),
    
    mainPanel(
      span(textOutput("text_error_csv"), style = "color: #337ab7"),
      br(),
      dataTableOutput("contents"),
      br(),
      dygraphOutput("csv_dygraph"),
      br(),
      br()
      )
  )
    )