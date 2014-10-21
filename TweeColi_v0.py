#!/usr/bin/env python
import phScan
from twython import Twython

print "Welcome to TweeColi!"
hi = 8				#Set high pH threshold here
lo = 6					#Set low pH threshold here

# Put your twitter api keys and tokens below
# Note: The current api keys correspond to @TweeColi 
apiKey = 'RJSlPyCo084MJKX63tdygPNqZ'
apiSecret = 'E5i83RLt9VisK4zCngIyHBYxIJx46GD89oowaAiSq4BZeqLXiT'
accessToken = '2798012371-BYjTww8SShM4lUoh2RNpoAB4TJ1aZLcCQRGZUBc'
accessTokenSecret = 'neGup8dLJbdlezQb2FrEKNHsxYdQUJCZbDxJ10Iinch7x'
# This sets up twython
api = Twython(apiKey,apiSecret,accessToken,accessTokenSecret) 

pHPre = 7
while True:
	pH = phScan.readLine()
	try:
		pH = float(pH)
	except:
		print "Failed to parse float: ", pH
		continue
  	if(not(hi > pHPre > lo) and (hi > pH > lo)):
		tweetStr = "Everything is ok! My pH is now %r" % pH
		api.update_status(status=tweetStr)
		print "Tweeted: " + tweetStr
	elif((hi > pHPre > lo) and not(hi > pH > lo)):
		tweetStr = "Ack! My pH is at %r" % pH
		api.update_status(status=tweetStr)
		print "Tweeted: " + tweetStr
	else:
		print "pHPre = %r pH = %r" % (pHPre, pH)
	pHPre = pH
