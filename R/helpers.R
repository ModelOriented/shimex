.create_global <- function(){

  global <- "
  library(shiny)
  library(iml)
  library(shinycssloaders)

  load('data.RData')
  predictor <- Predictor$new(explainer$model, data = data, y = y)"

  return(global)

}


.create_www <- function(){

  www <- "
  body {
  background-color: #fff;
    padding-top: 70px;
  }

  .navbar { background-color: #4a3c89;
  }

  .navbar-inverse .navbar-nav>li>a{ color: #fff !important; }

      .navbar-nav li a:hover, .navbar-nav > .active > a {
        color: #fff !important;

          background-color:#370F54 !important;
          background-image: none !important;
  }"

  return(www)

}


.write_files  <- function(mainDir, ui, server, global, www){

  write(ui, file.path(mainDir, 'ui.R'))
  write(server, file.path(mainDir, 'server.R'))
  write(global, file.path(mainDir, 'global.R'))

  if(!dir.exists(file.path(mainDir, '/www'))) dir.create(file.path(mainDir, '/www'))
  write(www, file.path(mainDir, '/www/style.css'))

}

