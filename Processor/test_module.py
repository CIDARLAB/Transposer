import ast
import Parse_Tweet

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
	print "here is the username"
	print username
else:
	print "Data error"


