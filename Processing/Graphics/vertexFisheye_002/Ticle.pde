public class Ticle {
  public PVector pos;
  public PVector posF;
  float size = 10f;
  Ticle[] myTicles;
  int[] myTicleBuddies;
  private int MAX_BUDDIES = 3;
  float dist;
  int MAX_RES = 20;



  public Ticle (Ticle[] theTicles) {
    myTicles = theTicles;
    init();
  }

  public void init() {
    pos = new PVector(random(-height*2f, height*2f), random(-height*2f, height*2f), random(-height*0.5f, height*1.5f));
    myTicleBuddies = new int[MAX_BUDDIES];
    for (int i = 0; i < myTicleBuddies.length; i++) {
      myTicleBuddies[i] = floor(random(myTicles.length));
    }
    dist = sqrt(sq(pos.x)+sq(pos.y)+sq(pos.z));
    if (dist > height) {
      pos.normalize();
      pos.mult(height-10f);
    }
    posF = vectorF(pos);
  }

  private void drawAxes() {
    stroke(255);
    noFill();
    beginShape();
    vertexF(pos.x-size, pos.y, pos.z);
    vertexF(pos.x, pos.y, pos.z);
    vertexF(pos.x+size, pos.y, pos.z);
    endShape();
    beginShape();
    vertexF(pos.x, pos.y-size, pos.z);
    vertexF(pos.x, pos.y, pos.z);
    vertexF(pos.x, pos.y+size, pos.z);
    endShape();
    beginShape();
    vertexF(pos.x, pos.y, pos.z-size);
    vertexF(pos.x, pos.y, pos.z);
    vertexF(pos.x, pos.y, pos.z+size);
    endShape();
    if (edgesOn ) drawEdges();
  }

  private void drawBox () {
    int[] myColors = {
      color(0, 127, 255), color(0, 63, 127), color(0, 31, 63)
    };
    drawCube(this.pos, this.size*10f, floor(this.MAX_RES*0.25f), myColors);
    //drawCube(this.pos, this.size*10f, 1, myColors);
    if (edgesOn ) drawEdges();
  }

  private void drawEdges() {
    //stroke(255, 255, 0, 63);
    stroke(255, 191);
    noFill();
    for (int i = 0; i < myTicleBuddies.length; i++) {
      //int res = floor(1/(1f+sqrt(dist*myTicles[myTicleBuddies[i]].dist)))*MAX_RES;
      //int res = sqrt(pos.z+height*0.5f)*myTicles[myTicleBuddies[i]].pos.z*MAX_RES;
      //float d = PVector.dist(posF, myTicles[myTicleBuddies[i]].posF);
      //int res = (int)(height/d*MAX_RES);
      int res = MAX_RES;
      //System.out.println(res);
      beginShape();
      float x0 = pos.x;
      float y0 = pos.y;
      float z0 = pos.z;
      float x1 = myTicles[myTicleBuddies[i]].pos.x;
      float y1 = myTicles[myTicleBuddies[i]].pos.y;
      float z1 = myTicles[myTicleBuddies[i]].pos.z;
      vertexF(x0, y0, z0);
      float myInc = 1/(float)res;
      for (int j = 0; j < res; j++) {
        vertexF((x1-x0)*j*myInc+x0, (y1-y0)*j*myInc+y0, (z1-z0)*j*myInc+z0);
      }
      vertexF(x1, y1, z1);
      endShape();
    }
  }


  public void display() {
    switch (MODE) {
      case (0) : 
      drawAxes();
      break;
      case (1) : 
      drawBox();
      break;
    }
  }

  public void move(float theX, float theY, float theZ) {
    pos.set(pos.x+theX, pos.y+theY, pos.z+theZ);
    dist = sqrt(sq(pos.x)+sq(pos.y)+sq(pos.z));
    posF = vectorF(pos);
    //if (pos.z < -height*0.5f || pos.z > height*1.5f || pos.x < -height*2f || pos.x > height*2f || pos.y < -height*2f || pos.y > height*2f) init();
    if (dist > height ) init();
  }

  public void rotX(PVector o, float phi) {
    pos = rotateX(o, pos, phi);
    posF = vectorF(pos);
  }

  public void rotY(PVector o, float phi) {
    pos = rotateY(o, pos, phi);
    posF = vectorF(pos);
  }

  public void rotZ(PVector o, float phi) {
    pos = rotateZ(o, pos, phi);
    posF = vectorF(pos);
  }

  public void setSize(float newSize) {
    size = newSize;
  }

  public void setPos(PVector newPos) {
    pos = newPos;
  }
}
