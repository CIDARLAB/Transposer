import org.gicentre.utils.stat.*;
import processing.serial.*;
import controlP5.*;

ControlP5 cp5;
Serial myPort; 

float pHmin, pHmax, pHmeasured;
int s1, s2; // syringe fill values
int v1, v2; // volume dispensed values
float loopDelay; // in seconds
Pump p1, p2;
boolean PUSH = true;

int count = 0; //restarts bar graph when start button is pressed
int num = 30; // number of bars in bar graph 
float[] pHdata = new float[num];
BarChart barChart;

void setup() {
  size(800,500);
  
  myPort = new Serial(this, Serial.list()[7], 9600); // Open the port you are using at the rate you want:
  
  PFont font = createFont("AndaleMono-48.vlw",12, true);
  textFont(font);
  ControlFont cfont = new ControlFont(font,241);
  
  p1 = new Pump(myPort, 1); // pH up solution
  p2 = new Pump(myPort, 2); // pH down solution
  pHmeasured = 7.0;
    
  cp5 = new ControlP5(this);
  cp5.setColorForeground(0xffaaaaaa)
     .setColorBackground(0xffffffff)
     .setColorValue(0xff00ff00)
     ;
     
  cp5.getTab("default")
     .setLabel(" Experiment ")
     .setColorLabel(0xff000000)
     .setColorActive(0xffaaaaaa)
     .setWidth(width/2)
     ;  
     
  cp5.addTab("settings")
     .setLabel(" Pump Settings ")
     .setColorLabel(0xff000000)
     .setColorActive(0xffaaaaaa)
     .setWidth(width/2)
     .activateEvent(true)
     ;
 
  cp5.addTextfield("pHmin")
     .setPosition(100,40)
     .setSize(50,25)
     .setFont(font)
     .setColor(color(50,50,50))
     .setColorCursor(color(0,0,0))
     .setText("6.534")
     .setLabel("Min")
     ;  
  cp5.addTextfield("pHmax")
     .setPosition(200,40)
     .setSize(50,25)
     .setFont(font)
     .setColor(color(50,50,50))
     .setColorCursor(color(0,0,0))
     .setText("7.512")
     .setLabel("Max")
     ;    
  
  cp5.addTextfield("LoopDelay")
     .setPosition(400,40)
     .setSize(40,25)
     .setFont(font)
     .setColor(color(50,50,50))
     .setColorCursor(color(0,0,0))
     .setText("1")
     .setLabel("Delay (sec)")
     ;    
  
  drawSyringe("Syringe1", color(0,0,255), 100, 100);    // pH-up
  drawSyringe("Syringe2", color(255,0,0), 100, 150);    // pH-down
  drawSettings("Syringe1", "settings", 100, 50);
  drawSettings("Syringe2", "settings", 100, 160);
 
  cp5.addButton("run")
     .setPosition(720,250)
     .setSize(40,20)
     .setLabel(" START")
     .setColorBackground(0xff00ff00 + 0x88000000)
     .setColorForeground(0xff00ff00)
     .setOff()
     ;
      
  barChart = new BarChart(this); 
  barChart.setValueAxisLabel("Measured pH \n");
  barChart.showValueAxis(true);
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
 
  pHmin = float(cp5.get(Textfield.class,"pHmin").getText().trim());   
  pHmax = float(cp5.get(Textfield.class,"pHmax").getText().trim());   
  loopDelay = float(cp5.get(Textfield.class,"LoopDelay").getText().trim());
  v1 = int(cp5.get(Textfield.class,"Syringe1Dispense").getText().trim());  
  v2 = int(cp5.get(Textfield.class,"Syringe2Dispense").getText().trim());   
  text("Target pH", 20, 60); 
  text("Reaction time", 300, 60); 
  text("pH Up", 20, 120);
  text("pH Down", 20, 170); 
    
  if (cp5.get(Button.class,"run").isOn()) {
    cp5.get(Button.class,"run").setLabel("  STOP")
       .setColorBackground(0xffff0000 + 0x88000000)
       .setColorForeground(0xffff0000);
    cp5.get(Slider.class,"Syringe1").lock();
    cp5.get(Slider.class,"Syringe2").lock();
    cp5.get(Textfield.class,"Syringe1Fill").lock();
    cp5.get(Textfield.class,"Syringe2Fill").lock();
    cp5.getTab("settings").hide();
    if (frameCount % 60 == 0) updatepH(); // 1 sec required between sensor readings
    if (frameCount % (60 * loopDelay) == 0) runLogic();
    text("Measured pH: "+ pHmeasured, 20, 240);  
    text("Experiment in Progress!", 575, 265);    
    if (count > 0) {  
      barChart.draw(20, height-240, width-40 , 200);
    }
  }
  else {
    cp5.get(Button.class,"run").setLabel(" START")
       .setColorBackground(0xff00ff00 + 0x88000000)
       .setColorForeground(0xff00ff00);
    count = 0;
    pHdata = new float[num];
    sliderInteraction(); 
    cp5.getTab("settings").show();
  };
}

void runLogic() {
  if (pHmeasured < pHmin) {
    if (s1 >= v1) {
      p1.dispense(v1, PUSH);
      s1 -= v1;           
      cp5.get(Slider.class,"Syringe1").setValue(s1);
      cp5.get(Textfield.class,"Syringe1Fill").setText(str(s1));
    }
    else {
      textSize(20);
      fill(#F57676);
      text("Insufficient PH up solution, experiment stopped", 150, 220);
      textSize(12);
      fill(50);
      noLoop();
    };
  }
  if (pHmeasured > pHmax) {
    if (s2 >= v2) {
      p2.dispense(v2, PUSH);
      s2 -= v2;           
      cp5.get(Slider.class,"Syringe2").setValue(s2);
      cp5.get(Textfield.class,"Syringe2Fill").setText(str(s2));
    }
    else {
      textSize(20);
      fill(#F57676);
      text("Insufficient PH down solution, experiment stopped", 150, 220);
      textSize(12);
      fill(50);
      noLoop();
    };
  }  
}

void updatepH() {
  String val = "";
  myPort.write("R;");
  if (myPort.available() > 0) {  // If data is available, 
    val = myPort.readStringUntil('\n');         // read it and store it in val 
    pHmeasured = float(val.trim()); 
  }
  else pHmeasured = random(pHmin-1,pHmax+1);
  count++;
  if (count <= num) {
    pHdata[count-1] = pHmeasured;
  }
  else {
    for (int i=0; i < num - 1; i++) {
      pHdata[i] = pHdata[i+1];
    }
    pHdata[num - 1] = pHmeasured;
  };
  barChart.setData(pHdata);
}

void sliderInteraction() {
    cp5.get(Slider.class,"Syringe1").unlock();
    cp5.get(Slider.class,"Syringe2").unlock();
    cp5.get(Textfield.class,"Syringe1Fill").unlock();
    cp5.get(Textfield.class,"Syringe2Fill").unlock();
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
}  
 
void guiSettings() {
  fill(#0000ff + 0x88000000);
  rect(20, 40, width-40, 100, 10);
  fill(#ff0000 + 0x88000000);
  rect(20, 150, width-40, 100, 10);
  fill(50);
  text("pH Down", 25, 60);
  text("pH Up", 25, 170);
} 


void controlEvent(ControlEvent theControlEvent) {
  if (theControlEvent.isTab()) {
    cp5.get(Button.class, "Syringe1Update").setLabel("SET VALUES");
    pumpGetValues(p1, "Syringe1");
    pumpGetValues(p2, "Syringe2");
  }
}

void Syringe1Update() {
  pumpSetValues(p1,"Syringe1");
  cp5.get(Button.class, "Syringe1Update").setLabel("SAVED!");
}

void Syringe2Update() {
  pumpSetValues(p2,"Syringe2");
  cp5.get(Button.class, "Syringe2Update").setLabel("SAVED!");
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
  PFont font = createFont("AndaleMono-48.vlw", 12, true);

  cp5.addTextfield(name + "Dispense")
     .setPosition(x, y)
     .setSize(50, 25)
     .setFont(font)
     .setColor(color(50,50,50))
     .setColorCursor(color(0,0,0))
     .setText("50")
     .setLabel("Dispense Volume (uL)")
     ;   
     
  cp5.addTextfield(name + "Fill")
     .setPosition(x + 100, y)
     .setSize(50,25)
     .setFont(font)
     .setColor(color(50,50,50))
     .setColorCursor(color(0,0,0))
     .setText("2500")
     .setLabel("Fill Level (uL)")
     ;
  cp5.addSlider(name)
     .setPosition(x + 151, y)
     .setSize(500,25)
     .setRange(0,10000)
     .setLabelVisible(false)
     .setValue(2500)
     .setColorForeground(c + 0x88000000)
     .setColorActive(c)
     ;
} 

void drawSettings(String name, String tabName, int x, int y) {  
  PFont font = createFont("AndaleMono-48.vlw",12, true);  
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

