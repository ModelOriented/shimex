#' creat server.R
#'
#' creates string for server.R file.
#'
#' @param factor_vars vector of strings containing names of factor variables.
#' @param cont_vars vector of strings containing names of continous variables.
#' @param all logical value. If TRUE, then extra tab is displayed showing all explainers


.create_server <- function(factor_vars, cont_vars, all, vars){

  str_explainers <- paste0("

      output$vars_input <- renderUI({

                           selected_columns <- input$selected_columns

                           lapply(1:length(selected_columns), function(i){
                           var_values <- data[, colnames(data) == selected_columns[i]]

                           if(class(var_values) == 'factor'){
                           selectInput(inputId = selected_columns[i],
                           label = selected_columns[i],
                           choices = levels(var_values),
                           selected = observation()[[selected_columns[i]]])}
                           else{
                           sliderInput(inputId = selected_columns[i],
                           label = selected_columns[i],
                           min = round(min(var_values, na.rm = T)),
                           max = round(max(var_values, na.rm = T)),
                           value = observation()[[selected_columns[i]]])
                           }
                           })
})

    pred_cp <- reactive({
      ingredients::ceteris_paribus(explainer,
                             new_observation = observation())
      })

   output$CeterisParibus <- renderPlot({
   p <- plot(pred_cp()) +
   ingredients::show_observations(pred_cp())

   return(p)
   })

  output$CeterisParibus_factor%1$s <- renderPlot({

  factor_vars_str <- c('", paste0(factor_vars, collapse = "', '"),"')

  if(factor_vars_str[1] == '') return(NULL)
  else { p <- plot(pred_cp(),
            variables = factor_vars_str,
            only_numerical  = F)
        return(p)
       }
  })

  output$CP_describe <- renderUI({

    d <- describe(pred_cp())
    d <- gsub('*', '', d, fixed = T)
    d <- gsub('\n', '<br>', d, fixed = T)
    d <- paste0(d, collapse = '<br>')
    HTML(d)

  })

  pred_bd <- reactive({
    iBreakDown::local_attributions(explainer,
                           new_observation = observation())
  })

   output$BreakDown <- renderPlot({
     p <- plot(pred_bd())
     return(p)
   })


   output$BD_describe <- renderUI({
     d <- iBreakDown::describe(pred_bd())
     d <- gsub('*', '', d, fixed = T)
     d <- gsub('\n', '<br>', d, fixed = T)
     d <- paste0(d, collapse = '<br>')
     HTML(d)
  })

  output$LocalModel%1$s <- renderPlot({

    pred_localModel <- localModel::individual_surrogate_model(explainer,
                                                              new_observation = observation(),
                                                              size = 500)
    p <- plot(pred_localModel) +
         DALEX::theme_drwhy()

    return(p)
  })


  output$Shapley%1$s <- renderPlot({

    shapley%1$s <- Shapley$new(predictor,
                               x.interest = observation())
    p <- shapley$plot() +
         DALEX::theme_drwhy()

    return(p)
  })

  output$Shap_iBD%1$s <- renderPlot({

     shap_ib <- iBreakDown::shap(explainer,
                     new_observation = observation())
     p <- plot(shap_ib)
     return(p)
  })


  lime.explain <- reactive({
    LocalModel$new(predictor,
                   x.interest = observation(),
                   k = input$lime_n_vars)
  })

  output$Lime%1$s <- renderPlot({
    p <- plot(lime.explain()) +
         DALEX::theme_drwhy()
    return(p)
  })

  output$shapeR%1$s <- renderPlot({
    shaper <- shapper::individual_variable_effect(explainer$model,
                                                  data = explainer$data[, -1],
                                                  new_observation = observation())

   plot(shaper)
  })

  output$Lime_ingr%1s <- renderPlot({
    asp <- as.list(colnames(data[, -1]))
    names(asp) <- colnames(data[, -1])

    pred_lime <- ingredients::aspect_importance(explainer,
                           new_observation = observation(),
                           aspects = asp)
    return(plot(pred_lime))
})")

  all_tab <- ''
  if(all) all_tab <- sprintf(str_explainers,'1')

  paste("library(shiny)

         shinyServer(function(input, output) {

          observeEvent(input$selected_columns, {

            lapply(colnames(data), shinyjs::hide)
            lapply(input$selected_columns, shinyjs::show)

          })

         observation <- reactive({
            o <- ", .create_observation(vars), "
          nulls <- sapply(o, function(x) length(x) == 0)
          o[nulls] <- new_obs[nulls]

        as.data.frame(o)
         }) \n
         ",
         sprintf(str_explainers,
         ''),
        '\n',
         all_tab,

         "# -----
         onStop(function() {
         stopApp()
         })
         })

         ")
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


