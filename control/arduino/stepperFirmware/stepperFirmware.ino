#include <AccelStepper.h>

//
int maxMotorSpeed = 1500;                     //speed motor will accellerate to (steps/sec)
int motorAccel = 2000;                    //steps/second/secoand to accelerate
int motorDirPin = 2;                      //digital pin 2
int motorStepPin = 3;                     //digital pin 3

// checkSerial() Variables
int sofar;                                // Number of bytes in serial buffer
#define MAX_BUF (64)                      // Maximum number of bytes to store in serial buffer
char buffer[MAX_BUF];                     // Creates serial buffer

// processCommand() Variables
int posTemp = 0;
int speedTemp = 0;

//set up the accelStepper intance
//the "1" tells it we are using a driver
AccelStepper stepper(1, motorStepPin, motorDirPin); 

void setup()
{  
    stepper.setMaxSpeed(maxMotorSpeed);
    stepper.setAcceleration(2000);
    Serial.begin(9600);
}

void loop()
{
    // Check serial port for inputs when motor has finished moving
    if (stepper.distanceToGo() == 0)
        checkSerial();
    stepper.run();
}

void checkSerial()
{
  // listen for commands
  while(Serial.available() > 0) {           // if something is available
    char c=Serial.read();                   // get it
    Serial.print(c);                        // repeat it back so I know you got the message
    if(sofar<MAX_BUF) buffer[sofar++]=c;    // store it
    if(buffer[sofar-1]==';') break;         // checks for command termination using ';'
  }

  if(sofar>0 && buffer[sofar-1]==';') {
                                            // we got a message and it ends with a semicolon
    buffer[sofar]=0;                        // set the end of the buffer to zero for string function compatibility
    Serial.print(F("\r\n"));                // echo a return character and new line for human-readability
    processCommand();                       // do something with the command
    ready();
  }
}

void processCommand() 
{
  // look for commands that start with 'G'
  int cmd=parsenumber('G');
  switch(cmd) {
  case  0: // move in a line
    posTemp = parsenumber('X');
    stepper.setMaxSpeed(maxMotorSpeed);
    stepper.moveTo(posTemp);
    break;
  case  1: // move in a line 
    speedTemp = parsenumber('S');
    posTemp = parsenumber('X');
    stepper.setMaxSpeed(speedTemp);
    stepper.moveTo(posTemp);
    break;
  default:  
    break;
  }
  // if the string has no G or M commands it will get here and the Arduino will silently ignore it
}

int parsenumber(char c)
{
  String tempCharString = "";

  for(int i = 0; i<MAX_BUF; i++)
  {
    if(buffer[i] == c)
    {
      while(buffer[i] != ' ')
      {
        i++;
        tempCharString += buffer[i];
      }
        return tempCharString.toInt();
        
    }
  }
  return 0;
}

void ready() {
  sofar=0;                  
  // resets buffer pointer, essentially clearing buffer because strings of characters are terminated by a zero byte
}
