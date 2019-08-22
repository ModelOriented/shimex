#' creat server.R
#'
#' creates string for server.R file.
#'
#' @param factor_vars vector of strings containing names of factor variables.
#' @param cont_vars vector of strings containing names of continous variables.


.create_server <- function(factor_vars, cont_vars){

  str_explainers <- "
  output$CeterisParibus%1$s <- renderPlot({

    pred_cp <- ingredients::ceteris_paribus(explainer,
                                            new_observation = observation())
    p <- plot(pred_cp) +
         ingredients::show_observations(pred_cp)

    return(p)
  })


  output$BreakDown%1$s <- renderPlot({

    pred_bd <- iBreakDown::local_attributions(explainer,
                                              new_observation = observation())
    p <- plot(pred_bd)

    return(p)
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
  })"

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
         sprintf( str_explainers,
         '1'),

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


