# ----Script Info ----

## ---- Purpose ----

# This script examines manually extracted literature review results (based on Web of Science search).

## ---- Additional Info ----

# Author: Christine M. K. Clarke 

# Date Created: 2026-02-19

# ---- Set up environment ----

# Clear R environment
rm(list = ls(all=TRUE))

# Load packages
library(dplyr)


# ---- Read data ----

SearchResults = read.csv("00_rawdata/WOS_searchResults_all.csv",stringsAsFactors = F)

# ---- Examine data ----

SearchResults %>% filter(Publication.Year <= "2010") %>% nrow()

SearchResults %>% filter(Publication.Year > "2010") %>%
  count(Screening_by.title,Screening_by.abstract,Screening_by.fulltext)
