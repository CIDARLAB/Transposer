#!/usr/bin/env python
# TweeColi_Output will initialize chemical states to False
import phScan
import datetime
from twython import Twython

print "Welcome to TweeColi!"
users = ['ryanjaysilva', 'BUBacteria', 'TweeColi']
is_valid=0
while not is_valid:
	try:
		# User-defined variables
		hi = float(raw_input("High steady-state pH threshold: "))
		lo = float(raw_input("Low steady-state pH threshold: "))
		chem = raw_input("What chemical are you sensing? Limit answer to 5-characters?: ") 
		user = raw_input("What username will you be posting to? Choose from this list: "+', '.join(users)+" ") % users 
	except ValueError as e:
		print("'%s' is not a valid float. Try again." % e.args[0].split(": ")[1])
	else:
		if hi-lo <= 0:
			print("Low pH threshold is gt or equal to High. Try again")
		elif len(chem) > 5:
			print("Chemical name is too long. Try again")
		elif users.count(user) != 1:
			print("Invalid username. Try again")
		else:
			# Initialize pHPre variable, which stores the previous pH reading
			pHPre = lo+((hi-lo)/2)
			# Exit the loop
			is_valid=1

# Prepare API keys
if user == users[0]:
	# Keys for @ryanjaysilva
	apiKey = 'fu4svJdREnATr3tNsLEhOvv5b'
	apiSecret = 'uKOhBYw5W3Rlk1RUtPtjo8DERQko8uiQi9l9VddWAU5pAzUZ6e'
	accessToken = '606389094-6HaxmuJZ6cqr4WzuYrBd5uPPWzEqnHar7X184jcv'
	accessTokenSecret = 'GkNQsYZI2L7Zr4prqlgFbgljDHKH6BtpPrOUwuIh9XPY7'
elif user == users[1]:
	# Keys for @BUBacteria
	apiKey = 'hbkblS9wvLUroL7tRI6MIO3Hj'
	apiSecret = 'EwVdnrn1DJzuxuyRDbzgoy1eh6it7x3PMesUoqIaDGstob3FPI'
	accessToken = '2860939569-oVLMyzz7TeQ3A5ji5WNPROIYQlZZTQ42dThvq7I'
	accessTokenSecret = 'Op5kNa6MCOTNtSHsoLoXZ4lT5He5JwMvBQOrdJpEqH4je'
else:
	# Keys for @TweeColi
	apiKey = 'RJSlPyCo084MJKX63tdygPNqZ'
	apiSecret = 'E5i83RLt9VisK4zCngIyHBYxIJx46GD89oowaAiSq4BZeqLXiT'
	accessToken = '2798012371-BYjTww8SShM4lUoh2RNpoAB4TJ1aZLcCQRGZUBc'
	accessTokenSecret = 'neGup8dLJbdlezQb2FrEKNHsxYdQUJCZbDxJ10Iinch7x'

# Set up twython
api = Twython(apiKey,apiSecret,accessToken,accessTokenSecret) 

# Clear the embedded shift register by getting an initial first value
phScan.get_value()

# Continuous pH readings
while True:
	pH = phScan.get_value()
	stamp = datetime.datetime.now()
	# Test float conversion in case of textual system response instead of data
	try:
		pH = float(pH)
	except ValueError:
		print "Failed to parse float: ", pH
		continue
	# Test for movement from out of steady-state into steady state
	# This will result in a chemical False message
  	if(not(hi > pHPre > lo) and (hi > pH > lo)):
		tweetStr = "%s False at %s" % (chem, stamp)
		api.update_status(status=tweetStr)
		print "Tweeted: " + tweetStr
	# Test for movement from steady-state to outside of threshold
	elif((hi > pHPre > lo) and not(hi > pH > lo)):
		tweetStr = "%s True at %s" % (chem, stamp)
		api.update_status(status=tweetStr)
		print "Tweeted: " + tweetStr
	# Print debugging message
	else:
		print "pHPre = %r pH = %r" % (pHPre, pH)
	pHPre = pH
