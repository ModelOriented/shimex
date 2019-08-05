#' creat server.R
#'
#' creates string for server.R file.
#'
#' @param factor_vars vector of strings containing names of factor variables.
#' @param cont_vars vector of strings containing names of continous variables.

create_server <- function(factor_vars, cont_vars){

  paste("library(shiny)

         shinyServer(function(input, output) {

          # shinyjs::hide(!colnames(data) %in% show_variables)

          observeEvent(input$selected_columns, {

            lapply(colnames(data), shinyjs::hide)
            lapply(input$selected_columns, shinyjs::show)

          })

         observation <- reactive({
            o <- ", .create_observation(factor_vars, cont_vars), "
          observation <-  o[, colnames(data)[-1]]
         }) \n
         ",
         sprintf(
         paste(readLines(system.file("extdata", "server_explainers.txt", package = "shimex")), collapse = '\n'),
         ''),
        '\n',
         sprintf(
         paste(readLines(system.file("extdata", "server_explainers.txt", package = "shimex")), collapse = '\n'),
         '1'),

         "# -----
         onStop(function() {
         stopApp()
         })
         })

         ")
}


#' helper for create_server
#'
#' returns string defining data.frame for current searched observation.
#'
#' @param factor_vars vector of strings containing names of factor variables.
#' @param cont_vars vector of strings containing names of continous variables.

.create_observation <- function( factor_vars, cont_vars){

  cont <- sprintf( "%1$s = as.numeric(input$%1$s)" , cont_vars)
  factors <- sprintf("%1$s = factor(input$%1$s, levels = levels(data$%1$s))" , factor_vars)
  cf <- c(cont, factors)
  obstr <- paste(cf, collapse = ", ", '\n')
  paste0("data.frame(", obstr,")")

}


