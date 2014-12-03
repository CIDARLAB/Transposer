import ast
import Parse_Tweet
from time import sleep
import RPi.GPIO as GPIO
from twython import TwythonStreamer

# Keys for @BUBacteria
#apiKey = 'hbkblS9wvLUroL7tRI6MIO3Hj'
#apiSecret = 'EwVdnrn1DJzuxuyRDbzgoy1eh6it7x3PMesUoqIaDGstob3FPI'
#accessToken = '2860939569-oVLMyzz7TeQ3A5ji5WNPROIYQlZZTQ42dThvq7I'
#accessTokennSecret = 'Op5kNa6MCOTNtSHsoLoXZ4lT5He5JwMvBQOrdJpEqH4je'

# Keys for @TweeColi
apiKey = 'RJSlPyCo084MJKX63tdygPNqZ'
apiSecret = 'E5i83RLt9VisK4zCngIyHBYxIJx46GD89oowaAiSq4BZeqLXiT'
accessToken = '2798012371-BYjTww8SShM4lUoh2RNpoAB4TJ1aZLcCQRGZUBc'
accessTokenSecret = 'neGup8dLJbdlezQb2FrEKNHsxYdQUJCZbDxJ10Iinch7x'


GPIO.setmode(GPIO.BCM)
GPIO.setup(25, GPIO.OUT)
GPIO.setup(24, GPIO.OUT)

# Initialize variables
aTc_state = 0
Ara_state = 0

try:
	class MyStreamer(TwythonStreamer):
		def on_success(self, data):
			if 'text' in data:
				# Assumed tweet format: chemical state (ex. aTc True)
				message = Parse_Tweet.get_message(data)
				username = Parse_Tweet.get_username(data)
				if message['chemical'] == "aTc":
					if message['state'] == "True":
						aTc_state = 1
					else:
						aTc_state = 0
					print aTc_state
					GPIO.output(24, aTc_state)
				else:
					print "no aTc update"
				if message['chemical'] == "Ara":
					if message['state'] == "True":
						Ara_state = 1
					else:
						Ara_state = 0
					print message
					print Ara_state
					GPIO.output(25, Ara_state)
				else:
					print "No Ara update"
					
		def on_error(self, status_code, data):
			print status_code
	
	stream = MyStreamer(apiKey, apiSecret,
		    	accessToken, accessTokenSecret)
	# User id below is @ryanjaysilva
	stream.statuses.filter(follow=606389094)
	# User id below is @TweeColi
	#stream.statuses.filter(follow=2798012371)
	# User id below is @bubacteria
	#stream.statuses.filter(follow=2860939569)
except KeyboardInterrupt:
	GPIO.cleanup()
