# Welcome to TweeColi!
Get real-time status updates from the E.Coli in our lab!

## Setup

- Connect the RPi to the internet
- Clone the repository to the home directory
```$ git clone https://github.com/CIDARLAB/Bioelectronics```
- Make the setup script executable
```$ sudo chmod +x makeEverything.sh```
- Execute the setup script
```$ ./makeEverything```

### Input Node 
TweeColi is meant to be used along with the [Atlas Scientific EZO pH circuit](https://www.atlas-scientific.com/product_pages/circuits/ezo_ph.html?). The following will ensure the stamp is setup to correctly feed data to python.
- Enter minicom ```$ minicom -b 38400 -D /dev/ttyAMA0```
- Calibrate the stamp
 - Datasheet can be found [here](https://www.atlas-scientific.com/_files/_datasheets/_circuit/pH_EZO_datasheet.pdf?)
- Ensure the EZO circuit is operating in continuous-read mode 
- Disable stamp Response 
- Exit minicom by CTRL-A X

Here are things to check/update in the python module:
- Set the high and low pH thresholds in TweeColivX.py
- Ensure API keys in TweeColivX.py are for the account you wish to update
- Start TweeColi ```python TweeColivX.py```

### Output Node

Here are things to check/update in the python module:
- Ensure API keys in TweeColivX.py are for the account you are using to establish the Twython streamer
- Ensure GPIO pins are correct
- Start Streamer ```sudo python TweeColi_Output.py```
 - Must run as root to access GPIO on the RPi 
