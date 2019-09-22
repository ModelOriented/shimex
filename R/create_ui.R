#' creates ui.R
#'
#' creates string for ui.R file.
#'
#' @param vars list of class of predictors.

.create_ui <- function(vars){

  body <- "
  library(shiny)

  shinyUI(fluidPage(
    theme = 'style.css',
    shinyjs::useShinyjs(),

    # ---- Sidebar
    sidebarLayout(
      sidebarPanel(
        selectInput(
          inputId = 'selected_columns',
          label = 'Select variables',
          choices = colnames(data),
          selected = selected_variables,
          multiple = T
        ),

        tags$hr(),
    uiOutput('vars_input'),
        width = 3
      ), #-- sidebarPanel

    mainPanel( width = 9,
        navbarPage(
          'Model Explorer',
          position = 'fixed-top',
          inverse = T,
          tabPanel('CeterisParibus',
                   withSpinner(uiOutput('CP'), color = '#4a3c89')),

          tabPanel('BreakDown',
            withSpinner(plotOutput('BreakDown'), color = '#4a3c89'),
                        htmlOutput('BD_describe')),

          tabPanel('Shap',
            h4('iBreakDown package'),
            withSpinner(plotOutput('Shap_iBD'), color = '#4a3c89'),
            br(),
            h4('iml package'),
            withSpinner(plotOutput('Shapley'), color = '#4a3c89')),

          tabPanel('shapeR',
            withSpinner(plotOutput('shapeR'), color = '#4a3c89')),

          tabPanel('Localmodel',
            withSpinner(plotOutput('LocalModel'), color = '#4a3c89')),

          tabPanel('Lime',
            h4('ingredients package'),
            fluidRow(withSpinner(plotOutput('Lime_ingr'), color = '#4a3c89')),
            br(),
            h4('iml package'),
            tags$div(
              class = 'box',
              numericInput(
                'lime_n_vars',
                label = 'Max number of features to be used for the surrogate model.',
                value = 3,
                min = 1,
                max = ncol(data) - 1
              )
            ),
            fluidRow(withSpinner(plotOutput('Lime'), color = '#4a3c89'))
        )
        )
      )
    ) # -- sidebarLayout
  ) # --fluidPage
) # -- shinyUI"

body

}


