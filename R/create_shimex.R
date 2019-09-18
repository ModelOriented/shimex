#' create Shiny App for Exploring Model
#'
#' creates files for Shiny App and runs Shiny.
#'
#' @param explainer explainer created with function `DALEX::explain()`
#' @param new_obs a new observation with columns that corresponds to variables used in the model
#' @param data ---
#' @param selected_variables a vector of variable names that will be shown in input panel,
#' @param all logical value. If TRUE, then extra tab is displayed showing all explainers,
#' @param main_dir string, path where shiny files should be stored.
#' @param delete logical value, if TRUE shiny files are deleted on exit of function.
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
                         all = FALSE, main_dir = NULL, delete = TRUE){

  # create main folder
  if(is.null(main_dir)) main_dir <- tempdir()
  main_dir <- file.path(main_dir, 'shimex')
  if(!dir.exists(main_dir)) dir.create(main_dir)

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

  save(file = file.path(main_dir, 'data.RData'),
       list = c('explainer', 'data', 'y', 'new_obs', 'selected_variables'))

  ui <- .create_ui(vars)
  server <- .create_server(vars)
  global <- .create_global()
  www <- .create_www()

  .write_files(main_dir, ui, server, global, www)


  shiny::runApp(main_dir)

  if(delete) unlink(main_dir, recursive = TRUE)
}





