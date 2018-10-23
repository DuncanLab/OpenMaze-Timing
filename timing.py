import RPi.GPIO as GPIO
import time
import threading
import datetime

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(4, GPIO.IN)
GPIO.setup(18, GPIO.IN)

class Timing:
    def __init__(self, startTime):
        '''
        Initialize class current time.
        '''
        self.startTime = startTime
        print(self.startTime) # print class start time.

    def printSensorStream(self):
        '''
        Basic function to print out function start time
        and print a stream of sensor data as a tuple. 
        '''
        print(self.startTime)
        while True:
            # flip photo sensore value for consistency with sounds sensor 
            print(int(not GPIO.input(4)), GPIO.input(18))

    def sensorDataAndTime(self):
        '''
        Function prints out sensor data as
        photo / sound / time in milliseconds since
        start time. 
        '''
        
        threading.Timer(5.00000, self.sensorDataAndTime).start()
        print(str(int(not GPIO.input(4))) +
              '/' + str(GPIO.input(18)) +
              '/' + str(datetime.datetime.now()-self.startTime))
        
        
timingTrial = Timing(datetime.datetime.now())
timingTrial.sensorDataAndTime();
        


