import ast
import Parse_Tweet
from pump_control import Pump
from time import sleep
import RPi.GPIO as gpio
from twython import TwythonStreamer

# Keys for @BUBacteria
apiKey = 'hbkblS9wvLUroL7tRI6MIO3Hj'
apiSecret = 'EwVdnrn1DJzuxuyRDbzgoy1eh6it7x3PMesUoqIaDGstob3FPI'
accessToken = '2860939569-oVLMyzz7TeQ3A5ji5WNPROIYQlZZTQ42dThvq7I'
accessTokenSecret = 'Op5kNa6MCOTNtSHsoLoXZ4lT5He5JwMvBQOrdJpEqH4je'

# Keys for @TweeColi
#apiKey = 'RJSlPyCo084MJKX63tdygPNqZ'
#apiSecret = 'E5i83RLt9VisK4zCngIyHBYxIJx46GD89oowaAiSq4BZeqLXiT'
#accessToken = '2798012371-BYjTww8SShM4lUoh2RNpoAB4TJ1aZLcCQRGZUBc'
#accessTokenSecret = 'neGup8dLJbdlezQb2FrEKNHsxYdQUJCZbDxJ10Iinch7x'

DIR = 11
STEP = 13

gpio.setmode(gpio.BOARD)
gpio.setup(STEP, gpio.OUT, initial = gpio.HIGH)
gpio.setup(DIR, gpio.OUT, intital = gpio.HIGH)

pitch = 0.8
stepAngle = 1.8
microsteps = 1
syringeID = 14.8
p = Pump(pitch, stepAngle, microsteps, syringeID)

print "Current number of chemical inputs is 2"
print "Listening to @ryanjaysilva and @TweeColi"

is_valid=0

while not is_valid:
	try:
		# User-defined variables
		chem0Name = raw_input("What chemical is the first input node sensing? Limit answer to 5-characters?: ") 
		chem1Name = raw_input("What chemical is the second input node sensing? Limit answer to 5-characters?: ") 
        except KeyboardInterrupt:
	        gpio.cleanup()
	else:
		if len(chem0Name) > 5 or len(chem1Name) > 5:
			print("Chemical name is too long. Try again")
		else:
			# Exit the loop
			is_valid=1


try:
	class MyStreamer(TwythonStreamer):
		# Initialize variables
		chem0 = 0
		chem1 = 0
		def on_success(self, data):
			if 'text' in data:
				# Assumed tweet format: chemical state (ex. aTc True)
				message = Parse_Tweet.get_message(data)
				username = Parse_Tweet.get_username(data)
				if message['chemical'] == chem0Name:
					if message['state'] == "True":
						self.chem0 = 1
					else:
						self.chem0 = 0
					print message
					print self.chem0
				else:
					print("no %s update") % chem0Name
				if message['chemical'] == chem1Name:
					if message['state'] == "True":
						self.chem1 = 1
					else:
						self.chem1 = 0
					print message
					print self.chem1
				else:
					print("No %s update") % chem1Name
				if (self.chem0 ^ self.chem1):
					p.dispense_slow(1, DIR, STEP)
					print "Dispensing"
				else:
					print (self.chem0 ^ self.chem1)
					
		def on_error(self, status_code, data):
			print status_code
	
	stream = MyStreamer(apiKey, apiSecret,
		    	accessToken, accessTokenSecret)
	# User id below is @ryanjaysilva
	stream.statuses.filter(follow='606389094,2798012371')
	# User id below is @TweeColi
	#stream.statuses.filter(follow=2798012371)
	# User id below is @bubacteria
	#stream.statuses.filter(follow=2860939569)
except KeyboardInterrupt:
	gpio.cleanup()
