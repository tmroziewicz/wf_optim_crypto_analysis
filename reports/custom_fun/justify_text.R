library(stringr)
internal_function <- function(line, width) {
  line <- trimws(line)
  n_spaces <- width - nchar(line)
  #print (paste("for line ", line , " size of line ", nchar(line), " n_spaces will be added "  ,n_spaces))
  if (n_spaces > 0) {
    words <- strsplit(line, "\\s+")[[1]]
    n_words <- length(words)
    
    # if (n_words > 1) {
    #   # Ensure space_count is always non-negative
    #   space_count <- pmax(0, floor(n_spaces / (n_words - 1)))
    #   space_count[1:n_spaces %% (n_words - 1)] <- space_count[1:n_spaces %% (n_words - 1)] + 1
    # } else {
    #   space_count <- 0
    # }
    ex_space_count <- n_words -1
    spaces <- rep(" ", ex_space_count)
    
    for( i in 1:n_spaces) {
      index <- if  (i==ex_space_count)  ex_space_count else i%%ex_space_count
      #print(index)
      spaces[index] <- paste(spaces[index]," ",sep="")
    }
    
    # Distribute spaces between words
    line_with_spaces <- trimws(paste(c(rbind(words, spaces)), collapse = ""))
    
    # Split line into words and spaces
    words_and_spaces <- strsplit(line_with_spaces, "(?<=\\s)", perl = TRUE)[[1]]
    
    # Combine words and spaces
    justified_line <- paste(words_and_spaces, collapse = "")
    
    return(justified_line)
  } else {
    line
  }
}

justify_text <- function(text, width) {
  # Split text into words
  words <- strsplit(text, "\\s+")[[1]]
  
  # Initialize output
  justified_text <- character()
  
  # Iterate over words
  line <- words[1]
  words <- words[-1]
  while (length(words) > 0) {
    word <- words[1]
    if (nchar(line) + nchar(word) < width) {
      line <- paste(line, word, sep = " ")
    } else {
      justified_text <- c(justified_text, line)
      line <- word
    }
    words <- words[-1]
  }
  justified_text <- c(justified_text, line)
  #print("===============================")
  #print("justified after initial process")
  #print(justified_text)
  #print("===============================")
  
  # Improved justification
  justified_text <- sapply(justified_text,internal_function, width)
  
  #print("===============================")
  #print("justified after internal function")
  #print(justified_text)
  #print("===============================")
  
  justified_text[length(justified_text)] <- gsub("\\s+", " ", justified_text[length(justified_text)])
  
  # Ensure at least one character in justified_text
  if (length(justified_text) > 0) {
    return(paste(justified_text, collapse = "\n"))
  } else {
    return(text)  # Return original text if no justification is possible
  }
}

test_justify <- function () {
  inputStr <- "just a quick email to say that sounds like a great idea. Saturday is better for me because I'm meeting my parents on Sunday. So if that's still good for you, why don't you come here? Then you can see the new flat and all the work we've done on the kitchen since we moved in. We can eat at home and then go for a walk in the afternoon. It's going to be so good to catch up finally. I want to hear all about your new job! Our address is 52 Charles Road, but it's a bit difficult to find because the house numbers are really strange here. If you turn left at the post office and keep going past the big white house on Charles Road, there's a small side street behind it with the houses 50–56 in. Don't ask me why the side street doesn't have a different name! But call me if you get lost and I'll come and get you. Let me know if there's anything you do/don't like to eat. Really looking forward to seeing you!"
  width <- 50
  cat(justify_text(inputStr, width))
  
  cat(str_wrap(inputStr,30))
  
  words <- c("this","is","my","home","Lovely")
  spaces <- c(" "," "," " ," ")
  
  trimws(paste(c(rbind(words, spaces)), collapse = ""))
  str_sub(paste(c(rbind(words, spaces)), collapse = ""), end = -2)
  
  anotherStr <- "Note: Bitcoin price (shaded area indicates data division). The global trainig data period covers data from February 8, 2018, to September 1, 2019.   The global trainig data period covers data from   February 8, 2018, to September 1, 2019."
  global_train_description_str <- "The global trainig data period covers data from February 8, 2018, to September 1, 2019."
  anotherStr <- paste(
    "Note: Bitcoin price (shaded area indicates data division).",
    global_train_description_str, 
    global_train_description_str
  )
   
  anotherStr <- "
  Note: This graph analyzes the smoothed heatmap of Sharpe Ratios for walk−forward
optimization on 60−minute Bitcoin price data within the global training period,
  using Exponential Moving Averages (EMA).The horizontal axis represents the
  training window size, which is the amount of historical data used to train the
  EMA strategy.The vertical axis represents the testing window size, which is the
  amount of data used to evaluate the performance of the EMA strategy after
  training. The intersection of a specific training window size and testing window
  size on the chart shows the corresponding Sharpe Ratio achieved by the
  walk−forward optimization with EMA for those parameters. Smoothed values were
  calculated using a weighted average. In this approach, the original value
  retained half the weight, while the remaining weight was distributed among its
  neighboring values. The global trainig data period covers data from February 8,
  2018, to September 1, 2019. Each transaction incurs a 0.1% cost. Changing
  positions from short to long requires two transactions, resulting in a total
  cost of 0.2%
  
  "
  cat(justify_text(anotherStr, 70))
}

