#!/usr/bin/env python

# Built for ActiveState Python v3.2

# For this to run, you will require the pyserial module (currently v2.6):
# http://pypi.python.org/pypi/pyserial
# Extract the files and from the extracted folder, run "C:\Python32\python3 setup.py install"

# You also need the Win32 extensions if you do not already have them:
# http://sourceforge.net/projects/pywin32/files/pywin32/


import time
import serial
import sys
import signal
import datetime

# HELPER CODE:
# These definitions are here as helper functions to make it easier to use the serial port
# You probably dont need to worry about how they work for now!

# Define a Read_Until function for the serial port (similar to what exists for Telnet already in Python)
def SerialReadUntil (Port, Char, Timeout):
    ReturnStr = b""
    Start = datetime.datetime.now()
    Done = False

    # Loop until done
    while (Done == False):        
        # Loop through waiting chars
        while (Port.inWaiting() > 0):
            # Read 1 char
            NewChar = Port.read (1)
            # If this is the exit char
            if NewChar == Char:
                # Return the current string
                return ReturnStr
            # Else append to the current string
            else:
                ReturnStr += NewChar
                # Reset start time for latest char
                Start = datetime.datetime.now()

        # If no further chars to read and timeout has passed, exit with what we currently have
        Now = datetime.datetime.now()
        if (Now - Start).seconds > Timeout:
            return ReturnStr

    return ReturnStr

# HELPER CODE ENDS


# MAIN FUNCTION CODE:

print ("")
print ("CONNECTING")
print ("")
print ("")

# Open serial connection
ser = serial.Serial (port='/dev/ttyUSB0',
                     baudrate=19200,
                     parity=serial.PARITY_NONE,
                     stopbits=serial.STOPBITS_ONE,
                     bytesize=serial.EIGHTBITS)
time.sleep(1)

print ("")
print ("OPEN")
print ("")
print ("")

# Read and dump anything the module send on its connection screen
r = ser.flushInput()

print ("")
print ("READY")
print ("")
print ("")

# Check the module we are connected to
ser.write(b"hello?\r\n")
r = SerialReadUntil(ser,b"\n",3)
r = SerialReadUntil(ser,b">",3)
print (r)

print ("")
print ("IDENTIFIED")
print ("")
print ("")

# Test1: FAST hotplug, (can be easily modified for slower speeds)

# Set the module to defualt
ser.write(b"conf:def state\r\n")
r = SerialReadUntil(ser,b"\n",3)	#This line discards the echoed characters
r = SerialReadUntil(ser,b">",3)		#This line gets the response from the module command
print (r)

# Get up for a 'FAST' hot-plug - only need to change the source delays
ser.write(b"source:1:delay 0\r\n")
r = SerialReadUntil(ser,b"\n",3)	#This line discards the echoed characters
r = SerialReadUntil(ser,b">",3)		#This line gets the response from the module command

# 10mS until source 2
ser.write(b"source:1:delay 10\r\n")
r = SerialReadUntil(ser,b"\n",3)	#This line discards the echoed characters
r = SerialReadUntil(ser,b">",3)		#This line gets the response from the module command

# 20 mS until source 3
ser.write(b"source:1:delay 20\r\n")
r = SerialReadUntil(ser,b"\n",3)	#This line discards the echoed characters
r = SerialReadUntil(ser,b">",3)		#This line gets the response from the module command

# Power down the attached module (FAST pull)
ser.write(b"run:power down\r\n")
r = SerialReadUntil(ser,b"\n",3)	#This line discards the echoed characters
r = SerialReadUntil(ser,b">",3)		#This line gets the response from the module command
print (r)

#Sleep for 5 seconds
time.sleep(5)

# Power up the attached module (FAST plug)
ser.write(b"run:power up <1>\r\n")
r = SerialReadUntil(ser,b"\n",3)	#This line discards the echoed characters
r = SerialReadUntil(ser,b">",3)		#This line gets the response from the module command
print (r)

# Now you can just loop to repear the above steps, setting the source delays to larger or smaller values to get the failures you need!

#Test2: Fail a simgle signal

# We are currently powered up, so failing a single signal now will simulate a failure to the connector during use



# Close the connection
ser.close()
