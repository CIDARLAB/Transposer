import RPi.GPIO as GPIO
from time import sleep
GPIO.setmode(GPIO.BCM)
GPIO.setup(25, GPIO.OUT)
GPIO.setup(24, GPIO.OUT)

try:
	while True:
		#if GPIO.input(25):
			#print "Port 25 is 1/GPIO.HIGH/True - switch is up"
		GPIO.output(24, 0)
		GPIO.output(25, 1)
		sleep(1)
		#else:
			#print "Port 25 is 0/GPIO.LOW/False - switch is down"
		GPIO.output(24, 1)
		GPIO.output(25, 0)
		sleep(1)
except KeyboardInterrupt:
	GPIO.cleanup()
