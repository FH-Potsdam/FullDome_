class FisheyeQuad {
  PApplet p5;
  int hRes, vRes;
  float[][][] vertices;
  float[][][] fisheyeVertices;
  float zIndex = 0f, displayZ = 0f;
  float Z_INDEX_FACTOR = 0.1f;
  int BILLBOARD_MODE = 0;
  int CYLINDER_MODE = 1;
  float RESOLUTION_FACTOR = 1/50f; //one segment per n pixels.
  int mode = BILLBOARD_MODE;
  PVector worldOrigin, selfOrigin = new PVector();
  float myRadius;
  float SPHERICAL_ANGLE = PI;

  FisheyeQuad(PApplet p5) {
    this.p5 = p5;
    worldOrigin = new PVector(p5.width/2, p5.height/2, 0);
  }  

  FisheyeQuad (PApplet p5, PVector[] theCorners) {
    this.p5 = p5;
    myRadius = p5.height*0.5f;
    float theWidth = sqrt(sq(theCorners[0].x-theCorners[1].x)+sq(theCorners[0].y-theCorners[1].y)+sq(theCorners[0].z-theCorners[1].z));
    float theHeight = sqrt(sq(theCorners[1].x-theCorners[2].x)+sq(theCorners[1].y-theCorners[2].y)+sq(theCorners[1].z-theCorners[2].z));
    setRes(theWidth, theHeight);
    worldOrigin = new PVector(p5.width/2, p5.height/2, 0);
    initVertices(theCorners);
  }

  void display() {
    for (int j = 0; j < vRes; j++) {
      p5.beginShape(QUAD_STRIP);
      for (int i = 0; i < hRes+1; i++) {
        drawVertexF(p5, fisheyeVertices[i][j], displayZ);
        drawVertexF(p5, fisheyeVertices[i][j+1], displayZ);
      }
      p5.endShape();
    }
  }
  void drawVertexF(PApplet applet, float[] v, float z) {
    applet.vertex(v[0], v[1], z);
  }

  void drawTexturedVertexF(PApplet applet, float[] v, float z, float[] st) {
    applet.vertex(v[0], v[1], z, st[0], st[1]);
  }

  void initVertices(PVector[] c) {
    vertices = new float[hRes+1][vRes+1][3];
    fisheyeVertices = new float[hRes+1][vRes+1][3];
    selfOrigin = new PVector((c[0].x+c[1].x+c[2].x+c[3].x)*0.25f, (c[0].y+c[1].y+c[2].y+c[3].y)*0.25f, (c[0].z+c[1].z+c[2].z+c[3].z)*0.25f);
    //BILLBOARD_MODE:
    float myHInc = 1f/float(hRes);
    float myVInc = 1f/float(vRes);
    for (int i = 0; i < hRes+1; i++) {
      for (int j = 0; j < vRes+1; j++) {
        vertices[i][j][0] =((c[3].x-c[0].x)*j*myVInc+c[0].x-((c[2].x-c[1].x)*j*myVInc+c[1].x))*i*myHInc+(c[2].x-c[1].x)*j*myVInc+c[1].x;
        vertices[i][j][1] =((c[3].y-c[0].y)*j*myVInc+c[0].y-((c[2].y-c[1].y)*j*myVInc+c[1].y))*i*myHInc+(c[2].y-c[1].y)*j*myVInc+c[1].y;
        vertices[i][j][2] =((c[3].z-c[0].z)*j*myVInc+c[0].z-((c[2].z-c[1].z)*j*myVInc+c[1].z))*i*myHInc+(c[2].z-c[1].z)*j*myVInc+c[1].z;        								
        fisheyeVertices[i][j] = vertexToFisheyeVertex(vertices[i][j]);
      }
    }
  }

  void setZIndex(int z) {
    zIndex = z;
    displayZ = zIndex*Z_INDEX_FACTOR;
  }

  float[] vertexToFisheyeVertex(float v[], float r) {
    float x = v[0] - worldOrigin.x;
    float y = v[1] - worldOrigin.y;
    float z = v[2] - worldOrigin.z;
    float d = sqrt(x*x+y*y+z*z);	
    float theta = acos(z/d);
    float radius = theta/SPHERICAL_ANGLE;
    float phi = atan2(y, x);
    float xP = cos(phi)*radius*r +  worldOrigin.x;
    float yP = sin(phi)*radius*r +  worldOrigin.y;
    float zP = Math.signum(z)*d +  worldOrigin.z;
    return new float[] {
      xP, yP, zP
    };
  }

  float[] vertexToFisheyeVertex(float v[]) {
    return vertexToFisheyeVertex(v, p5.height);
  }

  void translate(float x, float y, float z) {
    for (int i = 0; i < hRes+1; i++) {
      for (int j = 0; j < vRes+1; j++) {
        vertices[i][j][0] += x;
        vertices[i][j][1] += y;
        vertices[i][j][2] += z;
        fisheyeVertices[i][j] = vertexToFisheyeVertex(vertices[i][j]);
      }
    }
    selfOrigin.x += x;
    selfOrigin.y += y;
    selfOrigin.z += z;
  }

  void rotateX(PVector origin, float phi) {
    for (int i = 0; i < hRes+1; i++) {
      for (int j = 0; j < vRes+1; j++) {
        float x = vertices[i][j][0] - origin.x;
        float y = vertices[i][j][1] - origin.y;
        float z = vertices[i][j][2] - origin.z;
        vertices[i][j][0] = x + origin.x;
        vertices[i][j][1] = z*sin(phi)+y*cos(phi) + origin.y;
        vertices[i][j][2] = z*cos(phi)-y*sin(phi) + origin.z;
        fisheyeVertices[i][j] = vertexToFisheyeVertex(vertices[i][j]);
      }
    }
    rotateX(selfOrigin, origin, phi);
  }

  void rotateX(PVector v, PVector origin, float phi) {
    float x0 = v.x - origin.x;
    float y0 = v.y - origin.y; 
    float z0 = v.z - origin.z;
    v.x = x0 + origin.x;
    v.y = z0*sin(phi)+y0*cos(phi) + origin.y;
    v.z = z0*cos(phi)-y0*sin(phi) + origin.z;
  }

  void rotateY(PVector origin, float phi) {
    for (int i = 0; i < hRes; i++) {
      for (int j = 0; j < vRes; j++) {
        float x = vertices[i][j][0] - origin.x;
        float y = vertices[i][j][1] - origin.y;
        float z = vertices[i][j][2] - origin.z;
        vertices[i][j][0] = x*cos(phi)-z*sin(phi) + origin.x;
        vertices[i][j][1] = y + origin.y;
        vertices[i][j][2] = x*sin(phi)+z*cos(phi) + origin.z;
        fisheyeVertices[i][j] = vertexToFisheyeVertex(vertices[i][j]);
      }
    }
    rotateY(selfOrigin, origin, phi);
  }

  void rotateY(PVector v, PVector origin, float phi) {
    float x0 = v.x - origin.x;
    float y0 = v.y - origin.y; 
    float z0 = v.z - origin.z;
    v.x = x0*cos(phi)-z0*sin(phi) + origin.x;
    v.y = y0 + origin.y;
    v.z = x0*sin(phi)+z0*cos(phi) + origin.z;
  }

  void rotateZ(PVector origin, float phi) {
    for (int i = 0; i < hRes+1; i++) {
      for (int j = 0; j < vRes+1; j++) {
        float x = vertices[i][j][0] - origin.x;
        float y = vertices[i][j][1] - origin.y;
        float z = vertices[i][j][2] - origin.z;
        vertices[i][j][0] = x*cos(phi)-y*sin(phi) + origin.x;
        vertices[i][j][1] = x*sin(phi)+y*cos(phi) + origin.y;
        vertices[i][j][2] = z + origin.z;
        fisheyeVertices[i][j] = vertexToFisheyeVertex(vertices[i][j]);
      }
    }
    rotateZ(selfOrigin, origin, phi);
  }

  void rotateZ(PVector v, PVector origin, float phi) {
    float x0 = v.x - origin.x;
    float y0 = v.y - origin.y; 
    float z0 = v.z - origin.z;
    v.x = x0*cos(phi) - y0*sin(phi) + origin.x;
    v.y = x0*sin(phi) + y0*cos(phi) + origin.y;
    v.z = z0 + origin.z;
  }

  void rotateX(float phi) {
    rotateX(worldOrigin, phi);
  }

  void rotateY(float phi) {
    rotateY(worldOrigin, phi);
  }

  void rotateZ(float phi) {
    rotateZ(worldOrigin, phi);
  }

  void setRes(float theWidth, float theHeight) {
    hRes = ceil(theWidth*RESOLUTION_FACTOR);
    vRes = ceil(theHeight*RESOLUTION_FACTOR);
  }
}

