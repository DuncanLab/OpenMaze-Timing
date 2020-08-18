library("data.table")
library("dplyr")
library("ggplot2")
library("MASS")
library("tidyverse")
library("stringr")
library("psych")

#Set working directory
setwd("C:/Users/Ky Squared/Google Drive/Projects/OpenMaze/Timing/Analysis/Collision")

#Load Raspberry Pi Data
CollisionRP <- as.data.table(fread("CollisionRP.csv", stringsAsFactors = FALSE))

#Clean Raspberry Pi Data
#FORMAT COLUMN NAMES & Time stamps
CollisionRP <- CollisionRP[, `:=`  (Light = `Light Sensor Input`, Sound = `Sound Sensor Input`)
                           ][,`:=` (`Light Sensor Input` = NULL, `Sound Sensor Input` = NULL)
                             ][,TimeRP := str_sub(CollisionRP$`Current Time`, start = 12)
                               ][,TimeRP := as.POSIXct(CollisionRP$TimeRP, format = "%H:%M:%OS")
                                 ][, `:=` (`Current Time` = NULL, `Start Time` = NULL)]

#reduce data to only include Collection Trials Onset and Collisions (Light = 1 = Start of trial Light = True = Sound)
CollisionRP <- CollisionRP[Light != 0 & Light != FALSE][Light != lag(Light) | TimeRP - lag(TimeRP) > 0.3]
CollisionRP <- CollisionRP[!c(1:4), .(TimeRP, CollisionRP = ifelse(Light == 1, 0,1))]


#Load OpenMaze data
columns <- c("TimeStamp","BlockIndex","TrialIndex", "TrialInBlock", "Collision")
CollisionOM <- as.data.table(fread("CollisionOM.csv", select = columns, stringsAsFactors = FALSE))
rm(columns)
###Clean up OpenMaze Data
#Format time stamps  
CollisionOM[,TimeOM := str_sub(CollisionOM$TimeStamp, start = 12, end = -4)
            ][,TimeOM := as.POSIXct(CollisionOM$TimeOM, format = "%H:%M:%OS")
              ][, TimeStamp := NULL
                ][, TrialTime := TimeOM - min(TimeOM), by = .(BlockIndex, TrialInBlock)
                  ]

#Get Collision points and trial start time
CollisionOM <- CollisionOM[(TrialTime == 0 | Collision == 1) & BlockIndex != 1 & TrialIndex != 1 & TrialInBlock != 0]
CollisionOM[, CollisionOM := ifelse(Collision ==1, 1, 0)][, `:=` (TrialIndex = NULL, Collision = NULL, TrialTime = NULL)]


#Combine Data for analysis
Collision <- cbind(CollisionOM, CollisionRP)
#Add experiment & trial times 
Collision[, `:=` (ExpOM = TimeOM - min(TimeOM), ExpRP = TimeRP - min(TimeRP))][, `:=` (TrialOM = TimeOM - min(TimeOM), TrialRP = TimeRP - min(TimeRP)), by = .(BlockIndex, TrialInBlock)]
#Calculate difference between RP and OM
Collision[, `:=` (ExpDiff = (as.numeric(ExpRP - ExpOM))*1000, TrialDiff = (as.numeric(TrialRP-TrialOM))*1000)]
#Summary Stats
Collision[,BlockIndex := as.factor(BlockIndex)]

Collision_Block2 <-Collision[BlockIndex ==2]
Collision_Block3 <-Collision[BlockIndex ==3]
Collision_Block4 <-Collision[BlockIndex ==4]

aov.Collision <- aov(ExpDiff~BlockIndex, data = Collision)
summary(aov.Collision)

describe(Collision$ExpDiff)
describe(Collision_Block2$ExpDiff)
describe(Collision_Block3$ExpDiff)
describe(Collision_Block4$ExpDiff)


boxplot(Collision$ExpDiff)
describe(Collision$ExpDiff)
boxplot(Collision$TrialDiff)
describe(Collision$TrialDiff)






