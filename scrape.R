library(rvest)
library(stringr)
library(httr)

category_url <- function(path){
  category <- str_replace_all(path, "\\.", '\\/')
  category <- str_replace_all(category, "_", '-')
  url <- paste("https://www.etsy.com/c", category, sep = "/")
  return(url)
}

get_event_data <- function(url){

  #uastring <- "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36"
  #html <- html_session(url, user_agent(uastring))
  html <- read_html(url)
  
  javascript_tags <- html %>% html_nodes("script[type='text/javascript']") %>% html_text(trim = TRUE)
  
  event_data_regex <- ".*EventPipe\\.enabled=true;EventPipe\\.init\\(([^;]*)\\);.*"
  event_data <- str_match(javascript_tags, event_data_regex)[,2]
  event_data <- event_data[!is.na(event_data)]
  event_data <- str_trim(event_data)  
  return(fromJSON(event_data)["events"])
}

extract_count <- function(event_data){
  total_results <- event_data$events$attributes$total_results
  if(is.null(total_results)){
    return(0);
  }
  return(total_results)
}

extract_facet_data <- function(event_data){
  taxonomy_json <- event_data$events$attributes$taxonomy_facet_data
  if(is.null(taxonomy_json)){
    return(0);
  }
  return(taxonomy_json)
}

extract_listings <- function(event_data){
  return(event_data$events$attributes$listing_ids)
}

scrape <- function(url, file){
  
  count <- 0
  attempts <- 0
  while(count == 0 && attempts < 10){
    Sys.sleep(1.0)
    print(url)
    event_data <- get_event_data(url)
    count <- extract_count(event_data)
    listings <- extract_listings(event_data)
    facet_data <- extract_facet_data(event_data)
    attempts <- attempts + 1
  }

  error_file <- "error.log"
  if(!file.exists(error_file)){
    file.create(error_file)
  }
  
  if(attempts == 10){
    print(paste("Could not get count after 10 tries: ", url))  
    write(paste(url, "no count", sep = "~"), file = error_file, append = TRUE)
    return(NULL)
  }

  df <- tryCatch({
      data.frame( url = url, count = count, listings = listings, taxonomy_facet_data = facet_data, stringsAsFactors = FALSE)
    },
    warning = function(warn) {
      print(warn)
    }, 
    error = function(err) {
      print(paste("Error for URL: ", url))  
      write(paste(url, err, sep = "~"), file = error_file, append = TRUE)
      return(NULL)
    },
    finally = {
      print(paste("Processed: ", url))
      
    })

  write.table(df, file = file, append = TRUE, row.names = FALSE, col.names = FALSE, sep = "~")
  return(df)
  
}
