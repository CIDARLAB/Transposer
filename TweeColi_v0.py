#!/usr/bin/env python
import serial
import sys
import time
from twython import Twython

print "Welcome to TweeColi!"
high = 8				#Set high pH threshold here
low = 6					#Set low pH threshold here
usbport='/dev/ttyAMA0'			#RPi serial port
ser=serial.Serial(usbport,38400)	

# Put your twitter api keys and tokens below
# Note: The current api keys correspond to @TweeColi 
apiKey = 'RJSlPyCo084MJKX63tdygPNqZ'
apiSecret = 'E5i83RLt9VisK4zCngIyHBYxIJx46GD89oowaAiSq4BZeqLXiT'
accessToken = '2798012371-BYjTww8SShM4lUoh2RNpoAB4TJ1aZLcCQRGZUBc'
accessTokenSecret = 'neGup8dLJbdlezQb2FrEKNHsxYdQUJCZbDxJ10Iinch7x'
# This sets up twython
api = Twython(apiKey,apiSecret,accessToken,accessTokenSecret) 
line=""

while True:
	data = ser.read()
  	if(data == "\r"):
		try:
			linefl = float(line)
		except:
			print "Failed parsing float: ", line
			continue
		if(linefl > high or linefl < low):
			tweetStr = "Ack! My pH is at %r" % linefl
			api.update_status(status=tweetStr)
			print "Tweeted: " + tweetStr
			time.sleep(180)
		else:
			print "Did not Tweet:" + line
		line = ""
	else:
		line = line + data
		print line
