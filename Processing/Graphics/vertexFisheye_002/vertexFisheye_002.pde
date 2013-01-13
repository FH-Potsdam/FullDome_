import codeanticode.glgraphics.GLTexture;
import processing.opengl.*;

/**
*  Per-vertex Fisheye-distorter, maybe just a proof of concept.
*  The actual core of the code are the functions vertexF() and vectorF(),
*  where each point from the model(view) coordinate space quasi-geographical
*  coordinates are assigned, then the point is rendered using an orthographical
*  view of an azimuthal equdistant porjection (=fulldome standard).
*  The z-coordinate functions as a kind of z-index and transformations have to be implemented
*  manually (see some of my variations in the supplied classes.)
*  The problem is that everything above vertices (lines and faces) needs to be interpolated,
*  cf. the quad-examples. This is unfortunately very resource-intensive, and unlike
*  Christopher Warnow's very convenient FullDome Template not a hardware-based implementation.
*  One of the possible useful scenarios would if one does only need statical vertex-coordinates.
*  (in this case there could be an advantage to rendering the frame 5 times 
*  and not exhausting OpenGL resources)
*  Keys:
*  't'/'g' - adds/substracts 5° to the spherical angle ("FOV" of the camera (max. 360°))
*  'r'/'f' - move the sample cube along the z-axis
*  'e' - turn the edges between the (par)ticles on/off
*  'w' - (doesn't work!) switch between orthographical and perspective view
*   SPACE - screenshot
*  
*  Andres Colubri (author of the GLGraphics library) mentions a link which seems
*  pretty promising:
*  http://pages.cpsc.ucalgary.ca/~brosz/wiki/pmwiki.php/CSharp/08022008
*  His own solution (and some others found in internet) is however unfortunately
*  merely the pseudodeformation of a plane image. You can notice the difference
*  by observing how quickly an object disappears, moved eccentrically in the XY-plane.
*  With a real fisheye, such an object is visible to the infinity (never leaves the field if view).
*
*  v002 | dimitar.ruszev@gmail.com | 2011
*/


float xPos =-300;
float yPos =-300;
float zPos =100;
boolean orthoOn = true;
private static float SPHERICAL_ANGLE = PI;
public Ticle[] ticles;
boolean edgesOn = true;
boolean showGrid = true;
QuadF qf;
PImage img;
GLTexture glt;
static int MODE = 0; 
  String[] MODES = {
    "CARTESIAN_AXE", "BOX"
  };
  
 void setup() {
  size(800, 800, OPENGL);
  ticles = new Ticle[200];
  for (int i = 0; i < ticles.length; i++) {
    ticles[i] = new Ticle(ticles);
  }
  ticles[0].setSize(50f);
  ticles[0].setPos(new PVector(random(-50, 50), random(-50, 50), random(height/2, height)));
  qf = new QuadF(new PVector(0, 0, 100f), null, 200f, 200f, 20, "XY");
  img = loadImage(dataPath("")+"icosa_003_left_00024.jpg");
  //glt = new GLTexture(this, dataPath("")+"icosa_003_left_00024.jpg");
  qf.setTexture(img);
}

 void draw() {
  background(0);
  if (orthoOn) {
    ortho(0, width, 0, height, -height*2f, height*2f);
    translate(width, 0, 0);
    //rotateY(HALF_PI*0.5f);
    //rotateX(map(mouseY,0,height,-PI,PI));
  } 
  else {
    translate(width/2, height/2f, 0);
    //rotateY(HALF_PI*0.5f);
    //rotateX(map(mouseY,0,height,-PI,PI));
  }
  drawSampleCube();
  qf.rotY(ticles[0].pos, -TWO_PI/720f);
  qf.rotZ(qf.pos, TWO_PI/720f);
  //qf.move(0,1,0);
  qf.display();
  for (int i = 0; i < ticles.length; i++) {
    //ticles[i].move(1,0, -1);
    //ticles[i].move(0,1, 0);
    //ticles[i].move(1,0, 0);
    //ticles[i].rotX(new PVector(0,0,height), TWO_PI/1440f);
    ticles[i].rotY(ticles[0].pos, TWO_PI/720f);
    ticles[i].display();
  }
}

private void drawCube(PVector pos, float size, int res, int[] c) {
  noStroke();
  fill(color(c[0]));
  drawQuad(pos.x, pos.y, pos.z+size*0.5f, size, res, true, "XY");
  drawQuad(pos.x, pos.y, pos.z-size*0.5f, size, res, true, "XY");
  fill(color(c[1]));
  drawQuad(pos.x+size*0.5f, pos.y, pos.z, size, res, true, "YZ");
  drawQuad(pos.x-size*0.5f, pos.y, pos.z, size, res, true, "YZ");
  fill(color(c[2]));
  drawQuad(pos.x, pos.y+size*0.5f, pos.z, size, res, true, "XZ");
  drawQuad(pos.x, pos.y-size*0.5f, pos.z, size, res, true, "XZ");
}

private void drawSampleCube() {
  stroke(255);
  fill(255, 0, 0, 127);
  drawQuad(map(mouseX, 0, width, -800, 800), map(mouseY, 0, height, -800, 800), zPos+50f, 100f, 10, true, "XY");
  drawQuad(map(mouseX, 0, width, -800, 800)+50f, map(mouseY, 0, height, -800, 800), zPos, 100f, 10, true, "YZ");
  drawQuad(map(mouseX, 0, width, -800, 800), map(mouseY, 0, height, -800, 800)+50f, zPos, 100f, 10, true, "XZ");
  noFill();
  drawQuad(map(mouseX, 0, width, -800, 800), map(mouseY, 0, height, -800, 800), zPos-50f, 100f, 10, true, "XY");
  drawQuad(map(mouseX, 0, width, -800, 800)-50f, map(mouseY, 0, height, -800, 800), zPos, 100f, 10, true, "YZ");
  drawQuad(map(mouseX, 0, width, -800, 800), map(mouseY, 0, height, -800, 800)-50f, zPos, 100f, 10, true, "XZ");
  fill(0, 255, 0, 127);
  drawQuad(map(mouseX, 0, width, -800, 800), map(mouseY, 0, height, -800, 800), zPos+50f, 100f, 10, false, "XY");
  drawQuad(map(mouseX, 0, width, -800, 800)+50f, map(mouseY, 0, height, -800, 800), zPos, 100f, 10, false, "YZ");
  drawQuad(map(mouseX, 0, width, -800, 800), map(mouseY, 0, height, -800, 800)+50f, zPos, 100f, 10, false, "XZ");
  noFill();
  drawQuad(map(mouseX, 0, width, -800, 800), map(mouseY, 0, height, -800, 800), zPos-50f, 100f, 10, false, "XY");
  drawQuad(map(mouseX, 0, width, -800, 800)-50f, map(mouseY, 0, height, -800, 800), zPos, 100f, 10, false, "YZ");
  drawQuad(map(mouseX, 0, width, -800, 800), map(mouseY, 0, height, -800, 800)-50f, zPos, 100f, 10, false, "XZ");
}


private void drawQuad(float xPos, float yPos, float zPos, float size, int res, boolean fisheyeIsOn, String MODE) {

  PVector[] v = new PVector[4];
  v[0] = new PVector();
  v[1] = new PVector();
  v[2] = new PVector();
  v[3] = new PVector();
  if (MODE.equalsIgnoreCase("XY")) {
    v[0] = new PVector (xPos-size*0.5f, yPos-size*0.5f, zPos);
    v[1] = new PVector (xPos+size*0.5f, yPos-size*0.5f, zPos);
    v[2] = new PVector (xPos+size*0.5f, yPos+size*0.5f, zPos);
    v[3] = new PVector (xPos-size*0.5f, yPos+size*0.5f, zPos);
  }

  if (MODE.equalsIgnoreCase("YZ")) {
    v[0] = new PVector (xPos, yPos-size*0.5f, zPos-size*0.5f);
    v[1] = new PVector (xPos, yPos-size*0.5f, zPos+size*0.5f);
    v[2] = new PVector (xPos, yPos+size*0.5f, zPos+size*0.5f);
    v[3] = new PVector (xPos, yPos+size*0.5f, zPos-size*0.5f);
  }

  if (MODE.equalsIgnoreCase("XZ")) {
    v[0] = new PVector (xPos-size*0.5f, yPos, zPos-size*0.5f);
    v[1] = new PVector (xPos-size*0.5f, yPos, zPos+size*0.5f);
    v[2] = new PVector (xPos+size*0.5f, yPos, zPos+size*0.5f);
    v[3] = new PVector (xPos+size*0.5f, yPos, zPos-size*0.5f);
  }


  float myInc = 1f/(float)res;
  if (fisheyeIsOn) {
    for (int i = 0; i < res; i++) {
      for (int j = 0; j < res; j++) {
        beginShape();
        vertexF(
        ((v[3].x-v[0].x)*j*myInc+v[0].x-((v[2].x-v[1].x)*j*myInc+v[1].x))*i*myInc+(v[2].x-v[1].x)*j*myInc+v[1].x, 								
        ((v[3].y-v[0].y)*j*myInc+v[0].y-((v[2].y-v[1].y)*j*myInc+v[1].y))*i*myInc+(v[2].y-v[1].y)*j*myInc+v[1].y, 
        ((v[3].z-v[0].z)*j*myInc+v[0].z-((v[2].z-v[1].z)*j*myInc+v[1].z))*i*myInc+(v[2].z-v[1].z)*j*myInc+v[1].z, 
        height*0.5f);
        vertexF(
        ((v[3].x-v[0].x)*(j+1)*myInc+v[0].x-((v[2].x-v[1].x)*(j+1)*myInc+v[1].x))*i*myInc+(v[2].x-v[1].x)*(j+1)*myInc+v[1].x, 
        ((v[3].y-v[0].y)*(j+1)*myInc+v[0].y-((v[2].y-v[1].y)*(j+1)*myInc+v[1].y))*i*myInc+(v[2].y-v[1].y)*(j+1)*myInc+v[1].y, 
        ((v[3].z-v[0].z)*(j+1)*myInc+v[0].z-((v[2].z-v[1].z)*(j+1)*myInc+v[1].z))*i*myInc+(v[2].z-v[1].z)*(j+1)*myInc+v[1].z, 
        height*0.5f);
        vertexF(
        ((v[3].x-v[0].x)*(j+1)*myInc+v[0].x-((v[2].x-v[1].x)*(j+1)*myInc+v[1].x))*(i+1)*myInc+(v[2].x-v[1].x)*(j+1)*myInc+v[1].x, 
        ((v[3].y-v[0].y)*(j+1)*myInc+v[0].y-((v[2].y-v[1].y)*(j+1)*myInc+v[1].y))*(i+1)*myInc+(v[2].y-v[1].y)*(j+1)*myInc+v[1].y, 
        ((v[3].z-v[0].z)*(j+1)*myInc+v[0].z-((v[2].z-v[1].z)*(j+1)*myInc+v[1].z))*(i+1)*myInc+(v[2].z-v[1].z)*(j+1)*myInc+v[1].z, 
        height*0.5f);
        vertexF(
        ((v[3].x-v[0].x)*j*myInc+v[0].x-((v[2].x-v[1].x)*j*myInc+v[1].x))*(i+1)*myInc+(v[2].x-v[1].x)*j*myInc+v[1].x, 
        ((v[3].y-v[0].y)*j*myInc+v[0].y-((v[2].y-v[1].y)*j*myInc+v[1].y))*(i+1)*myInc+(v[2].y-v[1].y)*j*myInc+v[1].y, 
        ((v[3].z-v[0].z)*j*myInc+v[0].z-((v[2].z-v[1].z)*j*myInc+v[1].z))*(i+1)*myInc+(v[2].z-v[1].z)*j*myInc+v[1].z, 
        height*0.5f);

        endShape(CLOSE);
      }
    }
  } 
  else {
    for (int i = 0; i < res; i++) {
      for (int j = 0; j < res; j++) {
        beginShape();
        vertex(
        ((v[3].x-v[0].x)*j*myInc+v[0].x-((v[2].x-v[1].x)*j*myInc+v[1].x))*i*myInc+(v[2].x-v[1].x)*j*myInc+v[1].x, 								
        ((v[3].y-v[0].y)*j*myInc+v[0].y-((v[2].y-v[1].y)*j*myInc+v[1].y))*i*myInc+(v[2].y-v[1].y)*j*myInc+v[1].y, 
        ((v[3].z-v[0].z)*j*myInc+v[0].z-((v[2].z-v[1].z)*j*myInc+v[1].z))*i*myInc+(v[2].z-v[1].z)*j*myInc+v[1].z);
        vertex(
        ((v[3].x-v[0].x)*(j+1)*myInc+v[0].x-((v[2].x-v[1].x)*(j+1)*myInc+v[1].x))*i*myInc+(v[2].x-v[1].x)*(j+1)*myInc+v[1].x, 
        ((v[3].y-v[0].y)*(j+1)*myInc+v[0].y-((v[2].y-v[1].y)*(j+1)*myInc+v[1].y))*i*myInc+(v[2].y-v[1].y)*(j+1)*myInc+v[1].y, 
        ((v[3].z-v[0].z)*(j+1)*myInc+v[0].z-((v[2].z-v[1].z)*(j+1)*myInc+v[1].z))*i*myInc+(v[2].z-v[1].z)*(j+1)*myInc+v[1].z);
        vertex(
        ((v[3].x-v[0].x)*(j+1)*myInc+v[0].x-((v[2].x-v[1].x)*(j+1)*myInc+v[1].x))*(i+1)*myInc+(v[2].x-v[1].x)*(j+1)*myInc+v[1].x, 
        ((v[3].y-v[0].y)*(j+1)*myInc+v[0].y-((v[2].y-v[1].y)*(j+1)*myInc+v[1].y))*(i+1)*myInc+(v[2].y-v[1].y)*(j+1)*myInc+v[1].y, 
        ((v[3].z-v[0].z)*(j+1)*myInc+v[0].z-((v[2].z-v[1].z)*(j+1)*myInc+v[1].z))*(i+1)*myInc+(v[2].z-v[1].z)*(j+1)*myInc+v[1].z);
        vertex(
        ((v[3].x-v[0].x)*j*myInc+v[0].x-((v[2].x-v[1].x)*j*myInc+v[1].x))*(i+1)*myInc+(v[2].x-v[1].x)*j*myInc+v[1].x, 
        ((v[3].y-v[0].y)*j*myInc+v[0].y-((v[2].y-v[1].y)*j*myInc+v[1].y))*(i+1)*myInc+(v[2].y-v[1].y)*j*myInc+v[1].y, 
        ((v[3].z-v[0].z)*j*myInc+v[0].z-((v[2].z-v[1].z)*j*myInc+v[1].z))*(i+1)*myInc+(v[2].z-v[1].z)*j*myInc+v[1].z);
        endShape();
      }
    }
  }
}


private void vertexF(float x, float y, float z, float r) {	
  float theta = acos(z/sqrt(x*x+y*y+z*z));
  float radius = theta/SPHERICAL_ANGLE*r*2;
  float phi = atan2(y, x);
  float xP = cos(phi)*radius;
  float yP = sin(phi)*radius;
  float zP;
  zP = -Math.signum(z)*sqrt(x*x+y*y+z*z);
  vertex(xP, yP, zP);
}	

private void vertexF(float x, float y, float z) {	
  float theta = acos(z/sqrt(x*x+y*y+z*z));
  float radius = theta/SPHERICAL_ANGLE*height;
  float phi = atan2(y, x);
  float xP = cos(phi)*radius;
  float yP = sin(phi)*radius;
  float zP;
  zP = Math.signum(z)*sqrt(x*x+y*y+z*z);
  vertex(xP, yP, zP);
}	
private void vertexF(PVector v) {
  float x = v.x;
  float y = v.y;
  float z = v.z;
  float theta = acos(z/sqrt(x*x+y*y+z*z));
  float radius = theta/SPHERICAL_ANGLE*height;
  float phi = atan2(y, x);
  float xP = cos(phi)*radius;
  float yP = sin(phi)*radius;
  float zP;
  zP = Math.signum(z)*sqrt(x*x+y*y+z*z);
  vertex(xP, yP, zP);
}	
private void vertexF(PVector v, float sCoord, float tCoord) {
  float x = v.x;
  float y = v.y;
  float z = v.z;
  float theta = acos(z/sqrt(x*x+y*y+z*z));
  float radius = theta/SPHERICAL_ANGLE*height;
  float phi = atan2(y, x);
  float xP = cos(phi)*radius;
  float yP = sin(phi)*radius;
  float zP;
  zP = Math.signum(z)*sqrt(x*x+y*y+z*z);
  vertex(xP, yP, zP, sCoord, tCoord);
}	
private void vertex(PVector v) {
  vertex(v.x, v.y, v.z);
}
private void vertex(PVector v, float sCoord, float tCoord) {
  vertex(v.x, v.y, v.z, sCoord, tCoord);
}


private PVector vectorF(PVector v) {
  float x = v.x;
  float y = v.y;
  float z = v.z;
  float theta = acos(z/sqrt(x*x+y*y+z*z));
  float radius = theta/SPHERICAL_ANGLE*height;
  float phi = atan2(y, x);
  float xP = cos(phi)*radius;
  float yP = sin(phi)*radius;
  float zP;
  zP = Math.signum(z)*sqrt(x*x+y*y+z*z);
  return new PVector(xP, yP, zP);
}	

public PVector rotateZ(PVector o, PVector v, float phi) {
  PVector result = new PVector();
  float x =v.x - o.x;
  float y =v.y - o.y;
  //float z =v.z - o.z;
  result.x = x*cos(phi)-y*sin(phi)+o.x;
  result.y = x*sin(phi)+y*cos(phi)+o.y;
  result.z = v.z;
  return result;
}

public PVector rotateX(PVector o, PVector v, float phi) {
  PVector result = new PVector();
  //float x =v.x - o.x;
  float y =v.y - o.y;
  float z =v.z - o.z;
  result.x = v.x;
  result.y = z*sin(phi)+y*cos(phi)+o.y;
  result.z = z*cos(phi)-y*sin(phi)+o.z;
  return result;
}

public PVector rotateY(PVector o, PVector v, float phi) {
  PVector result = new PVector();
  float x =v.x - o.x;
  //float y =v.y - o.y;
  float z =v.z - o.z;
  result.x = x*cos(phi)-z*sin(phi)+o.x;
  result.y = v.y;
  result.z = x*sin(phi)+z*cos(phi)+o.z;
  return result;
}	

  public void setMode() {
    MODE = (MODE+1)%MODES.length;
  }


public void keyPressed() {
  if (key == 'r') {
    zPos +=10f;
    System.out.println("zPos: " + zPos);
  }
  if (key == 'f') {
    zPos -=10f;
    System.out.println("zPos: " + zPos);
  }
  if (key == 't') {
    SPHERICAL_ANGLE = min(TWO_PI, SPHERICAL_ANGLE+TWO_PI/72f);
    System.out.println("spherical angle: " + degrees(SPHERICAL_ANGLE));
  }
  if (key == 'g') {
    SPHERICAL_ANGLE = max(TWO_PI/72f, SPHERICAL_ANGLE-TWO_PI/72f);
    System.out.println("spherical angle: " + degrees(SPHERICAL_ANGLE));
  }

  if (key == 'e') edgesOn = !edgesOn;  
  //if (key == 'q') setMode();
  //if (key == 'w') orthoOn = !orthoOn;
  if(key == ' ') saveFrame("screenshots\\screnshot-#####.jpg");
}

