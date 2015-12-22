import processing.serial.*;

public class PumpFlow {
	int motorPort;	//M1, M2, M3, M4 from adafruit motor shield
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
        if (dir) CodeString = "F P" + str(pumpID) + " D" + str(uStepsMove) +";";
        else CodeString = "B P" + str(pumpID) + " D" + str(uStepsMove) +";";
        port.write(CodeString);
	println(CodeString);
    }
}
