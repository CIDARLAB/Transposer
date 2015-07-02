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

void setup() {
  size(800,300);
  
  myPort = new Serial(this, Serial.list()[0], 9600); // Open the port you are using at the rate you want:
  
  PFont font = createFont("AndaleMono-48.vlw",12, true);
  textFont(font);
  ControlFont cfont = new ControlFont(font,241);
  
  p1 = new Pump(myPort, 1); // pH up solution
  p2 = new Pump(myPort, 2); // pH down solution
  pHmeasured = 7.0;
    
  cp5 = new ControlP5(this);
    // change the original colors
    cp5.setColorForeground(0xffaaaaaa);
    cp5.setColorBackground(0xffffffff);
    cp5.setColorLabel(0xff555555);
    cp5.setColorValue(0xff00ff00);
    cp5.setColorActive(0xff000000);
  
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
  
  draw_syringe("Syringe1", color(0,0,255), 100, 100);    // pH-up
  draw_syringe("Syringe2", color(255,0,0), 100, 150);    // pH-down
 
  cp5.addButton("run")
     .setPosition(720,250)
     .setSize(40,20)
     .setLabel(" START")
     .setColorBackground(0xff00ff00 + 0x88000000)
     .setColorForeground(0xff00ff00)
     .setOff();
     ;
}

void draw()
{
  background(245);
  guiUpdate();    
  if (cp5.get(Button.class,"run").isOn()) {
    if (frameCount % (60 * loopDelay) == 0) runlogic();
    if (frameCount % 60 == 0 && frameCount % (60 * loopDelay) != 0) updatepH(); // 1 sec required between sensor readings
  }
}

void guiUpdate() {  
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
    text("Measured pH: "+ pHmeasured, 20, 240);  
    text("Experiment in Progress!", 575, 265);
    cp5.get(Slider.class,"Syringe1").lock();
    cp5.get(Slider.class,"Syringe2").lock();
    cp5.get(Textfield.class,"Syringe1Fill").lock();
    cp5.get(Textfield.class,"Syringe2Fill").lock();
  }
  else {
    cp5.get(Button.class,"run").setLabel(" START")
       .setColorBackground(0xff00ff00 + 0x88000000)
       .setColorForeground(0xff00ff00);
    sliderInteraction(); 
  }
}

void runlogic() {    
  updatepH();
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
      noLoop();
    };
  }  
}

void updatepH() {
  String val = "";
  myPort.write("R;");
  if ( myPort.available() > 0) {  // If data is available, 
    val = myPort.readStringUntil('\n');         // read it and store it in val 
    pHmeasured = float(val.trim()); 
  }  
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
  
void draw_syringe(String name, color c, int x, int y) {  
  PFont font = createFont("AndaleMono-48.vlw",12, true);

  cp5.addTextfield(name + "Dispense")
     .setPosition(x, y)
     .setSize(50, 25)
     .setFont(font)
     .setColor(color(50,50,50))
     .setColorCursor(color(0,0,0))
     .setText("50")
     .setLabel("Dispense Volume (uL)")
     .setAutoClear(false).keepFocus(false);
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
