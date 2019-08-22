#' creates ui.R
#'
#' creates string for ui.R file.
#'
#' @param factor_vars vector of strings containing names of factor variables.
#' @param cont_vars vector of strings containing names of continous variables.
#' @param all logical values, if TRUE extra tab is creating showing all explainers together.

.create_ui <- function(factor_vars, cont_vars, all){

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
          choices = colnames(data[,-1]),
          selected = selected_variables,
          multiple = T
        ),

        tags$hr(),
        %s % s
        %s,
        width = 3
      ), #-- sidebarPanel

    mainPanel(
        navbarPage(
          'Model Explorer',
          position = 'fixed-top',
          inverse = T,
          tabPanel('CeterisParibus',
            withSpinner(plotOutput('CeterisParibus'),
            color = '#4a3c89')),
          tabPanel('BreakDown',
            withSpinner(plotOutput('BreakDown'), color = '#4a3c89')),
          tabPanel('Shap',
            withSpinner(plotOutput('Shapley'), color = '#4a3c89')),
          tabPanel('shapeR',
            withSpinner(plotOutput('shapeR'), color = '#4a3c89')),
          tabPanel('Localmodel',
            withSpinner(plotOutput('LocalModel'), color = '#4a3c89')),
          tabPanel(
            'Lime',
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
          %s
        )
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

  comma <- ifelse(length(factor_vars), ',', '')

  sprintf( body,
           .create_inputs(factor_vars, .create_factor_input),
           comma,
           .create_inputs(cont_vars, .create_slider_input),
           all_expl_ui)
}

# helper for create_ui
.create_factor_input <- function(var_name){
  sprintf("selectInput(inputId = '%1$s',
          label = '%1$s',
          choices = levels(data$%1$s),
          selected = new_obs$%1$s)", var_name)
}

#helper for create_ui
.create_slider_input <- function(var_name){
  sprintf("sliderInput('%1$s',
          '%1$s:',
          min = round(min(data$%1$s, na.rm = T)),
          max = round(max(data$%1$s, na.rm = T)),
          value = new_obs$%1$s)", var_name)
}

#helper for UI
.create_inputs <- function(var_names, type_input_fun){
  paste(sapply(var_names, type_input_fun), collapse = ", \n")
}

