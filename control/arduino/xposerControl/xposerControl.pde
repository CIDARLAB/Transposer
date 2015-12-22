import org.gicentre.utils.stat.*;
import processing.serial.*;
import controlP5.*;

ControlP5 cp5;
Serial myPort; 

int s1, s2, s3; // syringe fill values
int v1, v2, v3; // volume dispensed values
int volume2, volume3; // volume dispensed values
float loopDelay; // in seconds
Pump p1, p2, p3;
boolean PUSH = true;
boolean PULL = false;
boolean initControl = false;

PImage cross, straight;
PFont font;

void setup() {
  size(800,550);
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[7], 9600); // Open the port you are using at the rate you want:
  font = createFont("AndaleMono-48.vlw",12, true);
  textFont(font);
  ControlFont cfont = new ControlFont(font,241);
  
  p1 = new Pump(myPort, 1); // MIT Pump holding inputs 
  p2 = new Pump(myPort, 2); // xposer1 control outside
  p3 = new Pump(myPort, 3); // xposer1 control inside 
    
  cp5 = new ControlP5(this);
  cp5.setColorForeground(0xffaaaaaa)
     .setColorBackground(0xffffffff)
     .setColorValueLabel(0xff00ff00)
     ;
     
  cp5.getTab("default")
     .setLabel(" Controller ")
     .setColorLabel(0xff000000)
     .setColorActive(0xffaaaaaa)
     .setWidth(width/2)
     ;  
     
  cp5.addTab("settings")
     .setLabel(" Settings ")
     .setColorLabel(0xff000000)
     .setColorActive(0xffaaaaaa)
     .setWidth(width/2)
     .activateEvent(true)
     ;

  cp5.addTextfield("LoopDelay")
     .setPosition(100,40)
     .setSize(40,25)
     .setFont(font)
     .setColor(color(50,50,50))
     .setColorCursor(color(0,0,0))
     .setText("1")
     .setLabel("Delay (sec)")
     ;    
  
  drawSyringe("Syringe1", color(0,0,255), 100, 100);    // Liquid 
  drawSyringe("Syringe2", color(255,0,0), 100, 150);    // Control Inside
  drawSyringe("Syringe3", color(0,255,0), 100, 200);    // Control Outside
  drawSettings("Syringe1", "settings", 100, 70);
  drawSettings("Syringe2", "settings", 100, 210);
  drawSettings("Syringe3", "settings", 100, 350);

  cross = loadImage("cross.png");
  straight = loadImage("straight.png");
  cp5.addToggle("AB")
	  .setPosition(150,300)
	  .setSize(50,20)
	  .setImages(cross, straight)
	  .updateSize()
	  ;

  cp5.addButton("pressMe")
     .setPosition(676,300)
     .setSize(40,20)
     .setLabel(" Dispense ")
     .setColorBackground(0xff00ff00 + 0x88000000)
     .setColorForeground(0xff00ff00)
     .setOff()
     ;
}

void draw() {
  background(0xffaaaaaa);
  fill(245);
  noStroke();
  rect(0 , 20, width, height-40);
  if (cp5.getTab("default").isActive()) guiDefault();
  if (cp5.getTab("settings").isActive()) guiSettings();
}

void guiDefault() {  
  fill(50); 
  loopDelay = float(cp5.get(Textfield.class,"LoopDelay").getText().trim());
  v1 = int(cp5.get(Textfield.class,"Syringe1Dispense").getText().trim());  
  v2 = int(cp5.get(Textfield.class,"Syringe2Dispense").getText().trim());   
  v3 = int(cp5.get(Textfield.class,"Syringe3Dispense").getText().trim());   
  text("Interval", 20, 60); 
  text("Liquid", 20, 120);
  text("Control Inside", 20, 145, 75, 170); 
  text("Control Outside", 20, 195, 75, 220); 
  if (cp5.get(Button.class,"pressMe").isOn()) {
    if (frameCount % (60 * loopDelay) == 0) dispenseLiquid();
    text("Experiment in Progress!", 575, 250);    
  }
  else {
    sliderInteraction();
  };
}

void pressMe() {
  if (cp5.get(Button.class,"pressMe").isOn()) {
    cp5.get(Button.class,"pressMe").setLabel("  Locked")
       .setColorBackground(0xffff0000 + 0x88000000)
       .setColorForeground(0xffff0000);
    cp5.get(Slider.class,"Syringe1").lock();
    cp5.get(Slider.class,"Syringe2").lock();
    cp5.get(Slider.class,"Syringe3").lock();
    cp5.get(Textfield.class,"Syringe1Fill").lock();
    cp5.get(Textfield.class,"Syringe2Fill").lock();
    cp5.get(Textfield.class,"Syringe3Fill").lock();
    cp5.getTab("settings").hide();
  }
  else {
    cp5.get(Button.class,"pressMe").setLabel(" Initialize")
       .setColorBackground(0xff00ff00 + 0x88000000)
       .setColorForeground(0xff00ff00);
    cp5.get(Slider.class,"Syringe1").unlock();
    cp5.get(Slider.class,"Syringe2").unlock();
    cp5.get(Slider.class,"Syringe3").unlock();
    cp5.get(Textfield.class,"Syringe1Fill").unlock();
    cp5.get(Textfield.class,"Syringe2Fill").unlock();
    cp5.get(Textfield.class,"Syringe3Fill").unlock();
    cp5.getTab("settings").show();  
  }
}

void dispenseLiquid() {
  if (s1 >= v1) {
    p1.dispense(v1, PUSH);
    s1 -= v1;           
    cp5.get(Slider.class,"Syringe1").setValue(s1);
    cp5.get(Textfield.class,"Syringe1Fill").setText(str(s1));
  }
  else shutDown("Insufficient liquid to dispense, experiment stopped");
}


void shutDown(String message) {
  textSize(20);
  fill(#F57676);
  text(message, 50, 270);
  textSize(12);
  fill(50); 
  noLoop();
}

void sliderInteraction() {
  if (cp5.get(Textfield.class,"Syringe1Fill").isFocus()) {  
    s1 = int(cp5.get(Textfield.class,"Syringe1Fill").getText().trim());  
    cp5.get(Slider.class,"Syringe1").setValue(s1);
  }  
  else {
    s1 = int(cp5.get(Slider.class,"Syringe1").getValue());
    cp5.get(Textfield.class,"Syringe1Fill").setText(str(s1));
  };
  if (cp5.get(Textfield.class,"Syringe2Fill").isFocus()) {  
    s2 = int(cp5.get(Textfield.class,"Syringe2Fill").getText().trim());  
    cp5.get(Slider.class,"Syringe2").setValue(s2);
  }
  else {
    s2 = int(cp5.get(Slider.class,"Syringe2").getValue());
    cp5.get(Textfield.class,"Syringe2Fill").setText(str(s2));
  };
  if (cp5.get(Textfield.class,"Syringe3Fill").isFocus()) {  
    s3 = int(cp5.get(Textfield.class,"Syringe3Fill").getText().trim());  
    cp5.get(Slider.class,"Syringe3").setValue(s3);
  }
  else {
    s3 = int(cp5.get(Slider.class,"Syringe3").getValue());
    cp5.get(Textfield.class,"Syringe3Fill").setText(str(s3));
  };
}  
 
void guiSettings() {
  fill(#0000ff + 0x88000000);
  rect(20, 60, width-40, 105, 10);
  fill(#ff0000 + 0x88000000);
  rect(20, 200, width-40, 105, 10);
  fill(#00ff00 + 0x88000000);
  rect(20, 340, width-40, 105, 10);
  fill(50);
  text("Liquid Pump", 20, 54);
  text("Control Inside Pump", 20, 194);
  text("Control Outside Pump", 20, 334);
} 

//This will reset the buttons on the settings tab to SET VALUES every time you switch back to the settings tab
void controlEvent(ControlEvent theControlEvent) {
  if (theControlEvent.isTab()) {
    cp5.get(Button.class, "Syringe1Update").setLabel("SET VALUES");
    cp5.get(Button.class, "Syringe2Update").setLabel("SET VALUES");
    cp5.get(Button.class, "Syringe3Update").setLabel("SET VALUES");
    pumpGetValues(p1, "Syringe1");
    pumpGetValues(p2, "Syringe2");
    pumpGetValues(p3, "Syringe3");
  }
}

void Syringe1Update() {
  pumpSetValues(p1,"Syringe1");
  cp5.get(Slider.class,"Syringe1").setRange(0, p1.getSyringeMaxCap());
  cp5.get(Button.class, "Syringe1Update").setLabel("SAVED!");
}

void Syringe2Update() {
  pumpSetValues(p2,"Syringe2");  
  cp5.get(Slider.class,"Syringe2").setRange(0, p2.getSyringeMaxCap());
  cp5.get(Button.class, "Syringe2Update").setLabel("SAVED!");
}

void Syringe3Update() {
  pumpSetValues(p3,"Syringe3");  
  cp5.get(Slider.class,"Syringe3").setRange(0, p3.getSyringeMaxCap());
  cp5.get(Button.class, "Syringe3Update").setLabel("SAVED!");
}

void pumpGetValues(Pump p, String name) {  
    cp5.get(Textfield.class, name + "ID").setText(str(p.getSyringeID()));  
    cp5.get(Textfield.class, name + "MaxCap").setText(str(p.getSyringeMaxCap()/1000));  
    cp5.get(Textfield.class, name + "Pitch").setText(str(p.getPitch()));  
    cp5.get(Textfield.class, name + "StepAngle").setText(str(p.getStepAngle()));  
    cp5.get(Textfield.class, name + "MicrostepsPerStep").setText(str(p.getMicrostepsPerStep()));  
    cp5.get(Textfield.class, name + "MotorMaxSpeed").setText(str(p.getMotorMaxSpeed()));
    cp5.get(Textfield.class, name + "FlowAcc").setText(str(p.getFlowAcc()));  
    cp5.get(Textfield.class, name + "FlowSpeed").setText(str(p.getFlowSpeed()));
}

void pumpSetValues(Pump p, String name) {
  p.setHardware( float(cp5.get(Textfield.class, name + "ID").getText().trim()),  
                 int(cp5.get(Textfield.class, name + "MaxCap").getText().trim())*1000,  
                 float(cp5.get(Textfield.class, name + "Pitch").getText().trim()),  
                 float(cp5.get(Textfield.class, name + "StepAngle").getText().trim()),  
                 int(cp5.get(Textfield.class, name + "MicrostepsPerStep").getText().trim()),  
                 int(cp5.get(Textfield.class, name + "MotorMaxSpeed").getText().trim()) );
  p.setFlowProfile( float(cp5.get(Textfield.class, name + "FlowAcc").getText().trim()),  
                    float(cp5.get(Textfield.class, name + "FlowSpeed").getText().trim()) );
  p.printValues();
}
  
void drawSyringe(String name, color c, int x, int y) {
  cp5.addTextfield(name + "Dispense")
     .setPosition(x, y)
     .setSize(50,25)
     .setFont(font)
     .setColor(color(50,50,50))
     .setColorCursor(color(0,0,0))
     .setText("1000")
     .setLabel("Dispense Volume (uL)")
     ;   
     
  cp5.addTextfield(name + "Fill")
     .setPosition(x + 100, y)
     .setSize(50,25)
     .setFont(font)
     .setColor(color(50,50,50))
     .setColorCursor(color(0,0,0))
     .setText("5000")
     .setLabel("Fill Level (uL)")
     ;
  cp5.addSlider(name)
     .setPosition(x + 151, y)
     .setSize(500,25)
     .setRange(0,10000)
     .setLabelVisible(false)
     .setValue(5000)
     .setColorForeground(c + 0x88000000)
     .setColorActive(c)
     ;
} 

void drawSettings(String name, String tabName, int x, int y) {  
  cp5.addTextfield(name + "ID")
     .setPosition(x, y)
     .setSize(50, 25)
     .setFont(font)
     .setColor(color(50,50,50))
     .setColorCursor(color(0,0,0))
     .setLabel("Syringe Inner Diameter (mm)")
     .setTab(tabName)  
     ;  
  cp5.addTextfield(name + "MaxCap")
     .setPosition(x + 150, y)
     .setSize(50, 25)
     .setFont(font)
     .setColor(color(50,50,50))
     .setColorCursor(color(0,0,0))
     .setLabel("Syringe Capacity (ml)")
     .setTab(tabName)  
     ;  
  cp5.addTextfield(name + "FlowAcc")
     .setPosition(x + 300, y)
     .setSize(50, 25)
     .setFont(font)
     .setColor(color(50,50,50))
     .setColorCursor(color(0,0,0))
     .setLabel("Flow Acceleration (uL/s/s)")
     .setTab(tabName)  
     ;
  cp5.addTextfield(name + "FlowSpeed")
     .setPosition(x + 450, y)
     .setSize(50, 25)
     .setFont(font)
     .setColor(color(50,50,50))
     .setColorCursor(color(0,0,0))
     .setLabel("Flow Velocity (uL/s)")
     .setTab(tabName)  
     ;  

  cp5.addTextfield(name + "Pitch")
     .setPosition(x, y + 50)
     .setSize(75, 25)
     .setFont(font)
     .setColor(color(50,50,50))
     .setColorCursor(color(0,0,0))
     .setLabel("Pitch (mm/rev)")
     .setTab(tabName)  
     ;  
  cp5.addTextfield(name + "MotorMaxSpeed")
     .setPosition(x + 150, y + 50)
     .setSize(50, 25)
     .setFont(font)
     .setColor(color(50,50,50))
     .setColorCursor(color(0,0,0))
     .setLabel("Maximum Motor Speed (uSteps/s)")
     .setTab(tabName)  
     ; 
  cp5.addTextfield(name + "StepAngle")
     .setPosition(x + 300, y + 50)
     .setSize(50, 25)
     .setFont(font)
     .setColor(color(50,50,50))
     .setColorCursor(color(0,0,0))
     .setLabel("Step Angle (deg/step)")
     .setTab(tabName)  
     ;  
  cp5.addTextfield(name + "MicrostepsPerStep")
     .setPosition(x + 450, y + 50)
     .setSize(25, 25)
     .setFont(font)
     .setColor(color(50,50,50))
     .setColorCursor(color(0,0,0))
     .setLabel("Microsteps per Step")
     .setTab(tabName)  
     ;

  cp5.addButton(name + "Update")
     .setPosition(x+580,y+25)
     .setSize(60,20)
     .setLabel("SET VALUES")
     .setColorBackground(0xffdddddd)
     .setTab(tabName)
     ;
}

void AB(boolean ABFlag) {
  if (initControl == false) { 
    volume2 = v2;
    volume3 = v3;
    initControl = true;
  }
  else {
    volume2 = 2*v2;
    volume3 = 2*v3;
  }
  println("ABFlag = " + ABFlag);
  println("initControl = " + initControl);
  println("volume2  = " + volume2);
  println("volume3  = " + volume3);
  if (ABFlag == true) {
    if (s2 >= volume2) {
      p2.dispense(volume2, PUSH);
      s2 -= volume2;           
      cp5.get(Slider.class,"Syringe2").setValue(s2);
      cp5.get(Textfield.class,"Syringe2Fill").setText(str(s2));
    }
    else shutDown("Insufficient air in inside control syringe, experiment stopped");
    if (p3.getSyringeMaxCap()-s3 >= volume3) {
      p3.dispense(volume3, PULL);
      s3 += volume3;           
      cp5.get(Slider.class,"Syringe3").setValue(s3);
      cp5.get(Textfield.class,"Syringe3Fill").setText(str(s3));
    }
    else shutDown("Insufficient space to aspirate in outside control syringe, experiment stopped");
  }  
  else {
    if (p2.getSyringeMaxCap()-s2 >= volume2) {
      p2.dispense(volume2, PULL);
      s2 += volume2;           
      cp5.get(Slider.class,"Syringe2").setValue(s2);
      cp5.get(Textfield.class,"Syringe2Fill").setText(str(s2));
    }
    else shutDown("Insufficient air in inside control syringe, experiment stopped");
    if (s3 >= volume3) {
      p3.dispense(volume3, PUSH);
      s3 -= volume3;           
      cp5.get(Slider.class,"Syringe3").setValue(s3);
      cp5.get(Textfield.class,"Syringe3Fill").setText(str(s3));
    }
    else shutDown("Insufficient space to aspirate in outside control syringe, experiment stopped");
  }
}
