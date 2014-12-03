import ast

# Assumed tweet format: chemical state (ex. aTc True)

def get_message(data):
	text = data['text'].split(' ')
	message = {'chemical' : text[0], 'state' : text[1]}
	return message
def get_username(data):
	username = data['user']['screen_name']
	return username
