// sketch that receives a kinect v1 (1414) input via USB and transmits it as either Spout or Syphon ouput
// based on Shiffmans basic example from:
// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import codeanticode.syphon.*;
import spout.*;

int os = 0; // 0 = Mac OS X, 1 = Windows

Kinect kinect;

SyphonServer server;
Spout spout;

PGraphics c;

float deg;

boolean ir = false;
boolean colorDepth = false;
boolean mirror = false;

void setup() {
  if (!System.getProperty("os.name").equals("Mac OS X")) os = 1;

  size(640, 550, P3D);
  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.initVideo();
  kinect.enableIR(ir);
  kinect.enableColorDepth(colorDepth);
  deg = kinect.getTilt();
  // kinect.tilt(deg);
  c = createGraphics(width, height, P3D);

  switch (os) {
  case 0: 
    PJOGL.profile = 1;
    server = new SyphonServer(this, "kinect_syphon");
    break;
  case 1:
    spout = new Spout(this);
    spout.createSender("kinect_spout");
    break;
  }
}


void draw() {
  background(0);
  c.beginDraw();
  //c.rotate(PI);
  c.image(kinect.getVideoImage(), 0, 0);
  fill(255);
  c.endDraw();
  image(c, 0, 0);
  text("Framerate: " + int(frameRate), 10, 15);
  text("Press 'i' to enable/disable between video image and IR image,  ", 10, 495);
  text("Press 'c' to enable/disable between color depth and gray scale depth", 10, 510);
  text("Press 'm' to enable/diable mirror mode", 10, 525);
  text("Press UP and DOWN to tilt camera ", 10, 540);

  switch (os) {
  case 0: 
    server.sendImage(c);
    break;
  case 1:
    spout.sendTexture(c);
    break;
  }
}

void keyPressed() {
  if (key == 'i') {
    ir = !ir;
    kinect.enableIR(ir);
  } else if (key == 'c') {
    colorDepth = !colorDepth;
    kinect.enableColorDepth(colorDepth);
  } else if (key == 'm') {
    mirror = !mirror;
    kinect.enableMirror(mirror);
  } else if (key == CODED) {
    if (keyCode == UP) {
      deg++;
    } else if (keyCode == DOWN) {
      deg--;
    }
    deg = constrain(deg, 0, 30);
    kinect.setTilt(deg);
  }
}
