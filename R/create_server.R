#' creat server.R
#'
#' creates string for server.R file.
#'
#' @param vars list of class of predictors.


.create_server <- function(vars){

  factor_vars <- names(vars)[sapply(vars, function(x) x == 'factor')]

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

    output$CP <- renderUI({

     selected_columns <- input$selected_columns
     dg <- describe(pred_cp(), variables = input$selected_columns[1])
     dg <- trimws(sub('\n.*', '', dg))
     
     tags$div(class='content',
       tags$div(
         renderText(dg),
         style = 'font-size: 110%'
       ),
       tags$br(),
       lapply(1:length(selected_columns), function(i){
                           
         p <- plot(pred_cp(),
         variables = input$selected_columns[i])
         d <- sub(dg, '', describe(pred_cp(),
         variables = input$selected_columns[i]))
         
         tags$div(
           tags$div(
             renderPlot(p, width = 300, height = 200)
           ),
           tags$div(
             renderText(d)
           ),
           style = 'width:300px;height:340px; float:left; margin:5px; font-size:13px'
         )
     })
   )
                           
                           
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

  output$LocalModel <- renderPlot({

    pred_localModel <- localModel::individual_surrogate_model(explainer,
                                                              new_observation = observation(),
                                                              size = 500)
    p <- plot(pred_localModel) +
         DALEX::theme_drwhy()

    return(p)
  })


  output$Shapley <- renderPlot({

    shapley <- Shapley$new(predictor,
                               x.interest = observation())
    p <- shapley$plot() +
         DALEX::theme_drwhy()

    return(p)
  })

  output$Shap_iBD <- renderPlot({

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

  output$Lime <- renderPlot({
    p <- plot(lime.explain()) +
         DALEX::theme_drwhy()
    return(p)
  })

  output$shapeR <- renderPlot({
    shaper <- shapper::individual_variable_effect(explainer$model,
                                                  data = explainer$data[, -1],
                                                  new_observation = observation())

   plot(shaper)
  })

  output$Lime_ingr <- renderPlot({
    asp <- as.list(colnames(data[, -1]))
    names(asp) <- colnames(data[, -1])

    pred_lime <- ingredients::aspect_importance(explainer,
                           new_observation = observation(),
                           aspects = asp)
    return(plot(pred_lime))
})")

  paste("library(shiny)

         shinyServer(function(input, output) {

         observation <- reactive({
            o <- ", .create_observation(vars), "
          nulls <- sapply(o, function(x) length(x) == 0)
          o[nulls] <- as.list(new_obs)[nulls]

        as.data.frame(o)
         }) \n
         ",
        str_explainers,
        "\n

         # -----
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


