import RPi.GPIO as GPIO
import time
import threading # for threading to ensure time consistency
import datetime
from pandas import DataFrame # used for xlsx generation
import pygame # for keypress detection and initial syncronization
import sys # for termination of program

# Configure sensor inputs from Raspberry pi
GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(4, GPIO.IN) # photo sensor IN at pin 4
GPIO.setup(18, GPIO.IN) # sound sensor IN at pin 18
GPIO.setup(26, GPIO.IN, pull_up_down=GPIO.PUD_UP) # button input IN at pin 26

class Timing:
    '''
    Overarching class containing all timing-relevant functions.

    The purpose of this class is to facillatate accurate (to 10
    milliseconds) timing of certain events for OpenMaze
    (ie when a new trial starts and a new screen appears in
    front of the user, is Unity reporting the same information
    as what is actually going on?)

    Three basic sensors are used: a photo light sensor and a sound
    sensor are leveraged to trigger timing events between the
    experiment running in Unity and the raspberry pi. A simple
    switch is used to determine when to start and stop the
    experiment. 
    
    '''
        
    def __init__(self, startTime):
        '''
        Initialize class with current time and store original
        time. Also initialize arrays to store data for sensor
        fire events and corresponding times.

        Finally, output current time and state that experiment
        has loading and awaiting start. 
        '''
        self.startTime = startTime # set time var to init time
        self.lightSensorArray = [] # init array of all data from light sensor
        self.soundSensorArray = [] # init array of all data from sound sensor
        self.timeDataArray = [] # init array of all captured time data
        self.experimentStart = False # Bool to know if button has been clicked. 

        print(self.startTime)
        print('Experiment has loaded, awaiting button press to start timing.')
        
    def printSensorStream(self):
        '''
        Basic function to print out a stream of sensor data to the
        console.

        Use for debugging light and sound sensors when getting set
        up. 
        '''
        while True:
            # flip photo sensore value for consistency with sounds sensor 
            print(int(not GPIO.input(4)), GPIO.input(18))

    def sensorDataAndTime(self):
        '''
        Function prints out sensor data as
        (photo / sound / time in milliseconds since
        start time).

        Use to test sensor and time integration as a stream
        of moniterable outputs. 
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
                self.timeDataArray.append(str(currentTime)))

    def toExcel(self):
        '''
        Convert all stored data to excel file and export to local path. 
        '''
        spread = DataFrame({'Light Sensor Input': self.lightSensorArray,
                            'Sound Sensor Input': self.soundSensorArray,
                            'Current Time': self.timeDataArray,
                            'Start Time': str(self.startTime)
                            })
        print(spread)
        spread.to_excel(str(datetime.datetime.now()) + 'timing_output.xlsx', sheet_name='timingSheet', index=False)

    def detectChange(self, pin):
        '''
        if either light sensor input or sound sensor input changes,
        mark the change, both sensor output and time of event.
        Add these to class arrays from concatDataToArray()

        '''

        self.concatDataToArray(int(not GPIO.input(4)),
                                   GPIO.input(18),
                                   datetime.datetime.now())
        
    def lightEdge(self, pin):
        '''
        '''
        self.concatDataToArray( not GPIO.input(4), 0, datetime.datetime.now())
        
    def soundEdge(self, pin):
        '''
        '''
        self.concatDataToArray( not GPIO.input(4), 1, datetime.datetime.now())

    def runTimingExperiment(self):
        '''
        Initial function run to start sensor readings and syncronize unity
        game and raspberry pi.

        Once 's' key is pressed on an attached keyboard, timing experiment will
        start and output to a csv file.

        Function will also listen for 'f' key press to stop sensor detection
        and put all data into a xlsx file for output. 
        '''

        pygame.init()
        pygame.display.set_mode((100,100))
        while True:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    pygame.quit()
                if event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_s:
                        print('Experiment START. Data collection init.')

                        # Mark current time, save to var

                        # Begin sensor output and save to arrays w/ timestamps
                        self.detectSurroundings()

                         
                    if event.key == pygame.K_f:
                        print('Experiment END. xlsx file generating.')

                        # Stop sensor output
                        self.endDetectSurroundings()

                        # Push data arrays to xlsx file and output.

                        # Terminate program
        
    def detectSurroundings(self):
        '''
        
        '''
        GPIO.add_event_detect(4, GPIO.BOTH, callback=self.detectChange)
        GPIO.add_event_detect(18, GPIO.BOTH, callback=self.soundEdge)

    def endDetectSurroundings(self):
        '''
        
        '''
        GPIO.remove_event_detect(4)
        GPIO.remove_event_detect(18)

    def button_callback(self, pin):
        if not self.experimentStart:
            print('Experiment Started')
            self.startTime = datetime.datetime.now()
            print('new start time:' + str(self.startTime))
            GPIO.add_event_detect(4, GPIO.BOTH, callback=self.detectChange)
            GPIO.add_event_detect(18, GPIO.BOTH, callback=self.soundEdge)

            self.experimentStart = True
        else:
            GPIO.remove_event_detect(4)
            GPIO.remove_event_detect(18)
            print('Experiment End')

            self.toExcel()
            
            self.experimentStart = False
            sys.exit()

                       
    

# timingTrial.toExcel(); # run function of choice
# timingTrial.detectChange(True, False)

'''
Activate both sound and light sensor to fire events when a change occurs. 
'''
timingTrial = Timing(datetime.datetime.now()) #initialize class with current time

#timingTrial.runTimingExperiment();


GPIO.add_event_detect(26,GPIO.RISING,callback=timingTrial.button_callback) # Setup event on pin 10 rising edge

'''
while True:
    input_state = GPIO.input(26)
    if input_state == False and experimentStart == False:
        print('Experiment Started')
        
        GPIO.add_event_detect(4, GPIO.BOTH, callback=timingTrial.detectChange)
        GPIO.add_event_detect(18, GPIO.BOTH, callback=timingTrial.soundEdge)

        experimentStart = True
        time.sleep(0.2)
    elif input_state == False and experimentStart == True:

        GPIO.remove_event_detect(4)
        GPIO.remove_event_detect(18)
        print('Experiment End')
        experimentStart = False
        time.sleep(0.2)
        '''
