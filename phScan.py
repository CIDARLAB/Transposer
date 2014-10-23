#!/usr/bin/python

import serial

#print "Welcome to TweeColi!"

usbport='/dev/ttyAMA0'
ser=serial.Serial(usbport,38400)

#Turn on the LEDs
#ser.write(b'\rL,1\r')

def readLine():
    line=""
    reading = True
    while reading:
        data = ser.read()
        if(data == "\r"):
            reading = False
        else:
            line = line + data
    return line
