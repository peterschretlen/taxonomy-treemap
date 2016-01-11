library(treemap)
library(dplyr)
# devtools::install_github("timelyportfolio/d3treeR")
library(d3treeR)
library(htmlwidgets)

source("taxonomy.R")
source("scrape.R")

scrape_counts <- FALSE
depth <- 7

# You can fetch and save a snapshot of Etsy taxonomy data to file using save_taxonomy
# save_taxonomy(<put your ETSY API key here>)

taxonomy <- load_taxonomy("data/taxonomy_08Jan2016.json")

#TODO: add a root entry to get all products

urls <- category_url(taxonomy$path)
taxonomy$url <- urls

filename <- "taxonomy.csv"
file.create(filename)

if(scrape_counts){
  counts_and_listings_all <- adply(urls, c(1), function(x) scrape(x, filename), .progress = "text" )
}

taxonomy_counts <- read.table("data/taxonomy.csv",sep = '~', stringsAsFactors = FALSE)

names(taxonomy_counts) <- c("url","count")

#join back to original data
taxonomy <- left_join(taxonomy, taxonomy_counts, by = c("url") )

taxonomy$parent_id[is.na(taxonomy$parent_id)] <- 0
taxonomy$count[is.na(taxonomy$count)] <- 0

#Title case name and remove underscores:
pretty_path <- str_to_title(str_replace_all(taxonomy$path, "_", " "))
pretty_path <- str_replace_all(pretty_path, "And", "and")

taxonomy_levels <- as.data.frame(str_split_fixed(pretty_path, "\\.", depth))
names(taxonomy_levels) <- paste("pathlevel", 1:depth, sep="")

taxonomy <- cbind(taxonomy, taxonomy_levels)

taxonomy$count <- as.numeric(taxonomy$count)

# we need to account for products that are not assigned to taxonomy leaf nodes, 
# otherwise they do not show up in the treemap. 
#
# We'll do this by takig the difference of a category and the sum of all child category counts. 
# This assumes products do not get multi-assigned categories, which does not always hold 
# because some categories end up with a count < 0
#
# These will be given as name of "-"
taxonomy_agg <- taxonomy %>% group_by( parent ) %>% dplyr::summarise( child_count = sum(count))
taxonomy_no_sub_category <- taxonomy %>% filter( path %in% taxonomy_agg$parent )
taxonomy_no_sub_category <- left_join(taxonomy_no_sub_category, taxonomy_agg, by=c("path" = "parent"))
taxonomy_no_sub_category$count <- taxonomy_no_sub_category$count - taxonomy_no_sub_category$child_count
taxonomy_no_sub_category$path <- paste(taxonomy_no_sub_category$path, "[No Sub Category]" , sep = ".")
taxonomy_no_sub_category$level <- as.numeric(taxonomy_no_sub_category$level) + 1
taxonomy_no_sub_category$parent_id <- taxonomy_no_sub_category$id
taxonomy_no_sub_category$children_ids <- ""
taxonomy_no_sub_category$name <- "[No Sub Category]"
taxonomy_no_sub_category <- taxonomy_no_sub_category %>% select( -child_count, -starts_with("pathlevel" ))

pretty_path <- str_to_title(str_replace_all(taxonomy_no_sub_category$path, "_", " "))
pretty_path <- str_replace_all(pretty_path, "And", "and")
taxonomy_levels <- as.data.frame(str_split_fixed(pretty_path, "\\.", depth))
names(taxonomy_levels) <- paste("pathlevel", 1:depth, sep="")
taxonomy_no_sub_category <- cbind(taxonomy_no_sub_category, taxonomy_levels)

taxonomy <- rbind(taxonomy, taxonomy_no_sub_category)

taxonomy <- taxonomy %>% dplyr::arrange(path)

#reset any negative counts to 0
taxonomy$count[ taxonomy$count < 0 ] <- 0 

tm <- treemap(taxonomy, index=paste("pathlevel", 1:depth, sep=""), vSize="count")
widget <- d3tree3( tm, rootname = "Etsy" , width="1024px", height="750px")

orig_dir <- setwd("widget_tmp/")
saveWidget(widget, "etsy-treemap.html", selfcontained = FALSE)
setwd(orig_dir)

