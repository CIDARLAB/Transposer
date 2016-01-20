import processing.serial.*;

public class PumpFlow {
	int motorPort;	//0 for M1, 1 for M2, 2 for M3, 3 for M4 from adafruit motor shield
	Serial port;

	public PumpFlow(Serial port, int motorPort) {
		this.port = port;
		this.motorPort = motorPort;
	}

	public void dispenseFlow(int pwmSpeed) {
	    String CodeString;
	    CodeString = "E M" + str(motorPort) + " D" + str(pwmSpeed) +";";
	    port.write(CodeString);
	    println(CodeString);
	}
 }

 public class Pump {
    //Port
    Serial port;
    int pumpID;

    public Pump(Serial port, int pumpID) {
        this.port = port;
        this.pumpID = pumpID;
    }
   
    public void dispense(int uStepsMove, boolean dir) {
        String CodeString;

	//--Comment out of dispense operations stop working
	CodeString = "A P" + str(pumpID) + " D" + str(uStepsAcc) +";";
        port.write(CodeString);
	println(CodeString);
        CodeString = "V P" + str(pumpID) + " D" + str(uStepsSpeed) +";";
        port.write(CodeString);
	println(CodeString);
	//--end section

        if (dir) CodeString = "F P" + str(pumpID) + " D" + str(uStepsMove) +";";
        else CodeString = "B P" + str(pumpID) + " D" + str(uStepsMove) +";";
        port.write(CodeString);
	println(CodeString);
    }
}
