#' creates ui.R
#'
#' creates string for ui.R file.
#'
#' @param vars list of class of predictors.
#' @param all logical values, if TRUE extra tab is creating showing all explainers together.

.create_ui <- function(vars, all){

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

    mainPanel(
        navbarPage(
          'Model Explorer',
          position = 'fixed-top',
          inverse = T,

          tabPanel('CeterisParibus',
                   div(
                     column(8, h4('Numerical Variables')),
                     column(4, actionButton('decribe_cp', 'Describe Plots'), align = 'right')
                      ),
           br(),
            withSpinner(plotOutput('CeterisParibus'), color = '#4a3c89'),
           br(),
           h4('Factor Variables'),
           br(),
            withSpinner(plotOutput('CeterisParibus_factor'), color = '#4a3c89'),
           br()
           ),

          tabPanel('BreakDown',
            p(actionButton('decribe_bd', 'Describe Plot'), align = 'right'),
            withSpinner(plotOutput('BreakDown'), color = '#4a3c89')),

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
          %s # <<all_explainers>>
        ),
          bsModal('describe_cp', 'Ceteris Paribus Description', 'decribe_cp', htmlOutput('CP_describe')),
          bsModal('describe_bd', 'Ceteris Paribus Description', 'decribe_bd', htmlOutput('BD_describe'))
      )
    ) # -- sidebarLayout
  ) # --fluidPage
) # -- shinyUI"

  all_expl_ui <- if(all) {
    ",
  tabPanel('All',
           withSpinner(plotOutput('CeterisParibus1'), color = '#4a3c89'),
           withSpinner(plotOutput('BreakDown1'), color = '#4a3c89'),
           withSpinner(plotOutput('Shapley1'), color = '#4a3c89'),
           withSpinner(plotOutput('shapeR1'), color = '#4a3c89'),
           withSpinner(plotOutput('LocalModel1'), color = '#4a3c89'),
           withSpinner(plotOutput('Lime1'), color = '#4a3c89'))"
  } else ""

  sprintf( body,
           all_expl_ui)
}


