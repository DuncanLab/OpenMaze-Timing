# This script exists in order to analyze timing data collected from the raspberry pi
# as well as Unity programs. The goal of this script is to identify scientifically 
# relevant lag in the Unity system depending on which environments are being used. 

# Ensure that you have loaded in first both files for analysis.

tlengths <- data.frame()

for(t in unique(X_config4_temp$`Trial Increment`)){
        dt <- subset(X_config4_temp, `Trial Increment` == t)
        x <- max(dt$`Time Since Trial Start (seconds)`)
        data <- data.frame("Trial" = t, "Length" = x)
        tlengths <- rbind(tlengths, data)
}

tlengths <- subset(tlengths, Trial != max(unique(X_config4_temp$`Trial Increment`)))

# Decompose time from Raspberry Pi timing output to something readable by R 
# and more importantly, accurate to the millisecond.
config4_timing_output$Time <- strptime(unique(config4_timing_output$`Current Time`), "%Y-%m-%d %H:%M:%OS")

# Get all time diffs from Raspberry Pi and make indexable for plotting
x = 0
for(c in 2:length(unique(config4_timing_output$Time))){
        config4_timing_output$index[c] = x
        x = x + 1
        # filter out time inputs that are an insignificant amount of time apart. 
        if(difftime(config4_timing_output$Time[c + 1], config4_timing_output$Time[c]) > 5) {
          config4_timing_output$TimeDiff[c] <- difftime(config4_timing_output$Time[c + 1], config4_timing_output$Time[c])
        } else {
          config4_timing_output$TimeDiff[c] <- NA
        }
}

# Graphs

# graph of Pi data
plot(config4_timing_output$index,config4_timing_output$TimeDiff,xlab="index",ylab="trial length (seconds)",pch=3) 
title("Raspberry Pi Trial Percieved Time")

# graph of Unity data
plot(tlengths $Length, xlab="index",ylab="trial length (seconds)")
title("Unity Engine Trial Percieved Time")

# Data Summaries

print("Summary of Raspberry Pi Percieved Time")
summary(config4_timing_output$TimeDiff)

print("Summary of Unity Perceived Time")
summary(tlengths$Length)

