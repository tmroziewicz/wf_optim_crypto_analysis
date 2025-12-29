if (!require("pacman")) install.packages("pacman", repos = "http://cran.us.r-project.org")
pacman::p_load(xts,yaml,optparse, tibble,here,tidyverse,roll,R6)

old_path <- Sys.getenv("PATH")

here::here()

getwd()

setwd("C:/todo-p/UW/Master-Thesis-analysis")

collect.yaml <- yaml::read_yaml("collect_strategy_runner_20250118.yaml")

Sys.setenv(PATH = paste(collect.yaml$dvc_path, old_path, sep = ";"))
Sys.getenv()
experiment.col.str <-  collect.yaml$experiment_col

command.template.str <- collect.yaml$command_to_execute

copy.path.str <- collect.yaml$copy_path

files.to.collect.arr <- collect.yaml$file_to_collect

experiment.csv.df <- read.csv(collect.yaml$experiment_csv, sep=",", encoding="UTF-8")

experiment.csv.df$Experiment <- as.character(experiment.csv.df$Experiment)



getwd()

setwd(collect.yaml$main_project)

result.list  <-  list()


experiment.csv.df$Experiment[521]
for ( i in 1:nrow(experiment.csv.df)) {
#for ( i in 3:5) {
  curr.exp.name.str <- experiment.csv.df[i,experiment.col.str]
  
  print(paste0("current experiment name : '",curr.exp.name.str,"'"))
  
  if ( curr.exp.name.str=='') {
    next;
  } 
  
  message("Executing dvc command:")
  cur.command.str <- sprintf(command.template.str, curr.exp.name.str)
  system(cur.command.str)
  
  param.yaml <- yaml::read_yaml("params.yaml")

  for (j in 1:length(files.to.collect.arr)) {
    fileToCollect <- files.to.collect.arr[j]
    fileToCollect <- sprintf(fileToCollect,param.yaml$general$asset, param.yaml$general$tfmin )
    message(fileToCollect)
  
    dest.dir.path.str <- paste0(copy.path.str,"\\",curr.exp.name.str)
    if (!dir.exists(dest.dir.path.str)) {
      dir.create(dest.dir.path.str)  
    }
    #getwd()
    
    #file.exists(fileToCollect)
    #file.exists("master\\data-wip\\1\\15\\07_wf_metrics.rds")
    
    file.copy(from = fileToCollect, to = paste0(dest.dir.path.str, "\\", basename(fileToCollect)), recursive=TRUE)
    
    #temp.df <- as.data.frame(yaml::read_yaml(fileToCollect))
    #temp.df$train_length <- param.yaml$wf$train_length
    #temp.df$test_length <- param.yaml$wf$test_length
    #temp.df$tfmin <- param.yaml$general$tfmin
    #result.list <- append(result.list, list(temp.df)) 
  }
}

#shell.exec("dvc exp")


