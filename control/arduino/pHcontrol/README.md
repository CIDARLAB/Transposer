# pH Control Experiment

The pHcontrol.pde sketch is a GUI for a pH-maintaining experiment where 2 syringes and a pH sensor are attached to a chamber and the goal is to maintain a specified pH range.

## Setup
Required Processing libraries
* [controlP5](http://www.sojamo.de/libraries/controlP5/)
* [gicentreUtils](http://www.gicentre.net/software/#/utils/)

Before running the sketch, make sure you update the port in the line 
 `myPort = new Serial(this, Serial.list()[7], 9600);` to the correct port for your machine.

## Assumptions
* Communicates with firmware using Ryan's special language commands
* Dispensing from the syringe with id 1 increases the pH of the chamber
* Dispensing from the syringe with id 2 decreases the pH of the chamber

## Features
#### Experiment Tab
The Experiment tab allows setting the following values:
* Desired pH range
* Volume of fluid in each syringe
* Desired volume to dispense from each syringe
* Time to wait between syringe dispenses

When the "Start" button is pressed, the system starts measuring and controlling the chamber pH. A graph of the measured pH trend scrolls across the bottom of the screen. The syringe fill-volumes are updated as dispenses occur and cannot be changed by the user until the experiment is stopped. The other values can be updated while the experiment runs and the changes will apply in real time.
    
#### Settings Tab
The Settings tab allows setting the following values 
* For each pump:
	* Syringe properties (Inner Diameter and Maximum Capacity)
	* Flow Profile (Acceleration and Speed) for the syringe dispenses
	* Motor step angle and number of microsteps per step
	* Pitch and motor maximum speed
* pH trend display:
	* Time between updates
	* Number of data points shown
* pH logging:
	* Turn writing the pH data to a file on or off

This tab is hidden while the experiment is in progress.