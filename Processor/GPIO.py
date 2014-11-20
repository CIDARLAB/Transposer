import RPi.GPIO as GPIO
from time import sleep
GPIO.setmode(GPIO.BCM)
GPIO.setup(25, GPIO.IN)
GPIO.setup(24, GPIO.OUT)

try:
	while True:
		if GPIO.input(25):
			print "Port 25 is 1/GPIO.HIGH/True - switch is up"
			GPIO.output(24, 1)
		else:
			print "Port 25 is 0/GPIO.LOW/False - switch is down"
			GPIO.output(24, 0)
		sleep(0.1)
except KeyboardInterrupt:
	GPIO.cleanup()
