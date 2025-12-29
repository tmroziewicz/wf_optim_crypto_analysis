if (!require("pacman")) install.packages("pacman", repos = "http://cran.us.r-project.org")

pacman::p_load(xts,yaml,optparse)


arg_parser <- function(input_args_str) {
  print("arg_parser START=============== ")
  #example of what is possible
  # fun1_arg1 - simple string argument 
  # fun1_arg2.0;fun1_arg2.1 - this will be converted to vector and passed as single arg
  # fun2_arg_simple - this is other function argument 
  # separator:
  # ;  vetor 
  # #  same function different args 
  # ,  different function args 
  #example_arg <- "fun1_arg1#fun1_arg2.0;fun1_arg2.1,fun2_arg_simple"
  print(paste("Raw argument list not yet parsed: ",  input_args_str))
  
  #list whcih will contain so many elements as many fun arguments are there 
  each_fun_arg_list <- list()
  
  fun_arg_list <- scan(text=input_args_str, what="", sep=",")
  
  print(paste("After first split by , so each element is representing each function",  str(fun_arg_list)))
  
  print("Iterattion by elements starts here ")
  
  for( each_fun_args_str in fun_arg_list ) {
    
    print(paste("Raw element", each_fun_args_str))
    
    single_fun_arg_list <- scan(text=each_fun_args_str, what="", sep="#")
    
    print(paste("After second split # so each element is representing argument ",  str(single_fun_arg_list)))
    
    new_arg_list <- list()
    
    print(paste("Last iteration by elements to search for vectors encodeds with separator ;"))
    for( single_arg_str in single_fun_arg_list ) {
      print(paste("Raw element", single_arg_str))
      arg <- scan(text=single_arg_str, what="", sep=";")
      print(paste("This will be stored finally", arg))
      new_arg_list[[length(new_arg_list)+1]] <- arg
    }
    #in case of debugging uncomment 
    #do.call("mock_args_fun",  new_arg_list )
    each_fun_arg_list[[length(each_fun_arg_list)+1]] <- new_arg_list
  }
  print("arg_parser END=============== ")
  return(each_fun_arg_list)
}


parser <- OptionParser()

parser <- add_option(parser, "--inputfile", action="store_true", type="character" ,
                     default=TRUE, help="Print extra output [default]")

parser <- add_option(parser,  "--output", action="store_true",type="character" , default="" , help="Print little output")

parser <- add_option(parser,  "--helper", action="store_true",type="character" , default="" , help="Print little output")

parser <- add_option(parser,  "--funs", action="store_true",type="character" , default="" , help="Print little output")

parser <- add_option(parser,  "--args", action="store_true",type="character" , default="" , help="Print little output")


opt <- parse_args(parser)

print(opt)

helper <- opt$helper

source(helper)

#listfu <- scan(text="xxx,yy", what="", sep=",")
function_list <- scan(text=opt$funs, what="", sep=",")

print(paste("Argument list option ", opt$args))

#read argument list, list is separated by commas 
args_list <- arg_parser(opt$args)

print(paste("Argument list ", args_list))

f <- get(function_list[[1]])

temp<- f(opt$input)
#print(head(temp))

for ( i in 2:(length(function_list)-1)) {
  print( paste("Executing function ", i,function_list[[i]] ))
  #$f <- get(function_list[[i]])
  if( args_list[[i-1]][[1]]!="noarg"  ) {
    print(paste("Function has arguments in raw form ",args_list[[i-1]]))
    
    #for each of element of the list , perfrom scan to search for args which are mulitply values
    #and then will be passed as vector to function
    new_arg_list <- append(list(temp), args_list[[i-1]] )

    print("Final argument list constructed and temp object added to the list  ")
    #print(paste("Argument list which will be passed to do.call",new_arg_list))

    temp <- do.call(function_list[[i]], new_arg_list )  
    
  } else {
    print(" function has no arguments ")
    f <- get(function_list[[i]])
    print(exists("temp"))
    temp<- f(temp)  
  }
  
  
}


print("Writing output")


print(head(temp))


f <- get(function_list[[length(function_list)]])
f(temp,opt$output)

print("Output wrote ....")

print(function_list)













