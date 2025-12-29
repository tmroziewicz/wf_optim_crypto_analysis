if (!require("pacman")) install.packages("pacman", repos = "http://cran.us.r-project.org")
pacman::p_load(R6,yaml)


DataCollector <- R6Class(
  "DataCollector",
  public = list(
    # Initialize the fields

    #this should not contain name of parmeters otehrwise it will be not general 
    data_list = list(),
    data_desc = list(),
    params.yaml = NULL,
    
    # Define the constructor
    initialize = function(param.path.str) {
      self$params.yaml <- yaml::read_yaml(param.path.str)
    }, 
    
    add_data = function(data, filename, data_desc ) {
      self$data_list[[filename]] <- data
      desc_df <-  data.frame(filename = filename, data_desc = data_desc, store_date=format(Sys.time(),"%y-%m-%d %H:%M:%S" ))
      self$data_desc <- append(self$data_desc, list(desc_df))
    },

    save_all_data = function() {
      file_names <- names(self$data_list)
      for(i in seq_along(self$data_list)) { 
          saveRDS(drop(self$data_list[[i]]), file = paste(self$params.yaml$path_to_save,paste0(file_names[i],".rds"),sep="/" )) 
      } 
      
      desc_df <- do.call("rbind", self$data_desc)
      
      yaml::write_yaml(desc_df,file.path(self$params.yaml$path_to_save, "desc.yaml"))

    }
  )
)
