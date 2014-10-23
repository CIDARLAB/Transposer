#!/usr/bin/env python
import phScan
from twython import Twython

print "Welcome to TweeColi!"

# Set high and low pH thresholds
hi = 8
lo = 6

# Put your twitter api keys and tokens below
# Note: The current api keys correspond to @TweeColi 
apiKey = 'RJSlPyCo084MJKX63tdygPNqZ'
apiSecret = 'E5i83RLt9VisK4zCngIyHBYxIJx46GD89oowaAiSq4BZeqLXiT'
accessToken = '2798012371-BYjTww8SShM4lUoh2RNpoAB4TJ1aZLcCQRGZUBc'
accessTokenSecret = 'neGup8dLJbdlezQb2FrEKNHsxYdQUJCZbDxJ10Iinch7x'
# Set up twython
api = Twython(apiKey,apiSecret,accessToken,accessTokenSecret) 

# Initialize pHPre variable, which stores the previous pH reading
pHPre = 7

# Continuous pH readings
while True:
	pH = phScan.readLine()
	# Test float conversion in case of textual system response instead of data
	try:
		pH = float(pH)
	except:
		print "Failed to parse float: ", pH
		continue
	# Test for movement from out of steady-state into steady state
  	if(not(hi > pHPre > lo) and (hi > pH > lo)):
		tweetStr = "Everything is ok! My pH is now %r" % pH
		api.update_status(status=tweetStr)
		print "Tweeted: " + tweetStr
	# Test for movement from steady-state to outside of threshold
	elif((hi > pHPre > lo) and not(hi > pH > lo)):
		tweetStr = "Ack! My pH is at %r" % pH
		api.update_status(status=tweetStr)
		print "Tweeted: " + tweetStr
	# Print debugging message
	else:
		print "pHPre = %r pH = %r" % (pHPre, pH)
	pHPre = pH
