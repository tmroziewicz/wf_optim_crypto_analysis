download_or_source <- function(UrlToSource,FileToSource) {

  tryCatch(
    {
      print( paste("sourcing URL", UrlToSource))
      source(UrlToSource)
      
    },
    error = function(e) {
      print( paste("sourcing local file", FileToSource))
      source(FileToSource)
    }
  )
}
