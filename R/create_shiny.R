#' create Shiny App for Exploring Model
#'
#' creates files for Shiny App
#'
#' @param explainer DALEX
#' @param data --
#' @param new_obs --
#' @param selected_variables --
#' @param all --

create_shiny <- function(explainer, data = NULL, new_obs = NULL, selected_variables = NULL, all = F){

  # create main folder
  mainDir <- tempdir()
  if(!dir.exists(mainDir)) dir.create(file.path(mainDir))

  # prepare data
  if(is.null(data)) data <- explainer$data[, -1]
  factor_vars <- colnames(data)[sapply(data, is.factor)]
  cont_vars <- colnames(data)[sapply(data, is.numeric)]

  if(is.null(new_obs)) new_obs <- data.frame(data[1, ])
  if(is.null(selected_variables)) selected_variables <- colnames(data)[1:min(ncol(data), 5)] # TODO:: spr czy ma wg 5
  #

  save(file = file.path(mainDir, 'data.RData'),
       list = c('explainer', 'new_obs', 'selected_variables'))

  ui <- create_ui(factor_vars, cont_vars, all)
  server <- create_server(factor_vars, cont_vars)
  global <- paste(readLines(system.file("extdata", "global.txt", package = "shimex")), collapse = '\n')
  # TODO:: w paczce będzie inaczej http://r-pkgs.had.co.nz/data.html
  www <- paste(readLines(system.file("extdata", "style.txt", package = "shimex")), collapse = '\n')

  write_files(mainDir, ui, server, global, www)


  # ---- to remove
  # write_files('C:\\Users\\Lenovo\\Documents\\mgr\\model_explorer_example', ui, server, global, www)
  # save(file = file.path('C:\\Users\\Lenovo\\Documents\\mgr\\model_explorer_example', 'data.RData'),
  #     list = c('explainer', 'new_obs', 'selected_variables'))
  ###


  shiny::runApp(mainDir)
  unlink(mainDir, recursive = TRUE)
}
