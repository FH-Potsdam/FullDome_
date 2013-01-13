class FisheyeTypoQuad extends FisheyeQuad {
  String content;
  PGraphics tex;
  PFont font;
  float fontSize;
  color col;
  float z;
  float startAngle, angularWidth;
  int margin = 50;
  float[][][] texels;
  float myRadius;
  boolean debug = false;
  // int BILLBOARD_TYPE = 0;
  // int ARC_TYPE = 1;
  int myType;

  //TODO: set mirroring.
  //TODO: make a more intuitive BB constructor!


  FisheyeTypoQuad(PApplet p5, int theType, String content, PFont font, float fontSize, color col, float z, float rad, float startAngle) {
    super(p5);
    myType = theType;
    this.content = content;
    this.font = font;
    this.fontSize = fontSize;
    this.col = col;
    this.z = z;
    this.startAngle = startAngle;
    p5.textFont(font, fontSize);
    int texW = ceil(p5.textWidth(content+2*margin));
    int texH = ceil(p5.textAscent() + p5.textDescent() + 2*margin);
    setRes(texW, texH);
    initTex(texW, texH);
    myRadius = rad;
    setAngularWidth(TWO_PI*texW/(TWO_PI*myRadius)); //you could simplify by TWO_PI ;))
    switch(myType) {
    case BILLBOARD_TYPE:
      initBillboardVertices();
      break;
    case ARC_TYPE:
      initArcVertices();
      break;
    }
  }

  void initTex(int texW, int texH) {
    tex = createGraphics(texW, texH, JAVA2D);
    texels = new float[hRes+1][vRes+1][2];

    tex.beginDraw();
    if (debug) {
      tex.background(255, 0, 0);
    } 
    else {
      tex.background(0, 0);
    }
    tex.noStroke();
    tex.fill(col);
    tex.textFont(font, fontSize);
    tex.text(content, margin, margin+tex.textAscent());
    tex.endDraw();
    for (int i = 0; i < hRes+1; i++) {
      for (int j = 0; j < vRes+1; j++) {
        texels[i][j][0] = (i/(hRes+1f)) * tex.width;
        texels[i][j][1] = (1f - j/(vRes+1f))*tex.height;
      }
    }
  }

  void initBillboardVertices() {
    float w = tex.width;
    float h = tex.height;

    float x0 = p5.width*0.5f;
    float y0 = myRadius;

    PVector v0 = new PVector(x0-w*0.5f, y0, z- h*0.5f);
    PVector v1 = new PVector(x0+w*0.5f, y0, z- h*0.5f);
    PVector v2 = new PVector(x0+w*0.5f, y0, z+ h*0.5f);
    PVector v3 = new PVector(x0-w*0.5f, y0, z+ h*0.5f);
    initVertices(new PVector[] {
      v0, v1, v2, v3
    }
    );
    this.rotateZ(startAngle);
  }

  void initArcVertices() {
    vertices = new float[hRes+1][vRes+1][3];
    fisheyeVertices = new float[hRes+1][vRes+1][3];
    float angInc = angularWidth/float(hRes);
    float zInc = tex.height/float(vRes);
    float myHInc = 1f/float(hRes);
    float myVInc = 1f/float(vRes);
    for (int i = 0; i < hRes+1; i++) {
      for (int j = 0; j < vRes+1; j++) {
        vertices[i][j][0] = myRadius*cos(startAngle - angInc*i) + worldOrigin.x;
        vertices[i][j][1] = myRadius*sin(startAngle - angInc*i) + worldOrigin.y;
        vertices[i][j][2] = z + zInc*j;
        fisheyeVertices[i][j] = vertexToFisheyeVertex(vertices[i][j]);
      }
    }
    float x = (vertices[floor((hRes+1)/2f)][floor((vRes+1)/2f)][0] + vertices[ceil((hRes+1)/2f)][floor((vRes+1)/2f)][0])*0.5f;
    float y = (vertices[floor((hRes+1)/2f)][floor((vRes+1)/2f)][1] + vertices[ceil((hRes+1)/2f)][floor((vRes+1)/2f)][1])*0.5f;
    float z = (vertices[floor((hRes+1)/2f)][floor((vRes+1)/2f)][2] + vertices[ceil((hRes+1)/2f)][floor((vRes+1)/2f)][2])*0.5f;
    selfOrigin = new PVector(x,y,z);
  }

  @Override
    void display() {
    if (debug) {
      p5.stroke(255);
    } 
    else {
      p5.noStroke();
    }
    //p5.noStroke();
    for (int j = 0; j < vRes; j++) {
      p5.beginShape(QUAD_STRIP);
      p5.texture(tex);
      for (int i = 0; i < hRes+1; i++) {
        drawTexturedVertexF(p5, fisheyeVertices[i][j], displayZ, texels[i][j]);
        drawTexturedVertexF(p5, fisheyeVertices[i][j+1], displayZ, texels[i][j+1]);
      }
      p5.endShape();
    }
  }

  void setRadius(float theRadius) {
    float delta = theRadius-myRadius;
    myRadius = theRadius;
    switch(myType) {
    case BILLBOARD_TYPE:
      this.translate(sqrt(2)*delta, sqrt(2)*delta, 0);
      break;
    case ARC_TYPE:
      setAngularWidth(TWO_PI*tex.width/(TWO_PI*myRadius)); //you could simplify by TWO_PI ;))
      initArcVertices();
      break;
    }
  }

  void incRadius(float dr) {
    setRadius(myRadius+dr);
  }

  float getAngularWidth() {
    return angularWidth;
  }

  void setAngularWidth(float theAngularWidth) {
    angularWidth = theAngularWidth;
  }

  @Override
    void rotateZ(float phi) {
    startAngle += phi;
    super.rotateZ(phi);
  }
}

