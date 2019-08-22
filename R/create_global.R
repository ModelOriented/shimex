#' creates ui.R
#'
#' creates string for global.R file.
#'

create_global <- function(){

  global <- "
  library(data.table)
  library(iml)
  library(shinycssloaders)

  load('data.RData')
  data <- data.frame(explainer$data)
  predictor <- Predictor$new(explainer$model, data = data[, -1], y = data[, 1])"

  return(global)

}
