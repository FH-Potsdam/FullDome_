import processing.opengl.*;

FisheyeTypoQuad[] bbTypo = new FisheyeTypoQuad[10];
String[] lines;

static final int BILLBOARD_TYPE = 0;
static final int ARC_TYPE = 1;
float xMax, xMin, maxDist = 1024f;
float xSpacing = 128;
float z0 = 128;
float xSpeed = 2;

void setup() {
  size(1024, 1024, OPENGL);
  xMax = width/2+maxDist;
  xMin = width/2-maxDist;
  lines = loadStrings("kafka_blindtext.txt");
  for (int i =0; i < bbTypo.length; i++) {
    int line_number = i%lines.length;
    bbTypo[i] = new FisheyeTypoQuad(this, BILLBOARD_TYPE, lines[line_number], loadFont("Georgia-Bold-48.vlw"), 48f, color(255), z0, xMin+xSpacing*i, HALF_PI);
  }
}

void draw() {
  background(0);
  stroke(255);
  fill(255, 0, 0);
  for (int i =0; i < bbTypo.length; i++) {
    float d = sq(1-abs(bbTypo[i].selfOrigin.x-width/2)/maxDist);
    if (d > 1) {
      println(d);
    }
    tint(d*255);
    bbTypo[i].display();
    bbTypo[i].translate(-xSpeed, 0f, 0);
    if (bbTypo[i].selfOrigin.x < xMin) {
      bbTypo[i].translate(maxDist*2f, 0, 0);
    }
  }
}

void keyPressed() {
  switch(key) {
  case 'w':
  case 'W':
    for (int i =0; i < bbTypo.length; i++) {
      bbTypo[i].translate(0, 0, 10);
    }    
    break;
  case 's':
  case 'S':
    for (int i =0; i < bbTypo.length; i++) {
      bbTypo[i].translate(0, 0, -10);
    }
    break;
  case 'a':
  case 'A':
    for (int i =0; i < bbTypo.length; i++) {
      bbTypo[i].rotateZ(radians(-1));
    }
    break;
  case 'd':
  case 'D':
    for (int i =0; i < bbTypo.length; i++) {
      bbTypo[i].rotateZ(radians(1));
    }
    break;
  case 'b':
  case 'B':
    for (int i =0; i < bbTypo.length; i++) {
      bbTypo[i].debug = !bbTypo[i].debug;
    }
    break;
  }
}

