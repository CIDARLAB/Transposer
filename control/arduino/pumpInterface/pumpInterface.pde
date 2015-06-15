import controlP5.*;
ControlP5 cp5;
String uLValue = "";
boolean direction = false;

import processing.serial.*;

float flowRate;
float totalFlow;
float ulPerRevolution;
float ulPerStep;
float syringeInnerDiameter;
float pitch;
float ulPerSecMotorSpeed;
int stepsPerRevolution;
int percentMotorSpeed;
int stepsPerSecFlowRate;
int stepsTotalFlow;

String g0CodeString;
String g1CodeString;

Serial myPort; 

void setup()
{
  size(1000,400);
  
  // List all the available serial ports:
  println(Serial.list());

  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[7], 9600);
  
  // Send a capital A out the serial port:
  //myPort.write(65);
    PFont font = createFont("AndaleMono-48.vlw",12, true);
    textFont(font);
    ControlFont cfont = new ControlFont(font,241);
    
    cp5 = new ControlP5(this);
    // change the original colors
    cp5.setColorForeground(0xffaaaaaa);
    cp5.setColorBackground(0xffffffff);
    cp5.setColorLabel(0xff555555);
    cp5.setColorValue(0xff00ff00);
    cp5.setColorActive(0xff000000);
  
  cp5.addTextfield("total ul")
     .setPosition(10,10)
     .setSize(100,25)
     .setFont(font)
     .setFocus(false)
     .setColor(color(50,50,50))
     .setText("1000")
     .setLabel("total fluid to move (uL)")
     .setAutoClear(false).keepFocus(false);
     ;
     
  cp5.addTextfield("flowRateField")
     .setPosition(10,60)
     .setSize(100,25)
     .setFont(font)
     .setFocus(false)
     .setColor(color(50,50,50))
     .setText("1000")
     .setLabel("flow rate (ul/sec)")
     .setAutoClear(false).keepFocus(false);
     ;
     
  cp5.addTextfield("syringeInnerDiameterField")
   .setPosition(150,10)
   .setSize(100,25)
   .setFont(font)
   .setFocus(false)
   .setColor(color(50,50,50))
   .setText("14.74")
   .setLabel("Syringe inner diameter (mm)")
   .setAutoClear(false).keepFocus(false);
   ;
   
   cp5.addTextfield("pitchField")
   .setPosition(150,60)
   .setSize(100,25)
   .setFont(font)
   .setFocus(false)
   .setColor(color(50,50,50))
   .setText("2.11667")
   .setLabel("Pitch of threaded rod (mm)")
   .setAutoClear(false).keepFocus(false);
   ;
   
   cp5.addTextfield("stepAngle")
   .setPosition(150,110)
   .setSize(100,25)
   .setFont(font)
   .setFocus(false)
   .setColor(color(50,50,50))
   .setText("1.8")
   .setLabel("Motor Step Angle (deg)")
   .setAutoClear(false).keepFocus(false);
   ;

   cp5.addTextfield("microstepsField")
   .setPosition(10,110)
   .setSize(100,25)
   .setFont(font)
   .setFocus(false)
   .setColor(color(50,50,50))
   .setText("8")
   .setLabel("Number of microsteps per step")
   .setAutoClear(false).keepFocus(false);
   ;
  
   cp5.addTextfield("percentMotorSpeedField")
   .setPosition(290,10)
   .setSize(100,25)
   .setFont(font)
   .setFocus(false)
   .setColor(color(50,50,50))
   .setText("100")
   .setLabel("percent motor speed")
   .setAutoClear(false).keepFocus(false);
   ;

  color c = color(0,0,255);
  smooth();
  
  flowRate=0;
  totalFlow=0;
  ulPerRevolution=0;
  stepsPerRevolution=0;
  g0CodeString = "%\n%";
  g1CodeString = "%\n%";
}

void draw()
{
  background(245);
  debugStates();
}

// G50 S2000 -> set spindle speed... is this movment speed?
void debugStates()
{
  
  pushMatrix();
  translate(10,190);
  fill(50);
  //text ("arrow up/down to zero syringe pump", 0, 0);
 
  totalFlow = float(cp5.get(Textfield.class,"total ul").getText().trim());
  flowRate = float(cp5.get(Textfield.class,"flowRateField").getText().trim());
  syringeInnerDiameter = float(cp5.get(Textfield.class,"syringeInnerDiameterField").getText().trim());
  pitch = float(cp5.get(Textfield.class,"pitchField").getText().trim());
  stepsPerRevolution = int(360 / float(cp5.get(Textfield.class,"stepAngle").getText().trim()))*int(cp5.get(Textfield.class,"microstepsField").getText().trim());
  percentMotorSpeed = int(cp5.get(Textfield.class,"percentMotorSpeedField").getText().trim());
  
  ulPerRevolution = sq(syringeInnerDiameter/2) * PI * pitch;
  ulPerStep = ulPerRevolution/stepsPerRevolution;
  ulPerSecMotorSpeed = int(map(percentMotorSpeed,0,100, 0, 1500))*1/(stepsPerRevolution/ulPerRevolution); 
  stepsPerSecFlowRate = int(flowRate/ulPerStep);
  stepsTotalFlow = int(totalFlow/ulPerStep);
  
  String dir = "PUSH";
  if(!direction)
    dir = "PULL";
  
  text("Motor + syringe settings : "+ ulPerRevolution +"uL/revolution *** 1 step = " + ulPerStep + "uL *** 1 uL = "+1/(ulPerStep) +"steps", 0, 0);
  text(int(map(percentMotorSpeed,0,100, 0,1500)) + " steps per second based on motor speed percentage", 0, 20);
  text(ulPerSecMotorSpeed + " uL per second based on motor speed percentage", 0, 40);
  text(stepsTotalFlow + " steps at " + stepsPerSecFlowRate + " steps per second based on input Flow Rate", 0, 60);
  text("Program settings : "+totalFlow +"uL @ " + flowRate +"uL/s, direction : " + dir, 0, 80);
  
  
  g0CodeString = "G0" + " X" + str(stepsTotalFlow) + ";";
  g1CodeString = "G1"+" S"+str(stepsPerSecFlowRate)+" X"+str(stepsTotalFlow)+";";
  text("GCODE PREVIEW :\n" + "Press Right: " + g0CodeString + "\n" + "Press Left: " + g1CodeString, 0, 100);
  popMatrix();
}
void controlEvent(ControlEvent theEvent) {
  if(theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
            +theEvent.getName()+"': "
            +theEvent.getStringValue()
            );
  }
}

void keyPressed() {
  if (key == CODED) 
  {
    if (keyCode == UP) 
    {
      // send Gcode position up 1
      println("manualMode : send gcode position up 1");
      myPort.write("G01 X+"+stepsPerRevolution+";");
      //update position here
    } 
    else if (keyCode == DOWN) 
    {
      // send Gcode position down 1
      println("manualMode : send gcode position down 1");
      println("G01 X-"+stepsPerRevolution+";");
      myPort.write("G01 X-"+stepsPerRevolution+";");
      //update position here
    } 
    else if (keyCode == LEFT) 
    {
      println("hippoMode");
      println(g1CodeString);
      myPort.write(g1CodeString);
      //update position here
    } 
    else if (keyCode == RIGHT) 
    {
      println("chickDuckMode");
      println(g0CodeString);
      myPort.write(g0CodeString);
      //update position here
    }  
  }
  else
  {
    if(key == 'd')
    {
      direction = !direction;
    }
    else if (key == 's')
    {
    //println("set speed");
    myPort.write("G00 S"+percentMotorSpeed+";");
    }
  }
    
}


