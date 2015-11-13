import processing.serial.*;

public class Pump {
    // Hardware 
    float syringeInnerD = 14.74; // mm
    int syringeMaxCap = 10000; // uL
    float pitch = 0.8; // mm/rev
    float stepAngle = 1.8; // deg/step
    int uStepsPerStep = 8; // uSteps/step
    int motorMaxSpeed = 1500; // uSteps/s
    // Flow Profile
    float flowAcc = 2000; // uL/s/s
    float flowSpeed = 300; // uL/s    
    //Port
    Serial port;
    int pumpID;
    // Calculated Values - update when hardware parameters are updated
    float ulPerUStep; // ul/ustep
    float flowMaxSpeed; // ul/s

    public Pump(Serial port, int pumpID) {
        this.port = port;
        this.pumpID = pumpID;
        updateSettings();
    }
    
    private void updateSettings() {      
        // Calculated Values - update when hardware parameters are updated
        ulPerUStep = syringeInnerD * syringeInnerD * 3.14159 / 4 * pitch / (360 * uStepsPerStep / stepAngle); // mm^3 /(deg * usteps/step * steps/deg)
        flowMaxSpeed = motorMaxSpeed * ulPerUStep; // uSteps/s * uL/uSteps
    }
    
    public float getSyringeID() { return syringeInnerD; }
    public int getSyringeMaxCap() { return syringeMaxCap; }
    public float getPitch() { return pitch; }
    public float getStepAngle() {return stepAngle; }
    public int getMicrostepsPerStep() {return uStepsPerStep; }
    public int getMotorMaxSpeed() { return motorMaxSpeed; }
    public float getFlowAcc() { return flowAcc; }
    public float getFlowSpeed() { return flowSpeed; }
    
    public void setHardware(float syringeInnerD, int syringeMaxCap, float pitch, float stepAngle, int uStepsPerStep, int motorMaxSpeed) { 
        this.syringeInnerD = syringeInnerD > 0 ? syringeInnerD : this.syringeInnerD; // Only update if input is a positive number
        this.syringeMaxCap = syringeMaxCap > 0 ? syringeMaxCap : this.syringeMaxCap;
        this.pitch = pitch > 0 ? pitch : this.pitch;
        this.stepAngle = stepAngle > 0 ? stepAngle : this.stepAngle;
        this.uStepsPerStep = uStepsPerStep > 0 ? uStepsPerStep : this.uStepsPerStep;
        this.motorMaxSpeed = motorMaxSpeed > 0 ? motorMaxSpeed : this.motorMaxSpeed;
        updateSettings();
    }
    
    public void setFlowProfile(float acc, float speed) {
        this.flowAcc = acc > 0 ? acc : this.flowAcc;
        this.flowSpeed = (speed > 0 && speed < flowMaxSpeed) ? speed : flowMaxSpeed; // Can't set the speed to higher than the motorMaxSpeed
    }
    
    public void dispense(float volume, boolean dir) {
        String CodeString;
        int uStepsAcc = (int)(flowAcc / ulPerUStep); // uL/s/s * uSteps/uL
        int uStepsSpeed = (int)(flowSpeed / ulPerUStep); // uL/s * uSteps/uL
        int uStepsMove = (int)(volume / ulPerUStep); // uL * uSteps/uL
        CodeString = "A P" + str(pumpID) + " D" + str(uStepsAcc) +";";
        port.write(CodeString);
	println(CodeString);
        CodeString = "V P" + str(pumpID) + " D" + str(uStepsSpeed) +";";
        port.write(CodeString);        
	println(CodeString);
        if (dir) CodeString = "F P" + str(pumpID) + " D" + str(uStepsMove) +";";
        else CodeString = "B P" + str(pumpID) + " D" + str(uStepsMove) +";";
        port.write(CodeString);
	println(CodeString);
    }
    
    public void printValues() {
        println("Syringe Inner Diameter:", syringeInnerD, "mm");
        println("Syringe Max Capacity:", syringeMaxCap, "uL");
        println("Pitch:", pitch, "mm/rev");
        println("Step Angle:", stepAngle, "deg/step");
        println("Microsteps Per Step:", uStepsPerStep, "uSteps/step");
        println("Motor Max Speed:", motorMaxSpeed, "uSteps/s");
        println("Flow Acceleration:", flowAcc, "uL/s/s");
        println("Flow Speed:", flowSpeed, "uL/s ");   
        println("Microliters Per Microstep:", ulPerUStep, "ul/ustep");
        println("Flow Max Speed:", flowMaxSpeed, "ul/s");
    }     
}
