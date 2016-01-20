#include <AccelStepper.h>
#include <Wire.h>
#include <Adafruit_MotorShield.h>
#include "utility/Adafruit_PWMServoDriver.h"

#define numStepMotors (6)
#define numDCMotors (3)

//https://forums.adafruit.com/viewtopic.php?f=31&t=41144
Adafruit_DCMotor*  InputArray[4];

float maxMotorSpeed = 3000;                 //speed motor will accellerate to (steps/sec)
float motorAccel = 1000;                    //steps/second/secoand to accelerate
int motor0DirPin = 2;                      //digital pin 2
int motor0StepPin = 3;                     //digital pin 3
int motor1DirPin = 4;
int motor1StepPin = 5;
int motor2DirPin = 6;
int motor2StepPin = 7;
int motor3DirPin = 8;
int motor3StepPin = 9;
int motor4DirPin = 10;
int motor4StepPin = 11;
int motor5DirPin = 12;
int motor5StepPin = 13;
long motorPos[numStepMotors] = {0, 0, 0, 0, 0, 0};
long motorPos_temp[numStepMotors] = {0, 0, 0, 0, 0, 0};

// checkSerial() Variables
int sofar=0;                                // Number of bytes in serial buffer
#define MAX_BUF (64)                      // Maximum number of bytes to store in serial buffer
char buffer[MAX_BUF];                     // Creates serial buffer

// processCommand() Variables
long posTemp[numStepMotors] = {0, 0, 0, 0, 0, 0};
int speedTemp = 0;
int pumpNum = 5;
int pumpNumFlow = 5;
int accelTemp = 0;
int pwmSpeedTemp = 0;

//set up the accelStepper intance
//the "1" tells it we are using a driver
AccelStepper stepper[6] = {
  AccelStepper(1, motor0StepPin, motor0DirPin),
  AccelStepper(1, motor1StepPin, motor1DirPin),
  AccelStepper(1, motor2StepPin, motor2DirPin),
  AccelStepper(1, motor3StepPin, motor3DirPin),
  AccelStepper(1, motor4StepPin, motor4DirPin),
  AccelStepper(1, motor5StepPin, motor5DirPin)
};

// Create the motor shield object with the default I2C address
Adafruit_MotorShield AFMS = Adafruit_MotorShield(); 

// Select which 'port' M1, M2, M3 or M4. In this case, M1
//If you stack motor shields, add more motors here
Adafruit_DCMotor *Input0 = AFMS.getMotor(1);
Adafruit_DCMotor *Input1 = AFMS.getMotor(2);
Adafruit_DCMotor *Input2 = AFMS.getMotor(3);
Adafruit_DCMotor *Input3 = AFMS.getMotor(4);

void setup()
{
   for (int i=0; i < numStepMotors; i++){  
    stepper[i].setMaxSpeed(maxMotorSpeed);
    stepper[i].setAcceleration(motorAccel);
   }
   AFMS.begin();
   
   //https://forums.adafruit.com/viewtopic.php?f=31&t=41144
   //If you stack motor shields, add more motors here
   InputArray[0] = Input0;
   InputArray[1] = Input1;
   InputArray[2] = Input2;
   InputArray[3] = Input3;

   Serial.begin(9600);
}


void loop()
{
    // Check serial port for inputs when any motor has finished moving
    for (int i = 0; i < numStepMotors; i++){
      if (stepper[i].distanceToGo() == 0){
        motorPos[i] = motorPos_temp[i];
        stepper[i].moveTo(motorPos[i]);      
      }
    }
    checkSerial();
    //Serial.println(stepper[0].distanceToGo());
    //Serial.println(motorPos[0]);
    for (int i=0; i < numStepMotors; i++){  
      stepper[i].run();
    }
}

void checkSerial()
{
  // listen for commands
  while(Serial.available() > 0) {           // if something is available
    char c=Serial.read();                   // get it
    //Serial.print(c);                        // repeat it back so I know you got the message
    if(sofar<MAX_BUF) 
      buffer[sofar++]=c;		    // store it
    if(buffer[sofar-1]==';') 
      break;				    // checks for command termination using ';'
  }

  if(sofar>0 && buffer[sofar-1]==';') {
    // we got a message and it ends with a semicolon
    buffer[sofar]=0;                        // set the end of the buffer to zero for string function compatibility
    //Serial.print(F("\r\n"));                // echo a return character and new line for human-readability
    processCommand();                       // do something with the command
    ready();
  }
}

void processCommand() 
{

  // look for command
  int cmd=buffer[0];
  switch(cmd) {
  case  'V': // set velocity
    pumpNum = parsenumber('P');            //retrieve 0-indexed pump number
    speedTemp = parsenumber('D');          //retrieve speed value
    stepper[pumpNum].setMaxSpeed(speedTemp);   //set speed value to 0-indexed motor
    break;
  case  'B': // pull in fluid "backwards"
    pumpNum = parsenumber('P');            //retrieve 0-indexed pump number      
    posTemp[pumpNum] = parsenumber('D');            //retrieve number of steps to move
    motorPos_temp[pumpNum] += posTemp[pumpNum];               //move posTemp number of steps
    break;
  case  'F': // push fluid "Forwards"
    pumpNum = parsenumber('P');            //retrieve 0-indexed pump number      
    posTemp[pumpNum] = parsenumber('D');            //retrieve number of steps to move
    motorPos_temp[pumpNum] -= posTemp[pumpNum];      //move posTemp number of steps
    break;
  case  'A': // set acceleration
    pumpNum = parsenumber('P');            //retrieve 0-indexed pump number
    accelTemp = parsenumber('D');          //retrieve speed value
    stepper[pumpNum].setAcceleration(accelTemp);   //set acceleration value to 0-indexed motor
    break;
  case  'E': // Turn on output 
    pumpNumFlow = parsenumber('M');            //retrieve 0-indexed input pump number
    pwmSpeedTemp = parsenumber('D');          //retrieve speed value
    InputArray[pumpNumFlow]->setSpeed(pwmSpeedTemp);   //set motor speed value to 0-indexed motor
    InputArray[pumpNumFlow]->run(FORWARD);   //run motor 
    break;
  default:  
    break;
  }
  // if the string has no valid commands the Arduino will silently ignore it
}

long parsenumber(char c)
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
