import ast
import Parse_Tweet
from time import sleep
import RPi.GPIO as GPIO

GPIO.setmode(GPIO.BCM)
GPIO.setup(25, GPIO.IN)
GPIO.setup(24, GPIO.OUT)

try:
	while True:
		f = open('sample_return', 'r')
		data = ast.literal_eval(f.readline())
		# Assumed tweet format: chemical state (ex. aTc True)
		message = Parse_Tweet.get_message(data)
		username = Parse_Tweet.get_username(data)
		if message['chemical'] == "aTc":
			if message['state'] == "True":
				aTc_state = 1
			else:
				aTc_state = 0
			print aTc_state
			print message
		else:
			print "Data error"
		GPIO.output(24, aTc_state)
		sleep(0.1)
except KeyboardInterrupt:
	GPIO.cleanup()
