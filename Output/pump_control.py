#!/usr/bin/python

# Copyright 2013 Michigan Technological University
# Author: Bas Wijnen <bwijnen@mtu.edu>
# This design was developed as part of a project with
# the Michigan Tech Open Sustainability Technology Research Group
# http://www.appropedia.org/Category:MOST
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or(at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# 2 June 2015
# Original file modified by arolfe@bu.edu to edit out the web interface 
# with the intention of using it as a module for python scripts

# 3 June 2015
# ryan.jay.silva@gmail.com added a flow and speed method and removed
# unnecessary methods and pin assignments


import sys
import argparse
import time
import math
import RPi.GPIO as gpio

class Pump:
    def __init__(self, pitch, stepAngle, microsteps, syringeID):
	self.steps_per_rev = 360 / float(stepAngle)
	print "steps_per_rev = %s" % self.steps_per_rev
	self.pulse_per_rev = self.steps_per_rev * microsteps
	print "pulse_per_rev = %s" % self.pulse_per_rev
	self.mm_per_pulse = float(pitch) / self.pulse_per_rev
	print "mm_per_pulse = %s" % self.mm_per_pulse
	self.ml_per_pulse = math.pi * math.pow(float(syringeID) / 2, 2) * float(self.mm_per_pulse) / 1000 # <- converts mm^3 to mL
	print "ml_per_pulse = %s" % self.ml_per_pulse
    def flow(self, amount, seconds, DIR, STEP):
	pulses = abs(int(float(amount) / self.ml_per_pulse))
	print "pulses = %s" % pulses 
	print "seconds = %s" % seconds
	wait_time = seconds / float(pulses) / 2.
	print "wait_time = %s" % wait_time 
	if (wait_time < 0.0003):
		suggest = 0.0003 * pulses * 2
		print "WARNING: Too fast! Suggest increasing time to %s" % suggest
        gpio.output(DIR, gpio.HIGH if amount > 0 else gpio.LOW)
    	time.sleep(wait_time)
        for t in range(pulses):
            gpio.output(STEP, gpio.HIGH)
    	    time.sleep(wait_time)
            gpio.output(STEP, gpio.LOW)
    	    time.sleep(wait_time)
    def dispense_slow(self, amount, DIR, STEP):
	pulses = abs(int(float(amount) / self.ml_per_pulse))
	print "pulses = %s" % pulses 
	wait_time = 0.0005
	print "wait_time = %s" % wait_time 
	gpio.output(DIR, gpio.HIGH if amount > 0 else gpio.LOW)
    	time.sleep(wait_time)
        for t in range(pulses):
            gpio.output(STEP, gpio.HIGH)
    	    time.sleep(wait_time)
            gpio.output(STEP, gpio.LOW)
    	    time.sleep(wait_time)
