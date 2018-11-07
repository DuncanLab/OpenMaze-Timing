import RPi.GPIO as GPIO
import time
import threading # for threading to ensure time consistency
import datetime
from pandas import DataFrame # used for xlsx generation

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
    # following three arrays are used to line up appropriate data for
    # conversion to spreadsheet for processing.
    
        
    def __init__(self, startTime):
        '''
        Initialize class with current time and store original
        time.
        '''
        self.startTime = startTime
        self.lightSensorArray = [] # init array of all data from light sensor
        self.soundSensorArray = [] # init array of all data from sound sensor
        self.timeDataArray = [] # init array of all captured time data
        print(self.lightSensorArray, self.soundSensorArray, self.timeDataArray)
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
        threading.Timer(0.1000, self.sensorDataAndTime).start()
        print(str(int(not GPIO.input(4))) +
              '/' + str(GPIO.input(18)) +
              '/' + str(datetime.datetime.now()-self.startTime))

    def concatDataToArray(self, lightSensorInput, soundSensorInput, currentTime):
        '''
        Add line of processed data from sensors and time to appropriate
        array. 
        '''
        print('raw', lightSensorInput, soundSensorInput, str(currentTime-self.startTime))
        #print('raw', lightSensorInput, soundSensorInput, currentTime)
        print('')
        #print('processed', self.lightSensorArray, self.soundSensorArray)
        #print('processed', self.lightSensorArray, self.soundSensorArray, self.timeDataArray)
        
        return(self.lightSensorArray.append(lightSensorInput),
                self.soundSensorArray.append(soundSensorInput),
                self.timeDataArray.append(currentTime))

    def toExcel(self):
        '''
        Convert all stored data to excel file and export to local path. 
        '''
        spread = DataFrame({'Light Sensor Input': self.lightSensorArray,
                            'Sound Sensor Input': self.soundSensorArray,
                            'Current Time': self.timeDataArray})
        print(spread)
        spread.to_excel('timing_output.xlsx', sheet_name='timingSheet', index=False)

    def detectChange(self, pin):
        '''
        if either light sensor input or sound sensor input changes,
        mark the change, both sensor output and time of event.
        Add these to class arrays from concatDataToArray()

        By setting function params to true or false you can choose
        if some or all sensor changes are recorded. 
        '''

        self.concatDataToArray(not GPIO.input(4),
                                   GPIO.input(18),
                                   datetime.datetime.now())
        
    def lightEdge(self, pin):
        '''
        '''
        self.concatDataToArray( not GPIO.input(4), 0, datetime.datetime.now())
        
    def lightOff(self, pin):
        '''
        '''
        self.concatDataToArray( 0, 0, datetime.datetime.now())
        
    def soundEdge(self, pin):
        '''
        '''
        self.concatDataToArray( not GPIO.input(4), 1, datetime.datetime.now())
        
    def soundOff(self, pin):
        '''
        '''
    
    
        
        
timingTrial = Timing(datetime.datetime.now()) #initialize class with current time
# timingTrial.toExcel(); # run function of choice
# timingTrial.detectChange(True, False)

GPIO.add_event_detect(4, GPIO.BOTH, callback=timingTrial.detectChange)
GPIO.add_event_detect(18, GPIO.RISING, callback=timingTrial.soundEdge)

        
