#' Create SHIny app for Model EXploration
#'
#' creates files for Shiny App and runs Shiny.
#'
#' @param explainer explainer created with function `DALEX::explain()`
#' @param new_obs a new observation with columns that corresponds to variables used in the model
#' @param data ---
#' @param selected_variables a vector of variable names that will be shown in input panel,
#' @param selected_explainers a vector of explainers, that will be shown in the app.
#' Possible choices: c('CeterisParibus', 'BreakDown', 'Shap', 'Shap_iml', 'Shap_shapper', 'LocalModel', 'Lime', 'Lime_iml')
#' The default value are explainers implemented by MI2 DataLab.
#' @param main_dir string, path where shiny files should be stored.
#' @param delete logical value, if TRUE shiny files are deleted on exit of function.
#' @param ... other parameters.
#'
#' @examples
#' \dontrun{
#' library(randomForest)
#' model_rm <- randomForest(life_length ~., data = DALEX::dragons, ntree = 200)
#' explainer <- DALEX::explain(model_rm)
#' create_shimex(explainer,  DALEX::dragons[1, ])
#' }
#'
#' @export
#'

create_shimex <- function(explainer, new_obs, data = explainer$data, selected_variables = NULL,
                          selected_explainers = c('CeterisParibus', 'BreakDown', 'Shap', 'LocalModel', 'Lime'),
                          main_dir = NULL,
                          delete = TRUE, ...){
  
  .create_shimex(explainer, new_obs, data, selected_variables, selected_explainers, main_dir, delete, ...)
}


.create_shimex <- function(explainer, new_obs, data, selected_variables,
                          selected_explainers, main_dir, delete, run = TRUE){

  cat('start')
  # create main folder
  if(is.null(main_dir)) main_dir <- tempdir()
  main_dir <- file.path(main_dir, 'shimex')
  if(!dir.exists(main_dir)) dir.create(main_dir)
  
  cat('catalog created')

  # get predictors and response names
  vars <- all.vars(formula(explainer$model))
  predvars <- vars[-1]
  y_name <- vars[1]

  # prepare data
  y <- data[, y_name]
  data <- data[, predvars]
  new_obs <- new_obs[, predvars]

  vars <- lapply(data, class)
  if(is.null(selected_variables)) selected_variables <- colnames(data)[1:min(ncol(data), 5)]

  ui <- .create_ui(selected_explainers)
  server <- .create_server(vars, selected_explainers)
  global <- .create_global(selected_explainers)
  www <- readChar(system.file("extdata", "template", "www.txt", package = "shimex"), nchars = 1e6)

  # write files
  .write_files(main_dir, ui, server, global, www)
  save(file = file.path(main_dir, 'data.RData'),
       list = c('explainer', 'data', 'y', 'new_obs', 'selected_variables'))

  cat('files written')
  cat(run)
  
  if(run) shiny::runApp(main_dir)
  
  cat('app run')

  if(delete) unlink(main_dir, recursive = TRUE)
  cat('deleted')
}


