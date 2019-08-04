write_files  <- function(mainDir, ui, server, global, www){
  
  write(ui, file.path(mainDir, 'ui.R'))
  write(server, file.path(mainDir, 'server.R'))
  write(global, file.path(mainDir, 'global.R'))
  
  if(!dir.exists(file.path(mainDir, '/www'))) dir.create(file.path(mainDir, '/www'))
  write(www, file.path(mainDir, '/www/style.css'))
  
}
