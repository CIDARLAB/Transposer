from flask import Flask
from flask import jsonify
import phScan
app = Flask(__name__)
requests = 0

@app.route('/')
def hello_world():
	return "Hello, world!"

@app.route('/scan')
def scan():
	pH = phScan.readLine()
	return jsonify(value=pH)

if __name__ == '__main__':
	#app.run(debug=False, host='0.0.0.0', port = 5003)
	app.run(debug = True, host='0.0.0.0',port=5003)
