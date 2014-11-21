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

class MyStreamer(TwythonStreamer):
	def on_success(self, data):
		if 'text' in data:
			print  data['user']['screen_name'].encode('utf-8'), ",", data['text'].encode('utf-8')
	
	def on_error(self, status_code, data):
		print status_code

stream = MyStreamer(apiKey, apiSecret,
		    accessToken, accessTokenSecret)
stream.statuses.filter(follow=606389094)
