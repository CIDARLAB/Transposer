#!/usr/bin/env python
import phScan
import datetime
from twython import Twython

print "Welcome to TweeColi!"

# Set high and low pH thresholds
hi = 8
lo = 6

# Keys for @ryanjaysilva
apiKey = 'fu4svJdREnATr3tNsLEhOvv5b'
apiSecret = 'uKOhBYw5W3Rlk1RUtPtjo8DERQko8uiQi9l9VddWAU5pAzUZ6e'
accessToken = '606389094-6HaxmuJZ6cqr4WzuYrBd5uPPWzEqnHar7X184jcv'
accessTokenSecret = 'GkNQsYZI2L7Zr4prqlgFbgljDHKH6BtpPrOUwuIh9XPY7'


# Keys for @BUBacteria
#apiKey = 'hbkblS9wvLUroL7tRI6MIO3Hj'
#apiSecret = 'EwVdnrn1DJzuxuyRDbzgoy1eh6it7x3PMesUoqIaDGstob3FPI'
#accessToken = '2860939569-oVLMyzz7TeQ3A5ji5WNPROIYQlZZTQ42dThvq7I'
#accessTokenSecret = 'Op5kNa6MCOTNtSHsoLoXZ4lT5He5JwMvBQOrdJpEqH4je'

# Keys for @TweeColi
#apiKey = 'RJSlPyCo084MJKX63tdygPNqZ'
#apiSecret = 'E5i83RLt9VisK4zCngIyHBYxIJx46GD89oowaAiSq4BZeqLXiT'
#accessToken = '2798012371-BYjTww8SShM4lUoh2RNpoAB4TJ1aZLcCQRGZUBc'
#accessTokenSecret = 'neGup8dLJbdlezQb2FrEKNHsxYdQUJCZbDxJ10Iinch7x'

# Set up twython
api = Twython(apiKey,apiSecret,accessToken,accessTokenSecret) 

# Initialize pHPre variable, which stores the previous pH reading
pHPre = 7
# Clear the embedded shift register by getting an initial first value
phScan.get_value()

# Continuous pH readings
while True:
	pH = phScan.get_value()
	stamp = datetime.datetime.now()
	# Test float conversion in case of textual system response instead of data
	try:
		pH = float(pH)
	except:
		print "Failed to parse float: ", pH
		continue
	# Test for movement from out of steady-state into steady state
  	if(not(hi > pHPre > lo) and (hi > pH > lo)):
		#tweetStr = "Everything is ok! My pH is now %r" % pH
		tweetStr = "aTc True at %s" % stamp
		api.update_status(status=tweetStr)
		print "Tweeted: " + tweetStr
	# Test for movement from steady-state to outside of threshold
	elif((hi > pHPre > lo) and not(hi > pH > lo)):
		tweetStr = "aTc False at %s" % stamp
		api.update_status(status=tweetStr)
		print "Tweeted: " + tweetStr
	# Print debugging message
	else:
		print "pHPre = %r pH = %r" % (pHPre, pH)
	pHPre = pH
