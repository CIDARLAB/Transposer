import processing.serial.*;

public class Pump {
    // Hardware 
    double syringeInnerD = 14.74; // mm
    double syringeMaxCap = 10000; // uL
    double pitch = 2.11667; // mm/rev
    double stepAngle = 1.8; // deg/step
    int uStepsPerStep = 8; // uSteps/step
    int motorMaxSpeed = 1500; // uSteps/s
    // Flow Profile
    double flowAcc = 0; // uL/s/s
    double flowSpeed = 300; // uL/s    
    //Port
    Serial port;
    int pumpID;
    // Calculated Values - update when hardware parameters are updated
    double ulPerUStep; // ul/ustep
    double flowMaxSpeed; // ul/s

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
    
    public void setHardware(double syringeInnerD, double syringeMaxCap, double pitch, double stepAngle, int uStepsPerStep, int motorMaxSpeed) { 
        this.syringeInnerD = syringeInnerD;
        this.syringeMaxCap = syringeMaxCap;
        this.pitch = pitch;
        this.stepAngle = stepAngle;
        this.uStepsPerStep = uStepsPerStep;
        this.motorMaxSpeed = motorMaxSpeed;
        updateSettings();
    }
    
    public void setFlowProfile(double acc, double speed) {
        this.flowAcc = acc;
        this.flowSpeed = speed < flowMaxSpeed ? speed : flowMaxSpeed; // Can't set the speed to higher than the motorMaxSpeed
    }
    
    public void dispense(double volume, boolean dir) {
        String CodeString;
        int uStepsAcc = (int)(flowAcc / ulPerUStep); // uL/s/s * uSteps/uL
        int uStepsSpeed = (int)(flowSpeed / ulPerUStep); // uL/s * uSteps/uL
        int uStepsMove = (int)(volume / ulPerUStep); // uL * uSteps/uL
        CodeString = "A P" + str(pumpID) + " D" + str(uStepsAcc) +";";
        port.write(CodeString);
        CodeString = "S P" + str(pumpID) + " D" + str(uStepsSpeed) +";";
        port.write(CodeString);        
        if (dir) CodeString = "F P" + str(pumpID) + " D" + str(uStepsMove) +";";
        else CodeString = "B P" + str(pumpID) + " D" + str(uStepsMove) +";";
        port.write(CodeString);
    }    
}
