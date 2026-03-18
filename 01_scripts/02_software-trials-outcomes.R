# ----Script Info ----

## ---- Purpose ----

# This script examines processing times of software trials

## ---- Additional Info ----

# Author: Christine M. K. Clarke 

# Date Created: 2026-03-17

# ---- Set up environment ----

# Clear R environment
rm(list = ls(all=TRUE))

# Load packages
library(dplyr)
library(ggplot2)
library(lubridate)


# ---- Read data ----

dataBatches = read.csv("00_rawdata/04_SoftwareTrial_DataBatches.csv",stringsAsFactors = F)
processingTimes = read.csv("00_rawdata/05_SoftwareTrial_ProcessingTimes.csv",stringsAsFactors = F)




# ---- Format data ----

dataBatches = dataBatches %>% 
  select(Dataset,AudioLength_Days,SamplingFrequency_kHz)

processingTimes = processingTimes %>% 
  left_join(dataBatches, relationship = "many-to-one") %>% 
  mutate(Start_datetime = ymd_hm(Start),
         End_datetime = ymd_hm(Finish),
         AudioLength = ddays(AudioLength_Days),
         ProcessingTime_minutes = End_datetime - Start_datetime,
         ProcessingSpeedFactor = AudioLength / ProcessingTime_minutes,
         TrialType = case_when(Software == "Triton" & methodVariant != "5s 100Hz resolution" ~ "WithinMethodVariant",
                               Software == "Triton" & DecimateFactor != "1" ~ "WithinMethodVariant",
                               Software == "Triton" & Start == "20260311T0811" ~ "Repeatability",
                               Software == "Raven" & DecimateFactor == "1" ~ "WithinMethodVariant",
                               T ~ "Primary"
                                       ))

# for processing that were done with pre-decimated files, add decimation time to total time
totalProcessingTimes = processingTimes %>% 
  filter(Approach == "Decimate" | TrialType == "Primary") %>% 
  group_by(Dataset) %>%
  mutate(DecimateTime = ProcessingTime_minutes[Approach == "Decimate"]) %>%
  ungroup() %>% 
  mutate(DecimateTime = case_when(DecimateFactor == 1 | is.na(DecimateFactor) ~ dminutes(0),
                                          T ~ DecimateTime)) %>% 
  filter(Approach != "Decimate") %>% 
  mutate(TotalTime = ProcessingTime_minutes + DecimateTime,
         TotalSpeedFactor = AudioLength / TotalTime)




# ---- Examine data ----

## ---- Within-Method variants ----

### ---- Triton ----

TritonLTSA_subtrials = processingTimes %>% filter(Software == "Triton", Dataset == "Fundian Channel")

TritonLTSA_benchmark = TritonLTSA_subtrials %>% filter(TrialType == "Primary") %>% 
  pull(ProcessingTime_minutes) %>% as.numeric()
TritonLTSA_repeat = TritonLTSA_subtrials %>% filter(TrialType == "Repeatability") %>% 
  pull(ProcessingTime_minutes) %>% as.numeric()
TritonLTSA_decimated = TritonLTSA_subtrials %>% filter(DecimateFactor == "5") %>% 
  pull(ProcessingTime_minutes) %>% as.numeric()
TritonDecimate = TritonLTSA_subtrials %>% filter(Approach == "Decimate") %>% 
  pull(ProcessingTime_minutes) %>% as.numeric()
TritonLTSA_lowres = TritonLTSA_subtrials %>% filter(methodVariant == "20s 100Hz resolution") %>% 
  pull(ProcessingTime_minutes) %>% as.numeric()


# reproducability:

((TritonLTSA_repeat - TritonLTSA_benchmark) / TritonLTSA_benchmark) * 100
# 5% time variation with exact replicate


# decimating: 

((TritonLTSA_decimated - TritonLTSA_benchmark) / TritonLTSA_benchmark) * 100
# 21% time saving once decimated, but...
((TritonLTSA_decimated + TritonDecimate - TritonLTSA_benchmark) / TritonLTSA_benchmark) * 100
# 15% time cost when factoring the time required to decimate


# resolution:

((TritonLTSA_lowres - TritonLTSA_benchmark) / TritonLTSA_benchmark) * 100
# negligible difference (+2.7%) in processing time


### ---- Raven -----

Raven_decimated = processingTimes %>% 
  filter(Software == "Raven", Dataset == "Fundian Channel", TrialType == "Primary") %>% 
  pull(ProcessingTime_minutes) %>% as.numeric()

Raven_benchmark = processingTimes %>% 
  filter(Software == "Raven", Dataset == "Fundian Channel", DecimateFactor == "1") %>% 
  pull(ProcessingTime_minutes) %>% as.numeric()

# decimating:

((Raven_decimated - Raven_benchmark) / Raven_benchmark) * 100
# 76% time saving once decimated, and...
((Raven_decimated + TritonDecimate - Raven_benchmark) / Raven_benchmark) * 100
# still 56% time saving when factoring the time required to decimate

## ---- Covariates of performance ----

### ---- CABLE ----

log_dat = read.csv("02_outdata/CABLE_logData.csv", stringsAsFactors = F)

CABLEprocessing = log_dat %>% 
  group_by(RecordingSubdirectory) %>% 
  summarise(ClicksFound = sum(ClicksFound), ClicksPassed = sum(ClicksPassed)) %>% 
  mutate(Dataset = case_when(RecordingSubdirectory == "BonavistaBay_2025-07" ~ "Bonavista Bay",
                             RecordingSubdirectory == "FCM-2023-08_September2023" ~ "Fundian Channel",
                             RecordingSubdirectory == "GDSE_2022_10-May2023" ~ "The Gully",
                             RecordingSubdirectory == "WhiteheadLab_2025-06" ~ "Flemish Pass"), .keep = "unused") %>% 
  left_join(processingTimes %>% 
              filter(Software == "CABLE"))

cor(CABLEprocessing$ClicksFound, CABLEprocessing$ProcessingSpeedFactor)


# ---- Plot data ----

totalProcessingTimes %>% 
  ggplot() + geom_point(aes(Dataset,TotalSpeedFactor, col = Software), size = 4)+
  ylab("Processing Speed (multiple of real time)")+
  theme_classic()

CABLEprocessing %>% ggplot() + geom_point(aes(ClicksFound,ProcessingSpeedFactor))



  