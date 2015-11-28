library(treemap)
library(dplyr)
# devtools::install_github("timelyportfolio/d3treeR")
library(d3treeR)

source("taxonomy.R")
source("scrape.R")

taxonomy <- load_taxonomy("data/CopyOftaxonomy_11Nov2015.json")

#TODO: add a root entry to get all products

urls <- category_url(taxonomy$path)
taxonomy$url <- urls

filename <- "taxonomy.csv"
file.create(filename)

counts_and_listigs_all <- adply(urls, c(1), function(x) scrape(x, filename), .progress = "text" )

taxonomy_counts <- read.table("taxonomy.csv",sep = '~', stringsAsFactors = FALSE)

#fix problem where column headers are output on every line
taxonomy_counts <- taxonomy_counts %>% filter( taxonomy_counts$V1 != "url") 
names(taxonomy_counts) <- c("url","count", "listings", "facet_data")

#fix problem with duplicate rows(???)
taxonomy_counts <- taxonomy_counts[!duplicated(taxonomy_counts),]

#join back to original data
taxonomy <- left_join(taxonomy, taxonomy_counts, by = c("url") )

taxonomy$parent_id[is.na(taxonomy$parent_id)] <- 0
taxonomy$count[is.na(taxonomy$count)] <- 0

taxonomy_levels <- as.data.frame(str_split_fixed(taxonomy$path, "\\.", 7))
names(taxonomy_levels) <- paste("pathlevel", 1:7, sep="")

taxonomy <- cbind(taxonomy, taxonomy_levels)

taxonomy$count <- as.numeric(taxonomy$count)


tm <- treemap(taxonomy, index=paste("pathlevel", 1:7, sep=""), vSize="count")
widget <- d3tree3( tm, rootname = "Etsy" )
saveWidget(widget, "etsy-treemap3.html", selfcontained = FALSE)


