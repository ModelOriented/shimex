#' creates ui.R
#'
#' creates string for ui.R file.
#'
#' @param selected_explainers list of class of predictors.

.create_ui <- function(selected_explainers){

  main <- readChar(system.file("extdata", "template", "ui_main.txt", package = "shimex"),
                 nchars = 1e6)

  
  tabs <- paste0("tabPanel('", selected_explainers,"',
                    %s
                    withSpinner(uiOutput('", selected_explainers , "'), color = '#4a3c89'))")
  
  # extra elements in ui tabs
  s_e_path <- paste0('ui_', selected_explainers, '.txt')
  s_e_path <- sapply(s_e_path, function(x) system.file("extdata", "template", x, package = "shimex"))
  s_e_path[s_e_path != ""] <- sapply(s_e_path[s_e_path != ""], readChar, nchars = 1e6 )

  tabs <- sprintf(tabs, as.vector(s_e_path))
  tabs <- paste0(tabs, collapse = ',\n')
  
  sprintf(main, tabs)

}

