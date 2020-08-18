####Load Packages####
library("data.table")
library("dplyr")
library("ggplot2")
library("MASS")
library("tidyverse")
library("stringr")
library("psych")
library("ggpubr")
install.packages("effsize")
library(rstatix)
library(effsize)

setwd("C:/Users/Ky Squared/Google Drive/Projects/OpenMaze/Timing/Data")
#OpenMaze Data
columns <- c("TimeStamp","BlockIndex", "TrialIndex", "TrialInBlock", "Collision", "Instructional")
Framerate_Trials <-as.data.table(fread("Framerate_Trials.csv", select = columns, stringsAsFactors = FALSE))
rm(columns)

#Format time
Framerate_Trials[,Time := str_sub(Framerate_Trials$TimeStamp, start = 12, end = -3)
         ][,Time := as.POSIXct(Framerate_Trials$Time, format = "%H:%M:%OS")]

#Remove Instruction/Cue Screen Trials
Framerate_Trials <- Framerate_Trials[Instructional == 0]


#Add Framerate column to data 
Framerate_Trials[, Rate := 1/(as.numeric(Time - lag(Time)))][, TrialTime := Time - min(Time), by = .(BlockIndex, TrialInBlock) ]

#Format for analysis
Framerate_Trials[,BlockIndex := as.factor(BlockIndex)]

#Analysis Framerate over entire trial length
boxplot(Framerate_Trials$Rate)
boxplot(Framerate_Trials$Rate, by = BlockIndex)
describe(Framerate_Trials$Rate)
aov.frames <- aov(Rate~BlockIndex, data = Framerate_Trials)
summary(aov.frames200)


#Calculate Framerate after 200ms
Framerate_Trials <- Framerate_Trials[TrialTime > .2]
boxplot(Framesrate_After200$Rate)
boxplot(Framesrate_After200$Rate, by = BlockIndex)
describe(Framesrate_After200$Rate)
aov.framesA200 <- aov(Rate~BlockIndex, data = Framesrate_After200)
summary(aov.framesA200)

#Calculate Framerate before 200ms
Framesrate_Before200 <- Framerate_Trials[TrialTime < .2]
boxplot(Framesrate_Before200$Rate)
boxplot(Framesrate_Before200$Rate, by = BlockIndex)
describe(Framesrate_Before200$Rate)
aov.framesB200 <- aov(Rate~BlockIndex, data = Framesrate_Before200)
summary(aov.framesB200)

#Block level Analysis
##All Framerate
###ALL 
t.test(Framerate_Trials$Rate[Framerate_Trials$BlockIndex ==2],Framerate_Trials$Rate[Framerate_Trials$BlockIndex ==3])
cohen.d(Framerate_Trials$Rate[Framerate_Trials$BlockIndex ==2],Framerate_Trials$Rate[Framerate_Trials$BlockIndex ==3])

t.test(Framerate_Trials$Rate[Framerate_Trials$BlockIndex ==2],Framerate_Trials$Rate[Framerate_Trials$BlockIndex ==4])
cohen.d(Framerate_Trials$Rate[Framerate_Trials$BlockIndex ==2],Framerate_Trials$Rate[Framerate_Trials$BlockIndex ==4])

t.test(Framerate_Trials$Rate[Framerate_Trials$BlockIndex ==3],Framerate_Trials$Rate[Framerate_Trials$BlockIndex ==3])
cohen.d(Framerate_Trials$Rate[Framerate_Trials$BlockIndex ==3],Framerate_Trials$Rate[Framerate_Trials$BlockIndex ==3])

##After 200ms Framerate
###ALL 
t.test(Framesrate_After200$Rate[Framesrate_After200$BlockIndex ==2],Framesrate_After200$Rate[Framesrate_After200$BlockIndex ==3])
cohen.d(Framesrate_After200$Rate[Framesrate_After200$BlockIndex ==2],Framesrate_After200$Rate[Framesrate_After200$BlockIndex ==3])

t.test(Framesrate_After200$Rate[Framesrate_After200$BlockIndex ==2],Framesrate_After200$Rate[Framesrate_After200$BlockIndex ==4])
cohen.d(Framesrate_After200$Rate[Framesrate_After200$BlockIndex ==2],Framesrate_After200$Rate[Framesrate_After200$BlockIndex ==4])

t.test(Framesrate_After200$Rate[Framesrate_After200$BlockIndex ==3],Framesrate_After200$Rate[Framesrate_After200$BlockIndex ==3])
cohen.d(Framesrate_After200$Rate[Framesrate_After200$BlockIndex ==3],Framesrate_After200$Rate[Framesrate_After200$BlockIndex ==3])

##Before 200ms Framerate
###ALL 
t.test(Framesrate_Before200$Rate[Framesrate_Before200$BlockIndex ==2],Framesrate_Before200$Rate[Framesrate_Before200$BlockIndex ==3])
cohen.d(Framesrate_Before200$Rate[Framesrate_Before200$BlockIndex ==2],Framesrate_Before200$Rate[Framesrate_Before200$BlockIndex ==3])

t.test(Framesrate_Before200$Rate[Framesrate_Before200$BlockIndex ==2],Framesrate_Before200$Rate[Framesrate_Before200$BlockIndex ==4])
cohen.d(Framesrate_Before200$Rate[Framesrate_Before200$BlockIndex ==2],Framesrate_Before200$Rate[Framesrate_Before200$BlockIndex ==4])

t.test(Framesrate_Before200$Rate[Framesrate_Before200$BlockIndex ==3],Framesrate_Before200$Rate[Framesrate_Before200$BlockIndex ==3])
cohen.d(Framesrate_Before200$Rate[Framesrate_Before200$BlockIndex ==3],Framesrate_Before200$Rate[Framesrate_Before200$BlockIndex ==3])







