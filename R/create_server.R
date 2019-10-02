#' creat server.R
#'
#' creates string for server.R file.
#'
#' @param vars list of class of predictors.
#' @param selected_explainers ---


.create_server <- function(vars, selected_explainers){
  
  main <- readChar(system.file("extdata", "template", "server_main.txt", package = "shimex"),
                   nchars = 1e6)
  
  sprintf(main,
          .create_observation(vars),
          .create_explainers(selected_explainers))

}


# helper for create_server
# returns string defining list for current searched observation.
.create_observation <- function(vars){

  t_vars <- as.data.frame(cbind(names = names(vars), type = vars))
  t_vars$levels <- apply(t_vars, 1, function(x) paste0(', levels = levels(data$', x$`names`, ')'))
  t_vars$levels[t_vars$type != 'factor']  <- ''
  t_vars$as  <- ''
  t_vars$as[t_vars$type != 'factor']  <- 'as.'

  t <- apply(t_vars, 1, function(x) paste0(x$`names`, ' = ', x$`as` , x$`type` , '(input$', x$`names`, x$`levels`, ')'))

  obstr <- paste(t, collapse = ", ", '\n')
  paste0("list(", obstr,")")

}

.create_explainers <- function(s_e){
  
  s_e_path <- paste0('server_', s_e, '.txt')
  s_e_path <- system.file("extdata", "template", s_e_path, package = "shimex")
  str_expl <- lapply(s_e_path, readChar, nchars = 1e6 )
  
  paste(str_expl, collapse = '\n\n')
  
}
