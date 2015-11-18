source("taxonomy.R")
source("scrape.R")

taxonomy <- load_taxonomy("data/CopyOftaxonomy_11Nov2015.json")

#TODO: add a root entry to get all products

subset <- taxonomy[1:nrow(taxonomy),]

urls <- category_url(subset$path)

filename <- "taxonomy.csv"
file.create(filename)

counts_and_listigs_all <- adply(urls, c(1), function(x) scrape(x, filename), .progress = "text" )
