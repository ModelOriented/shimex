#' creates ui.R
#'
#' creates string for ui.R file.
#'
#' @param factor_vars vector of strings containing names of factor variables.
#' @param cont_vars vector of strings containing names of continous variables.
#' @param all logical values, if TRUE extra tab is creating showing all explainers together.

create_ui <- function(factor_vars, cont_vars, all){

  body <- paste(readLines(system.file("extdata", "ui_template.txt", package = "shimex")), collapse = '\n')
  all_expl_ui <- if(all) paste(readLines(system.file("extdata", "ui_all_explainers.txt", package = "shimex")), collapse = '\n') else ""

  comma <- ifelse(length(factor_vars), ',', '')
  sprintf( body,
           create_inputs(factor_vars, create_factor_input),
           comma,
           create_inputs(cont_vars, create_slider_input),
           all_expl_ui)
}

# helper for create_ui
create_factor_input <- function(var_name){
  sprintf("selectInput(inputId = '%1$s',
          label = '%1$s',
          choices = levels(data$%1$s),
          selected = new_obs$%1$s)", var_name)
}

#helper for create_ui
create_slider_input <- function(var_name){
  sprintf("sliderInput('%1$s',
          '%1$s:',
          min = round(min(data$%1$s, na.rm = T)),
          max = round(max(data$%1$s, na.rm = T)),
          value = new_obs$%1$s)", var_name)
}

#helper for UI
create_inputs <- function(var_names, type_input_fun){
  paste(sapply(var_names, type_input_fun), collapse = ", \n")
}

