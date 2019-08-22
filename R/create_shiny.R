#' create Shiny App for Exploring Model
#'
#' creates files for Shiny App
#'
#' @param explainer explainer created with function `DALEX::explain()`
#' @param new_obs --
#' @param selected_variables --
#' @param all logical value. If TRUE, then extra tab is displayed showing all explainers,
#' @param main_dir string, path where shiny files should be stored.
#' @param delete logical value, if TRUE shiny files are deleted on exit of function.
#'
#' @example
#' library(randomForest)
#' model_rm <- randomForest(life_length ~., data = DALEX2::dragons, ntree = 200)
#' explainer <- DALEX::explain(model_rm)
#' create_shiny(explainer)
#'
#' @export
#'

create_shiny <- function(explainer, new_obs = NULL, selected_variables = NULL, all = FALSE,
                         main_dir = NULL, delete = TRUE){

  # create main folder
  if(is.null(main_dir)) main_dir <- tempdir()
  if(!dir.exists(main_dir)) dir.create(file.path(main_dir))

  # prepare data
  data <- explainer$data[, -1]
  factor_vars <- colnames(data)[sapply(data, is.factor)]
  cont_vars <- colnames(data)[sapply(data, is.numeric)]

  if(is.null(new_obs)) new_obs <- data.frame(data[1, ])
  if(is.null(selected_variables)) selected_variables <- colnames(data)[1:min(ncol(data), 5)]
  #

  save(file = file.path(main_dir, 'data.RData'),
       list = c('explainer', 'new_obs', 'selected_variables'))

  ui <- .create_ui(factor_vars, cont_vars, all)
  server <- .create_server(factor_vars, cont_vars)
  global <- .create_global()
  www <- .create_www()

  .write_files(main_dir, ui, server, global, www)


  shiny::runApp(main_dir)

  if(delete) unlink(main_dir, recursive = TRUE)
}
