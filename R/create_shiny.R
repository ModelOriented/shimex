#' create Shiny App for Exploring Model
#'
#' creates files for Shiny App and runs Shiny.
#'
#' @param explainer explainer created with function `DALEX::explain()`
#' @param new_obs a new observation with columns that corresponds to variables used in the model
#' @param selected_variables a vector of variable names that will be shown in input panel,
#' @param input_order a vector of variable names, that indicates order of displayed inputs.
#' It is not sessecairly to define all varaible names here. Names not entered will appear at the
#' end of the dispalyed inputs list. Factor variables always appear above numeric variables, unless
#' they are hidden.
#' @param all logical value. If TRUE, then extra tab is displayed showing all explainers,
#' @param main_dir string, path where shiny files should be stored.
#' @param delete logical value, if TRUE shiny files are deleted on exit of function.
#'
#' @examples
#' \dontrun{
#' library(randomForest)
#' model_rm <- randomForest(life_length ~., data = DALEX::dragons, ntree = 200)
#' explainer <- DALEX::explain(model_rm)
#' create_shiny(explainer)
#' }
#'
#' @export
#'

create_shiny <- function(explainer, new_obs = NULL, selected_variables = NULL, input_order = NULL,
                         all = FALSE, main_dir = NULL, delete = TRUE){

  # create main folder
  if(is.null(main_dir)) main_dir <- tempdir()
  main_dir <- file.path(main_dir, 'shimex')
  if(!dir.exists(main_dir)) dir.create(main_dir)

  # prepare data
  data <- explainer$data[, -1]
  input_order <-  union(input_order, colnames(data))

  factor_vars <- colnames(data)[sapply(data, is.factor)]
  factor_vars <- input_order[input_order %in% factor_vars]

  cont_vars <- colnames(data)[sapply(data, is.numeric)]
  cont_vars <- input_order[input_order %in% cont_vars]
  vars <- lapply(data, class)

  if(is.null(new_obs)) new_obs <- data.frame(data[1, ])
  if(is.null(selected_variables)) selected_variables <- colnames(data)[1:min(ncol(data), 5)]

  save(file = file.path(main_dir, 'data.RData'),
       list = c('explainer', 'new_obs', 'selected_variables'))

  ui <- .create_ui(factor_vars, cont_vars, all)
  server <- .create_server(factor_vars, cont_vars, all, vars)
  global <- .create_global()
  www <- .create_www()

  .write_files(main_dir, ui, server, global, www)


  shiny::runApp(main_dir)

  if(delete) unlink(main_dir, recursive = TRUE)
}
