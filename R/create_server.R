#' creat server.R
#'
#' creates string for server.R file.
#'
#' @param factor_vars vector of strings containing names of factor variables.
#' @param cont_vars vector of strings containing names of continous variables.


.create_server <- function(factor_vars, cont_vars, all){

  str_explainers <- paste0("
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
                     new_observation = new_obs)
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
            o <- ", .create_observation(factor_vars, cont_vars), "
          observation <-  o[, colnames(data)[-1]]
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
# returns string defining data.frame for current searched observation.
.create_observation <- function( factor_vars, cont_vars){

  cont <- sprintf( "%1$s = as.numeric(input$%1$s)" , cont_vars)
  factors <- sprintf("%1$s = factor(input$%1$s, levels = levels(data$%1$s))" , factor_vars)
  cf <- c(cont, factors)
  obstr <- paste(cf, collapse = ", ", '\n')
  paste0("data.frame(", obstr,")")

}


