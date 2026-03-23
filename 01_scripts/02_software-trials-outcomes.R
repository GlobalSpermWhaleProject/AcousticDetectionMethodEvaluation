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
library(stringr)


# ---- Read data ----

dataBatches = read.csv("00_rawdata/04_SoftwareTrial_DataBatches.csv",stringsAsFactors = F)
processingTimes = read.csv("00_rawdata/05_SoftwareTrial_ProcessingTimes.csv",stringsAsFactors = F)

# ---- Format data ----

dataBatches = dataBatches %>% 
  select(Dataset,AudioLength_Days,SamplingFrequency_kHz,Channels) %>% 
  mutate(Channels = as.factor(Channels))

processingTimes = processingTimes %>% 
  left_join(dataBatches, relationship = "many-to-one") %>% 
  mutate(Start_datetime = ymd_hm(Start),
         End_datetime = ymd_hm(Finish),
         AudioLength = ddays(AudioLength_Days),
         ProcessingTime_minutes = End_datetime - Start_datetime,
         ProcessingSpeedFactor = AudioLength / ProcessingTime_minutes,
         TrialType = case_when(Software == "Triton" & methodVariant != "5s 100Hz resolution" ~ "WithinMethodVariant",
                               Software == "Triton" & Approach == "LTSA" & DecimateFactor != "1" ~ "WithinMethodVariant",
                               Software == "Triton" & Approach == "Click detector" & DecimateFactor == "1" ~ "WithinMethodVariant",
                               Software == "Triton" & Start == "20260311T0811" ~ "Repeatability",
                               Software == "Raven" & DecimateFactor == "1" ~ "WithinMethodVariant",
                               Software == "PAMGuard" & (is.na(methodVariant) == F) ~ "WithinMethodVariant",
                               T ~ "Primary"
                                       ),
         Method = case_when(Software %in% c("CABLE","Gubnitky and Diamant (2024)","detEdit") ~ Software,
                            T ~ paste0(Software," - ", Approach)))

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

### ---- Triton LTSA ----

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

### ---- Triton SPICE Detector ----

TritonSPICE_subtrials = processingTimes %>% 
  filter(Software == "Triton", Approach %in% c("Click detector","Decimate"), Dataset == "Flemish Pass")

TritonSPICE_benchmark = TritonSPICE_subtrials %>% filter(DecimateFactor == "1") %>% 
  pull(ProcessingTime_minutes) %>% as.numeric()
TritonSPICE_decimated = TritonSPICE_subtrials %>% filter(DecimateFactor == "4") %>% 
  pull(ProcessingTime_minutes) %>% as.numeric()
TritonDecimate = TritonSPICE_subtrials %>% filter(Approach == "Decimate") %>% 
  pull(ProcessingTime_minutes) %>% as.numeric()

# decimating: 

((TritonSPICE_decimated - TritonSPICE_benchmark) / TritonSPICE_benchmark) * 100
# 75% time saving once decimated
((TritonSPICE_decimated + TritonDecimate - TritonSPICE_benchmark) / TritonSPICE_benchmark) * 100
# and still 67% time saving when factoring the time required to decimate


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

# Datasets

dataBatches %>% 
  ggplot() + geom_point(aes(AudioLength_Days,SamplingFrequency_kHz, 
                            col = Dataset, pch = Channels), alpha = 0.7, 
                        size = 4, stroke = 1.5, position = position_jitter(seed = 2, width = 0, height = 1))+
  ylab("Sampling Frequency (kHz)")+xlab("Total Audio Duration (Days)")+
  ylim(100,270)+xlim(0,8)+
  theme_classic()+
  scale_color_manual(values = c("#fdae61","#abd9e9","#d73027","#4575b4"))+
  guides(col = guide_legend(override.aes = list(shape = 16)))

ggsave("03_figures/Datasets.png", width = 6.5, height = 3, dpi = 300 )

# Processing times

totalProcessingTimes %>% 
  arrange(Method) %>% 
  mutate(Method = case_when(Method == "Raven - BLED" ~ "Raven Pro - BLED",
                            Method == "Triton - Click detector" ~ "Triton - SPICE detector",
                            T ~ Method),
         DatasetLabel = str_replace(Dataset," ","\n")) %>% 
  ggplot() + geom_point(aes(DatasetLabel,TotalSpeedFactor, col = Method, pch = Method), size = 4, stroke = 1.5)+
  ylab("Processing Speed\n(recording duration processed / processing time)")+xlab("Dataset")+
  scale_y_continuous(limits = c(0, NA), expand = expansion(mult = c(0, 0.05)))+
  scale_color_brewer(palette = "Paired")+
  theme_classic()

ggsave("03_figures/ProcessingSpeed.png", width = 6.5, height = 5, dpi = 300 )

CABLEprocessing %>% ggplot() + geom_point(aes(ClicksFound,ProcessingSpeedFactor))



  