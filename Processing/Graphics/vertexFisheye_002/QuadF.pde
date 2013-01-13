public class QuadF {
  public PVector pos;
  public PVector posF;
  public PVector[] corners;
  public PVector[][] vertices;
  public PVector[][] verticesF;
  public float width, height;
  public int RES;
  public PImage pTex;
  public GLTexture gTex;
  String[] MODES = {
    "XY", "YZ", "XZ", "FREE"
  };
  String MODE; 
  boolean texOn = false;
  public boolean flipX, flipY, rot90, rot270;
  boolean showGrid = true;
  int myColor = color(127, 0, 255);


  public QuadF (PVector thePos, PVector[] theCorners, float theWidth, float theHeight, int theRes, String theMode) {
    pos = thePos;
    width = theWidth;
    height = theHeight;
    RES = theRes;
    vertices = new PVector[RES+1][RES+1];
    verticesF = new PVector[RES+1][RES+1];
    if (theCorners == null || theCorners.length != 4) {
      MODE = theMode;
      initCorners();
    } 
    else {
      //in this case, width and height will actually be ignored
      corners = theCorners;
      MODE = "FREE";
    }
    setVertices();
  }

  public void display() {
    if (pTex == null && gTex == null) {
      if (showGrid) {
        stroke(255);
        strokeWeight(1);
      } 
      else {
        noStroke();
      }
      fill(color(myColor));
      for (int j = 0; j < vertices.length-1;j++ ) {
        beginShape(QUAD_STRIP);
        for (int i = 0; i < vertices[0].length; i++) {
          vertex(verticesF[i][j]);
          vertex(verticesF[i][j+1]);
        }
        endShape();
      }
    } 
    else {
      if (gTex == null) {

        float wInc = pTex.width/(float)RES;
        float hInc = pTex.height/(float)RES;
        for (int j = 0; j < vertices.length-1;j++ ) {
          beginShape(QUAD_STRIP);
          texture(pTex);
          for (int i = 0; i < vertices[0].length; i++) {
            vertex(verticesF[i][j], wInc*i, hInc*j);
            vertex(verticesF[i][j+1], wInc*i, hInc*(j+1));
          }
          endShape();
        }
      } 
      else {
        float wInc = gTex.width/(float)RES;
        float hInc = gTex.height/(float)RES;
        for (int j = 0; j < vertices.length-1;j++ ) {
          beginShape(QUAD_STRIP);
          texture(gTex);
          for (int i = 0; i < vertices[0].length; i++) {
            vertex(verticesF[i][j], wInc*i, hInc*j);
            vertex(verticesF[i][j+1], wInc*i, hInc*(j+1));
          }
          endShape();
        }
      }
    }
  }

  public void setTexture(PImage theTex) {
    pTex = theTex;
  }

  public void setTexture(GLTexture theTex) {
    gTex = theTex;
  }

  public void setVertices () {
    float myInc = 1f/(float)RES;
    for (int i = 0; i <= RES; i++) {
      for (int j = 0; j <= RES; j++) {
        vertices[i][j] = new PVector (
        ((corners[3].x-corners[0].x)*j*myInc+corners[0].x-((corners[2].x-corners[1].x)*j*myInc+corners[1].x))*i*myInc+(corners[2].x-corners[1].x)*j*myInc+corners[1].x, 								
        ((corners[3].y-corners[0].y)*j*myInc+corners[0].y-((corners[2].y-corners[1].y)*j*myInc+corners[1].y))*i*myInc+(corners[2].y-corners[1].y)*j*myInc+corners[1].y, 
        ((corners[3].z-corners[0].z)*j*myInc+corners[0].z-((corners[2].z-corners[1].z)*j*myInc+corners[1].z))*i*myInc+(corners[2].z-corners[1].z)*j*myInc+corners[1].z);
        verticesF[i][j] = vectorF(vertices[i][j]);
      }
    }
  }

  public void initCorners() {
    corners = new PVector[4];
    corners[0] = new PVector();
    corners[1] = new PVector();
    corners[2] = new PVector();
    corners[3] = new PVector();
    if (MODE.equalsIgnoreCase("XY")) {
      corners[0] = new PVector (pos.x-width*0.5f, pos.y-height*0.5f, pos.z);
      corners[1] = new PVector (pos.x+width*0.5f, pos.y-height*0.5f, pos.z);
      corners[2] = new PVector (pos.x+width*0.5f, pos.y+height*0.5f, pos.z);
      corners[3] = new PVector (pos.x-width*0.5f, pos.y+height*0.5f, pos.z);
    }

    if (MODE.equalsIgnoreCase("YZ")) {
      corners[0] = new PVector (pos.x, pos.y-width*0.5f, pos.z-height*0.5f);
      corners[1] = new PVector (pos.x, pos.y-width*0.5f, pos.z+height*0.5f);
      corners[2] = new PVector (pos.x, pos.y+width*0.5f, pos.z+height*0.5f);
      corners[3] = new PVector (pos.x, pos.y+width*0.5f, pos.z-height*0.5f);
    }

    if (MODE.equalsIgnoreCase("XZ")) {
      corners[0] = new PVector (pos.x-width*0.5f, pos.y, pos.z-height*0.5f);
      corners[1] = new PVector (pos.x-width*0.5f, pos.y, pos.z+height*0.5f);
      corners[2] = new PVector (pos.x+width*0.5f, pos.y, pos.z+height*0.5f);
      corners[3] = new PVector (pos.x+width*0.5f, pos.y, pos.z-height*0.5f);
    }
  }

  public void move(float theX, float theY, float theZ) {
    pos.set(pos.x+theX, pos.y+theY, pos.z+theZ);
    posF = vectorF(pos);
    corners[0].set(corners[0].x+theX, corners[0].y+theY, corners[0].z+theZ);
    corners[1].set(corners[1].x+theX, corners[1].y+theY, corners[1].z+theZ);
    corners[2].set(corners[2].x+theX, corners[2].y+theY, corners[2].z+theZ);
    corners[3].set(corners[3].x+theX, corners[3].y+theY, corners[3].z+theZ);
    setVertices();
  }

  public void rotX(PVector o, float phi) {
    pos = rotateX(o, pos, phi);
    posF = vectorF(pos);
    corners[0] = rotateX(o, corners[0], phi);
    corners[1] = rotateX(o, corners[1], phi);
    corners[2] = rotateX(o, corners[2], phi);
    corners[3] = rotateX(o, corners[3], phi);
    setVertices();
  }
  public void rotY(PVector o, float phi) {
    pos = rotateY(o, pos, phi);
    posF = vectorF(pos);
    corners[0] = rotateY(o, corners[0], phi);
    corners[1] = rotateY(o, corners[1], phi);
    corners[2] = rotateY(o, corners[2], phi);
    corners[3] = rotateY(o, corners[3], phi);
    setVertices();
  }
  public void rotZ(PVector o, float phi) {
    pos = rotateZ(o, pos, phi);
    posF = vectorF(pos);
    corners[0] = rotateZ(o, corners[0], phi);
    corners[1] = rotateZ(o, corners[1], phi);
    corners[2] = rotateZ(o, corners[2], phi);
    corners[3] = rotateZ(o, corners[3], phi);
    setVertices();
  }
}

