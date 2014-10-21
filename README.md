# Welcome to TweeColi!
Get real-time status updates from the E.Coli in our lab!

##Setup
TweeColi is meant to be used along with the [Atlas Scientific EZO pH circuit](https://www.atlas-scientific.com/product_pages/circuits/ezo_ph.html?).
- Ensure the EZO circuit is operating in continuous-read mode.
- Set the high and low pH thresholds in TweeColivX.py

##Use
- TweeColi will register an alert tweet when the pH of its solution has gone outside of the designated threshold
```Ack! My pH is at XX```
- When the pH returns to a value within the established threshold it will output all-clear
```Everything is ok! My pH is now X```
