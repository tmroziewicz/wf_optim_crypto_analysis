#if (!require("pacman")) install.packages("pacman", repos = "http://cran.us.r-project.org")
#pacman::p_load(xts,yaml,optparse, tibble,here,tidyverse,roll,R6,broom,quantmod,tseries,PerformanceAnalytics,data.table)
library(data.table)

isValidCoord <- function (matx , row, col ) {
  if (row<=nrow(matx) &&  col<=ncol(matx) && row >= 1 && col>=1) {
    return (TRUE)
  } else { 
    return (FALSE)
  }
  
}

smooth_matrix_debug <- function( matx.df, stat.name ) {
  print(paste("Type of first argument", class(matx.df)))
}

smooth_matrix <- function( matx.df, stat.name ) {
  print(head(matx.df))
  print(stat.name)
  matx.df <- as.data.frame(dcast(as.data.table(matx.df),  wf.test_length ~ wf.train_length,value.var = stat.name))  
  orginal_colnames <- as.numeric(colnames(matx.df)[2:ncol(matx.df)])
  orginal_rownames <- matx.df[,1]
  
  matx.df <- matx.df[,2:ncol(matx.df)]
  #elements which will be added to eeach coordinate, to retrieve the neighboor
  addlist <-list(c(1,0),c(0,1),c(1,1),c(-1,-1),c(-1,1),c(1,-1),c(-1,0),c(0,-1))  
  dflist <- list()
  colnames(matx.df) <- as.character(seq(1:ncol(matx.df)))
  rownames(matx.df) <-as.character(seq(1:nrow(matx.df)))
  
  colname.map.df <- data.frame(row.names=colnames(matx.df) , val = orginal_colnames)
  rowname.map.df <- data.frame(row.names=rownames(matx.df) , val = orginal_rownames)
  print(str(matx.df))
  for (col in 1:ncol(matx.df)) {
    for (row in 1:nrow(matx.df)) {
      
	  print(paste( "Row", row,"Col ", col, " Value " , matx.df[row,col]))    
	  
	  cellvalue <- matx.df[row,col]
	  
      nbvalue <- c()
	  
      for ( adding in addlist) {
        
        newcord <- c(row,col) + adding
        
        if ( isValidCoord(matx.df, newcord[1], newcord[2])) {
          print(adding)
		  print(" debug" )
          print (paste(newcord[1], newcord[2], matx.df[newcord[1], newcord[2] ]))
          nbvalue <- append(nbvalue, matx.df[newcord[1], newcord[2] ] )
        }
      }
	  
      weighted <- (mean(nbvalue) + matx.df[row,col])/2
	  
      dflist <- append(dflist, list(data.frame(wf.test_length = rowname.map.df[row,] , wf.train_length = colname.map.df[col,] ,  weighted = as.numeric(weighted))))
    }
  }
  d <- do.call(rbind, dflist)
}

#sharpe.df <- readRDS("./data_to_share/01_sharpe_heatmap.rds")
#debug(smooth_matrix)
#smoothed.df <- smooth_matrix(sharpe.df, "sharpe_ratio")








