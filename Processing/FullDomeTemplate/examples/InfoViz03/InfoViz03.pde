// Hi Boris, hier kannst du die Anzahl der Boxen einstellenn
int NUM_PARTICLES = 150;







/**
 * this project uses an fbo to write into cubemap txtures dynamically
 * use wasd or arrow cursors to navigate, use mouse to move the cursor
 * you can press the mouse to zoom in as well
 *
 * Author: Christopher Warnow, 2010, ch.warnow@gmx.de
 */
import codeanticode.glgraphics.*;
import processing.opengl.*;
import javax.media.opengl.*;
import javax.media.opengl.glu.GLU;
import com.sun.opengl.util.*;
import toxi.physics.constraints.*;
import toxi.physics.*;
import toxi.geom.*;
import fullscreen.*;

GLSLShader shader;
PGraphicsOpenGL pgl;
GL gl;
GLU glu;
GLUT glut;
PFont myFont;
int REST_LENGTH = 1;
int SPHERE_RADIUS = 200;

VerletPhysics physics;
DataItem d;
ArrayList dataList = new ArrayList();
Vec3D mouseP;
float globalZoom = 0;

String[] cities = { 
  "Potsdam", "Beelitz", "Belzig", "Havelsee", "Niemegk", "Teltow", "Treuenbrietzen", "Werder", "Ziesar", "Gross Kreutz (Havel)", "Kleinmachnow", "Kloster Lehnin", "Michendorf", "Nuthetal", "Schwielowsee", "Seddiner See", "Stahnsdorf", "Wiesenburg/Mark", "Beetzsee", "Beetzsee", "Beetzseeheide", "Havelsee Stadt", "Päwesin", "Roskow", "Brück", "Borkheide", "Borkwalde", "Brück Stadt", "Golzow", "Linthe", "Planebruch", "Niemegk", "Mühlenfließ", "Niemegk Stadt", "Planetal", "Rabenstein/Fläming", "Wusterwitz", "Bensdorf", "Rosenau", "Wusterwitz", "Ziesar", "Buckautal", "Görzke", "Gräben", "Wenzlow", "Wollin", "Ziesar Stadt"  };
PVector mousePos;
float mouseSpeed = .2;
float globalX = 0;
float globalZ = 0;
float destGlobalX = 0;
float destGlobalZ = 0;

void setup() {
  println(cities.length);
  //size(screen.width, screen.height, OPENGL);
   size(600, 600, OPENGL);
  mousePos = new PVector(width*.5, height*.5, 0);
  glut = new GLUT();
  glu = new GLU();
  pgl = (PGraphicsOpenGL) g;
  gl = pgl.gl;

  // init physics
  // create collision sphere at origin, replace OUTSIDE with INSIDE to
  // keep particles inside the sphere
  ParticleConstraint sphere = new SphereConstraint(new Sphere(
  new Vec3D(), SPHERE_RADIUS), SphereConstraint.INSIDE);
  physics = new VerletPhysics();
  // set bounding box to 110% of sphere radius
  physics.setWorldBounds(new AABB(new Vec3D(), new Vec3D(SPHERE_RADIUS,
  SPHERE_RADIUS, SPHERE_RADIUS).scaleSelf(1.0f)));

  int cityID = 0;
  for (int i = 0; i < NUM_PARTICLES; i++) {
    // create particles at random positions outside sphere
    VerletParticle p = new VerletParticle(Vec3D.randomVector()
      .scaleSelf(SPHERE_RADIUS * random(1) * .95));
    p.addVelocity(Vec3D.randomVector().scaleSelf(.02));
    DataItem data = new DataItem(p, cities[cityID++].toUpperCase());
    if(cityID == cities.length) cityID = 0;
    // set sphere as particle constraint
    p.addConstraint(sphere);
    physics.addParticle(p);
    dataList.add(data);
  }

  // test font init
  String[] fontList = PFont.list();
  // println(fontList);
  myFont = createFont("Helvetica", 32);
  textFont(myFont);

  initCubeMap();

  noCursor();
}

void draw() {
  // main position
  globalX += (destGlobalX - globalX)*.25;
  globalZ += (destGlobalZ - globalZ)*.25;

  // println(frameRate);
  background(0, 0, 30);
  if(mousePressed) {
    destGlobalZ += 3;
  }else{
    destGlobalZ -= 1;
    if (destGlobalZ < 0){
     destGlobalZ = 0; 
    }
  }

  mousePos.x += (mouseX - mousePos.x) * mouseSpeed;
  mousePos.y += (mouseY - mousePos.y) * mouseSpeed;
  mouseP = new Vec3D(-mousePos.x + width*.5, mousePos.y - height*.5, 0);
  
  //println(mousePos.x + " " + mousePos.y);

  // update dataitems
  for(int i=0;i<dataList.size();i++) {
    DataItem d = (DataItem) dataList.get(i);

    float distance = dist(mouseP.x, mouseP.y, mouseP.z, d.position.x(), d.position.y(), d.position.z());
    if(distance < 100) {
      // move to mouse a bit
      d.position.addSelf(
      (mouseP.x - d.position.x) * (.01+(1-(distance/100))*.255),
      (mouseP.y - d.position.y) * (.01+(1-(distance/100))*.255),
      (mouseP.z - d.position.z) * (.01+(1-(distance/100))*.255)
        );
    }

    d.update();
  }

  // update physics
  physics.update();

  // draw a sphere that reflects its environment (cubemap)
  drawCubeMap();
}

/*
 * this scene is called 6 times for the cubemap 
 * unfortunately one has to use pure opengl calls, the processing ones are not visible
 */
void drawScene() {
 
  pushMatrix();
  // rotateY(globalRotation);
  translate(globalX, 0, globalZ);

  gl.glBlendFunc (GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA);
  //  gl.glDisable(GL.GL_DEPTH_TEST);
  float light_pos[] = { 
    10, 50, -200, 0             };
  float light_color_am[] = { 
    .5f, .5f, .85f, 1             };
  float light_color_diff[] = { 
    .8f, .8f, 1f, 1             };
  float light_color_spec[] = { 
    1, 1, 1, 1             };

  gl.glLightfv(GL.GL_LIGHT0, GL.GL_POSITION, light_pos, 0);
  gl.glLightfv(GL.GL_LIGHT0, GL.GL_AMBIENT, light_color_am, 0);
  gl.glLightfv(GL.GL_LIGHT0, GL.GL_DIFFUSE, light_color_diff, 0);
  gl.glLightfv(GL.GL_LIGHT0, GL.GL_SPECULAR, light_color_spec, 0);

  gl.glEnable(GL.GL_LIGHTING);
  gl.glEnable(GL.GL_LIGHT0);

  gl.glEnable(GL.GL_DEPTH_TEST);
  gl.glDepthFunc(GL.GL_LEQUAL);

  // gl.glEnable(GL.GL_SMOOTH);
  // gl.glShadeModel(GL.GL_SMOOTH);


  // This fixes the overlap issue
  // gl.glDisable(GL.GL_DEPTH_TEST);
  // gl.glBlendFunc (GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA);
  // gl.glEnable(GL.GL_DEPTH_TEST);
  // gl.glDepthFunc(GL.GL_LEQUAL);
  
  for(int i=0;i<dataList.size();i++) {
    DataItem d = (DataItem) dataList.get(i);
    stroke(255, 50);
    strokeWeight(.5);
    // data box
    fill(255, 230, 230);
    pushMatrix();
    translate(d.position.x(), d.position.y(), d.position.z());
    pushMatrix();
    rotateX(d.position.headingXY());
    rotateY(d.position.headingXZ());
    rotateZ(d.position.headingYZ());
    box(3);
    popMatrix();
    popMatrix();
    strokeWeight(2);
    float distance = dist(mouseP.x, mouseP.y, mouseP.z, d.position.x(), d.position.y(), d.position.z());
    if(distance < 100) {
      // connecting lines
      int lineAmount = floor(noise(i)*5);
      fill(200 + noise(i*.1)*55, 200, 200, (1-(distance/100))*255);
      noFill();
      for(int j=0;j<lineAmount;j++) {
        Vec3D anchor0Pos = d.position.getRotatedX(j).scaleSelf(.175);
        Vec3D anchor1Pos = mouseP.getRotatedX(-j).scaleSelf(.175);
        beginShape();
        curveVertex(d.position.x, d.position.y, d.position.z);
        curveVertex(d.position.x, d.position.y, d.position.z);
        curveVertex(d.position.x + anchor0Pos.x, d.position.y + anchor0Pos.y, d.position.z + anchor0Pos.z);
        curveVertex(mouseP.x + anchor1Pos.x, mouseP.y + anchor1Pos.y, mouseP.z + anchor1Pos.z);
        curveVertex(mouseP.x, mouseP.y, mouseP.z);
        curveVertex(mouseP.x, mouseP.y, mouseP.z);
        endShape();
      }
      //
      // data text
      fill(200, 200, 255);
      pushMatrix();
      translate(d.position.x() + 5, d.position.y() + 5, d.position.z() + 5);
      pushMatrix();
      rotateX(d.position.headingXY());
      rotateY(d.position.headingXZ() + 180);
      rotateZ(d.position.headingYZ() + 180);
      scale((1-(distance/100))*.25);
      text(d.title, 0, 0);
      popMatrix();
      popMatrix();
    }
  }

  // cursorBox
  fill(255, 200, 50);
  pushMatrix();
  translate(mouseP.x, mouseP.y, mouseP.z);
  box(5);
  popMatrix();

  popMatrix();
}

void keyPressed() {
  if(key == 'w' || keyCode == UP) {
    destGlobalZ+=3;
  }
  if(key == 's' || keyCode == DOWN) {
    destGlobalZ-=3;
  }

  if(key == 'a' || keyCode == LEFT) {
    destGlobalX-=3;
  }
  if(key == 'd' || keyCode == RIGHT) {
    destGlobalX+=3;
  }
}



