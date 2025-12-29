source("../DataCollector.r")

test_that("save_list_to_rds works as expected", {
  temp_dir <- tempdir()
  
  test_yaml <- yaml::read_yaml("../DataCollector.yaml")
  test_yaml$path_to_save <- temp_dir
  test_yaml_path_filename_str <- paste(temp_dir,"data_collector_test.yaml",sep="/")
  con <- file(test_yaml_path_filename_str, "w")
  yaml::write_yaml(test_yaml, con)
  
  data_collector.obj <- DataCollector$new(param.path.str = test_yaml_path_filename_str)  
  
  data_collector.obj$add_data(mtcars,"mtcars")
  data_collector.obj$add_data(iris, "iris")
  data_collector.obj$add_data(airquality,"airquality")
  data_collector.obj$save_all_data()
  
  file_names <- c("mtcars.rds", "iris.rds", "airquality.rds")
  paths_files_vec <- file.path(temp_dir,file_names)
  
  expect_true(all(file.exists(paths_files_vec)))
  mtcars.read <- readRDS(paths_files_vec[1]) 
  #class(mtcars.read)
  expect_identical(readRDS(paths_files_vec[1]), mtcars)
  expect_identical(readRDS(paths_files_vec[2]), iris)
  expect_identical(readRDS(paths_files_vec[3]), airquality) 
}
)
