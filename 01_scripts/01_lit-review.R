# ----Script Info ----

## ---- Purpose ----

# This script examines manually extracted literature review results.

## ---- Additional Info ----

# Author: Christine M. K. Clarke 

# Date Created: 2026-02-19

# ---- Set up environment ----

# Clear R environment
rm(list = ls(all=TRUE))

# Load packages
library(dplyr)


# ---- Read data ----

SearchResults_WoS = read.csv("00_rawdata/01_Results_WoS-search.csv",stringsAsFactors = F)
SearchResults_O = read.csv("00_rawdata/01_Results_Other.csv",stringsAsFactors = F)
SearchResults_G2025 = read.csv("00_rawdata/01_Results_Gracic-et-al-2025-references.csv",stringsAsFactors = F)

stage2 = read.csv("00_rawdata/02_FilteredResults_SecondaryScreening.csv",stringsAsFactors = F)

stage3 = read.csv("00_rawdata/03_ShortList_StudyDetails.csv",stringsAsFactors = F)


# ---- Examine data ----

## Initial Filtering ----

# Duplicates
SearchResults_G2025 %>% filter(PrefilterRejectStage == "Duplicate check") %>%  count(PrefilterRejectDetails)

# year:

SearchResults_WoS %>% filter(Publication.Year <= "2010") %>% nrow() +
  SearchResults_G2025 %>% filter(PrefilterRejectStage == "Year") %>% nrow()

# Pre-filter
SearchResults_G2025 %>% filter(!(PrefilterRejectStage %in% c("Duplicate check","Year"))) %>% count(PrefilterRejectStage)

# Content filtering
SearchResults_WoS %>% filter(Publication.Year > "2010") %>%
  count(Screening_by.title,Screening_by.abstract,Screening_by.fulltext)

SearchResults_G2025 %>% filter(is.na(PrefilterRejectStage)) %>% count(Screening_by.title,Screening_by.abstract,Screening_by.fulltext)

## Secondary Screening ----

stage2 %>% filter(SelectedForDetailedConsideration=="No") %>% count(Comments)

## Short list ----


