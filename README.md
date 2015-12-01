# Exploring Product Categories with Treemaps

This project uses R and D3 to show how a treemap can be used to explore and analyze product classification (also known as product taxonomy) for ecommerce sites. 

## Treemap Overview

[Treemaps] (https://en.wikipedia.org/wiki/Treemapping) are good at showing how properties are distributed through a hierarchy. Here are some classic examples: 
  - showing how disk space is used on your filesystem
  - showing how market capitalization and price changes are distributed across sectors, subsectors, and individual stocks in a portfolio or stock exchange.

## Why use a Treemap for Product Categories?

Large ecommerce sites tend to classify their products using a hierarchy of categories (taxonomy), to help with site navigation and faceted search. For example on Etsy there are 38M products with over 2000 different product classification in a hiearchy that is 6 levels deep. For catalogs and product taxonomies, a treemap can help answer questions like:  
 - How are my products distributed?
 - Are my categories granular enough?   
   - Too many products in a category = can be hard to find what you're looking for. 
   - Too few products in a category = your store feels sparse. 
 - Which categories are the most popular / get the most traffic? 
 - Which categories have the highest conversion rates? 
 - How has a metric (e.g. product count/margin/sales/conversion) for a category changed over time?  
 
## Example

Here is a simple example using Etsy's taxonomy. Area represents the number of products in a category, and color is mapped to the top-level category. This set of screenshots starts with the distribution of products across top-level categories, and using the treemap to drill down into the Hats and Caps category.  

![navigationexample_2015-12-01_10-58-46](https://cloud.githubusercontent.com/assets/7903188/11506160/f864daaa-981b-11e5-85bc-31d79ecd9541.png)
