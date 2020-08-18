library("data.table")
library("dplyr")
library("ggplot2")
library("MASS")
library("tidyverse")
library("stringr")

setwd("C:/Users/Ky Squared/Google Drive/Projects/OpenMaze/Timing/Data/Trials")
filenames <- list.files(pattern="*.csv")
columns <- c("TimeStamp","Instructional", "Enclosure","BlockIndex", "TrialIndex", "TrialInBlock")
TrialsOM <-fread("TrialOM.csv", select = columns, stringsAsFactors = FALSE) 
TrialsRPRAW <- fread("TrialsRP.csv", stringsAsFactors = FALSE)
#Remove unneeded data from Environment
rm(columns, filenames)

#Format timestamps OpenMaze
TrialsOM <- as.data.table(TrialsOM)
TrialsOM[,TimeStampClean := str_sub(TrialsOM$TimeStamp, start = 12, end = -3)]

#Format Timestamps Raspberry Pi
TrialsRP <- as.data.table(TrialsRPRAW)
TrialsRP[,TimeStampClean := str_sub(TrialsRP$`Current Time`, start = 12)]

#Add Experiment Time and Trial Time
TrialsOM[,TimeStampClean := as.POSIXct(TrialsOM$TimeStampClean, format = "%H:%M:%OS")
                 ][,ExpTime := TimeStampClean - min(TimeStampClean)
                   ][,TrialTime := TimeStampClean - min(TimeStampClean), by = .(BlockIndex, TrialInBlock)
                     ]

##Get Trialonset times
TrialOnsetOM <- TrialsOM[TrialTime == 0 & TrialInBlock != 0]

#Add Trial Durations
TrialOnsetOM[, TrialDuration := lead(as.numeric(ExpTime)) - as.numeric(ExpTime)]


#Format Raspberry pi data
TrialsRP <-fread("TrialsRP.csv", stringsAsFactors = FALSE)
#Format Timestamps Raspberry Pi
TrialsRP <- as.data.table(TrialsRP)
TrialsRP[,TimeStampClean := str_sub(TrialsRP$`Current Time`, start = 12)]
#Clean up data
TrialsRPClean <- TrialsRP[, Light := `Light Sensor Input`
                          ][, `Light Sensor Input` := NULL
                            ][, `Sound Sensor Input` := NULL
                              ][Light != "TRUE" & Light != "FALSE"][Light != lag(Light)]


#Format Raspberry Pi Time
TrialsRPClean[,TimeStampClean := as.POSIXct(TrialsRPClean$TimeStampClean, format = "%H:%M:%OS")
         ][,ExpTime := TimeStampClean - min(TimeStampClean)
           ][, TrialDuration := lead(as.numeric(ExpTime)) - as.numeric(ExpTime)]


#formatting data to be merged
ForAnalysisRP <- TrialsRPClean[-c(1:5)]
ForAnalysisRP[,RPTime := TrialDuration]

ForAnalysisOM <- TrialOnsetOM[-c(1:6)]
ForAnalysisOM[, OMTime := TrialDuration]

#Merge Data and calculate difference scores
Analysis <- as.data.table(cbind(ForAnalysisOM, ForAnalysisRP))
Analysis[,`:=` (OM = V1, RP = V2)][, `:=` (V1 = NULL, V2 = NULL)]
Analysis[, Diff := (OMTime - RPTime)*1000]

#Subset datat by block 
Onset_Block2 <- Analysis[BlockIndex == 2]
Onset_Block3 <- Analysis[BlockIndex == 3]
Onset_Block4 <- Analysis[BlockIndex == 4]

#Analyze difference scores
describe(Onset_Block2$Diff)
describe(Onset_Block3$Diff)
describe(Onset_Block4$Diff)


Analysis[,BlockIndex := as.factor(BlockIndex)]
aov.Onset <- aov(Diff~BlockIndex, data = Analysis)
summary(aov.Onset)

AverageDiff <- mean(Analysis$Diff, na.rm = T)*1000
MaxDiff <- max(Analysis$Diff, na.rm = T)*1000
MinDiff <- min(Analysis$Diff, na.rm = T)*1000
hist((Analysis$Diff))
StandardDeviation <- sd(Analysis$Diff, na.rm = T)*1000


