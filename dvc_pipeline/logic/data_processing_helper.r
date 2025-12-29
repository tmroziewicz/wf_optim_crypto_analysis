merge_files <- function(input_file, merge_type = "cbind", path_list_to_merge) {
  print("Merge files function")
  print(paste("Input file", input_file, " Merg type ", merge_type, "list_data_to_merge  ", path_list_to_merge))
  data_df <- readRDS(input_file)
  for (current_path in path_list_to_merge) {
    data_df <- do.call(merge_type, list(data_df, readRDS(current_path)))
  }
  return (data_df)
}

merge_files_cols_bind <- function ( input_file, path_list_to_merge) {
  merge_files(input_file = input_file  ,  "cbind", path_list_to_merge) 
}

merge_files_rows_bind <- function ( input_file, path_list_to_merge) {
  merge_files(input_file = input_file  ,  "rbind", path_list_to_merge ) 
}
