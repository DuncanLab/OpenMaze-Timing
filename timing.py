import RPi.GPIO as GPIO
import time
import threading # for threading to ensure time consistency
import datetime

# Configure sensor input from Raspberry pi
GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(4, GPIO.IN) # photo sensor IN at pin 4
GPIO.setup(18, GPIO.IN) # sound sensor IN at pin 18

class Timing:
    '''
    Overarching class containing all timing-relevant functions.

    The purpose of this class is to facillatate accurate timing
    of certain events for OpenMaze (ie when a new trial starts
    and a new screen appears in front of the user, is unity
    reporting the same information as what is actually going on?)

    Two basic sensors are used: a photo light sensor and a sound
    sensor are leveraged to trigger timing events between the
    experiment running in Unity and the raspberry pi. 
    
    '''
    def __init__(self, startTime):
        '''
        Initialize class with current time and store original
        time.
        '''
        self.startTime = startTime
        print(self.startTime) # print class start time for reference

    def printSensorStream(self):
        '''
        Basic function to print out a stream of sensor data to the
        console. 
        '''
        while True:
            # flip photo sensore value for consistency with sounds sensor 
            print(int(not GPIO.input(4)), GPIO.input(18))

    def sensorDataAndTime(self):
        '''
        Function prints out sensor data as
        (photo / sound / time in milliseconds since
        start time). 
        '''
        # open a new thread and report sensor data every x seconds
        threading.Timer(5.00000, self.sensorDataAndTime).start()
        print(str(int(not GPIO.input(4))) +
              '/' + str(GPIO.input(18)) +
              '/' + str(datetime.datetime.now()-self.startTime))
        

timingTrial = Timing(datetime.datetime.now()) #initialize class with current time
timingTrial.sensorDataAndTime(); # run function of choice
        
