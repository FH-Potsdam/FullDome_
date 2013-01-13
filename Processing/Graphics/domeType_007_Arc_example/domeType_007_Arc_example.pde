import processing.opengl.*;

FisheyeTypoQuad[][] arcTypo = new FisheyeTypoQuad[5][5];
String[] lines;

static final int BILLBOARD_TYPE = 0;
static final int ARC_TYPE = 1;
float rMax, rMin;
float zMax, zMin;
float xSpacing = 128;
float z0 = 128;
float angularSpeed_0 = 0.05f;
float angularSpeed_1 = 0.3f;
float speedDifference = angularSpeed_1-angularSpeed_0;

void setup() {
  size(1024, 1024, OPENGL);
  zMin = 0;
  zMax = height;
  float zInc = (zMax-zMin)/float(arcTypo.length);
  rMin = height/2f;
  rMax = height*2f;
  float rInc = (rMax-rMin)/float(arcTypo[0].length);
  lines = loadStrings("kafka_blindtext.txt");
  for (int i = 0; i < arcTypo.length; i++) {
    for (int j = 0; j < arcTypo[0].length; j++) {
      int line_number = (i*arcTypo[0].length+j)%lines.length;
      arcTypo[i][j] = new FisheyeTypoQuad(this, ARC_TYPE, lines[line_number], loadFont("Georgia-Bold-48.vlw"), 48f, color(255), zMin + zInc*i, rMin + rInc*j, HALF_PI);
      //the following line causes the texture background to be opaque!
      //arcTypo[i][j].setZIndex(arcTypo.length-i);
    }
  }
}

void draw() {
  background(0,0,0);
  stroke(255);
  //we need to iterate this way, because the z-index is not working!
  for (int i =  arcTypo.length-1; i >= 0; i--) {
    for (int j = arcTypo[0].length-1; j >= 0; j--) {
      tint(192*(1-j/float(arcTypo[0].length))+63);
      arcTypo[i][j].display();
      arcTypo[i][j].rotateZ(radians(angularSpeed_0 + speedDifference*(1-i/float(arcTypo.length))));
    }
  }
}

void keyPressed() {
  switch(key) {
  case 'w':
  case 'W':
    for (int i = 0; i < arcTypo.length; i++) {
      for (int j = 0; j < arcTypo[0].length; j++) {      
        arcTypo[i][j].translate(0, 0, 10);
      }
    }   
    break;
  case 's':
  case 'S':
    for (int i = 0; i < arcTypo.length; i++) {
      for (int j = 0; j < arcTypo[0].length; j++) {      
        arcTypo[i][j].translate(0, 0, -10);
      }
    }   
    break;
  case 'b':
  case 'B':
    for (int i = 0; i < arcTypo.length; i++) {
      for (int j = 0; j < arcTypo[0].length; j++) {        
        arcTypo[i][j].debug = !arcTypo[i][j].debug;
      }
    }
    break;
  }
}

