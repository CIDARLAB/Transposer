#include <AccelStepper.h>

float maxMotorSpeed = 1500;                 //speed motor will accellerate to (steps/sec)
float motorAccel = 2000;                    //steps/second/secoand to accelerate
int motor2DirPin = 2;                      //digital pin 2
int motor2StepPin = 3;                     //digital pin 3
int motor3DirPin = 4;
int motor3StepPin = 5;
int motor1DirPin = 6;
int motor1StepPin = 7;
long motorPos[3] = {0, 0, 0};
long motorPos_temp[3] = {0, 0, 0};
boolean reading = true;
String sensorstring = ""; 
char readstring[ ] = "R\r";

// checkSerial() Variables
int sofar=0;                                // Number of bytes in serial buffer
int sofarSensor=0;
#define MAX_BUF (64)                      // Maximum number of bytes to store in serial buffer
char buffer[MAX_BUF];                     // Creates serial buffer
char bufferSensor[MAX_BUF];

// processCommand() Variables
long posTemp[3] = {0, 0, 0};
int speedTemp = 0;
int pumpNum = 5;
int accelTemp = 0;

//set up the accelStepper intance
//the "1" tells it we are using a driver
AccelStepper stepper[3] = {
  AccelStepper(1, motor1StepPin, motor1DirPin),
  AccelStepper(1, motor2StepPin, motor2DirPin),
  AccelStepper(1, motor3StepPin, motor3DirPin)
};

void setup()
{  
    stepper[0].setMaxSpeed(3000);
    stepper[0].setAcceleration(1000);

    stepper[1].setMaxSpeed(3000);
    stepper[1].setAcceleration(1000);

    stepper[2].setMaxSpeed(3000);
    stepper[2].setAcceleration(1000);
    Serial.begin(9600);
    Serial3.begin(9600);
    Serial3.print(readstring); //clear the buffer
}


void loop()
{
    // Check serial port for inputs when any motor has finished moving
    for (int i = 0; i < 3; i++){
      if (stepper[i].distanceToGo() == 0){
        motorPos[i] = motorPos_temp[i];
        stepper[i].moveTo(motorPos[i]);      
      }
    }
    checkSerial();
    //Serial.println(stepper[0].distanceToGo());
    //Serial.println(motorPos[0]);
    stepper[0].run();
    stepper[1].run();
    stepper[2].run();
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

void checkSerial3()
{
  // listen for sensor data
  while(Serial3.available() > 0) {           // if something is available
    char c=Serial3.read();                   // get it
    Serial.print(c);                         // print to Processing sketch
    if(sofarSensor<MAX_BUF) 
      bufferSensor[sofarSensor++]=c;         // store it
    if(bufferSensor[sofarSensor-1]=='\r') 
      break;				     // checks for command termination using ';'
  }

  if(sofarSensor>0 && bufferSensor[sofarSensor-1]=='\r') {
    // we got data and it ends with a carriage return
    bufferSensor[sofarSensor]=0;             // set the end of the buffer to zero for string function compatibility
    Serial.print(F("\n"));                   // echo line feed so processing knows the data is complete
    readySensor();
  }
}

void processCommand() 
{

  // look for command
  int cmd=buffer[0];
  switch(cmd) {
  case  'V': // set velocity
    pumpNum = parsenumber('P');            //retrieve 1-indexed pump number
    speedTemp = parsenumber('D');          //retrieve speed value
    stepper[pumpNum-1].setMaxSpeed(speedTemp);   //set speed value to 0-indexed motor
    break;
  case  'B': // pull in fluid "backwards"
    pumpNum = parsenumber('P');            //retrieve 1-indexed pump number      
    posTemp[pumpNum-1] = parsenumber('D');            //retrieve number of steps to move
    motorPos_temp[pumpNum-1] += posTemp[pumpNum-1];               //move posTemp number of steps
    break;
  case  'F': // push fluid "Forwards"
    pumpNum = parsenumber('P');            //retrieve 1-indexed pump number      
    posTemp[pumpNum-1] = parsenumber('D');            //retrieve number of steps to move
    motorPos_temp[pumpNum-1] -= posTemp[pumpNum-1];      //move posTemp number of steps
    break;
  case  'A': // set acceleration
    pumpNum = parsenumber('P');            //retrieve 1-indexed pump number
    accelTemp = parsenumber('D');          //retrieve speed value
    stepper[pumpNum-1].setAcceleration(accelTemp);   //set acceleration value to 0-indexed motor
  case  'R': //read from sensor
    Serial3.print(readstring);
    checkSerial3();
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

void readySensor() {
  sofarSensor=0;                  
  // resets buffer pointer, essentially clearing buffer because strings of characters are terminated by a zero byte
}

