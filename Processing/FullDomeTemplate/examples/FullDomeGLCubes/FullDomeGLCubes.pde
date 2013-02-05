/**
 * Created with IntelliJ IDEA.
 * User: marcTiedemann
 * Date: 19.12.12
 * Time: 21:05
 * To change this template use File | Settings | File Templates.
 */


    /**
     * this project uses an fbo to write into cubemap txtures dynamically
     * use wasd or arrow cursors to navigate, use mouse to move the cursor
     * you can press the mouse to zoom in as well
     *
     * draw everything into the 'drawScene' function, instead of draw.
     *
     * Author: Christopher Warnow, 2010, ch.warnow@gmx.de
     */

import codeanticode.glgraphics.*;
import com.sun.opengl.util.GLUT;
import processing.opengl.*;

import javax.media.opengl.GL;
import javax.media.opengl.glu.GLU;



    GLGraphics pgl;
    GL gl;
    GLU glu;
    GLUT glut;
    PVector mouseP;
    float globalZoom = 0;

    PVector mousePos;
    float mouseSpeed = .2f;
    float globalX = 0;
    float globalZ = 100;
    float destGlobalX = 0;
    float destGlobalZ = 350;

     CubeMapUtilsCubes cubeMapUtils;


    int cubeCount = 1500;
    float cubeSize = 10;
    float volSize = 1000;

    GLModel cubes;
    GLModel xcubes;
    
    boolean moveUp = true;
    float cubePos=1;

  boolean pauseAnimation = false;

   public void setup() {
        size(screen.height, screen.height,  GLConstants.GLGRAPHICS);
        mousePos = new PVector(width*.5f, height*.5f, 0);
        glut = new GLUT();
        glu = new GLU();
        pgl = (GLGraphics) g;

        gl = pgl.gl;

        cubeMapUtils = new CubeMapUtilsCubes(this);


        noCursor();
       initScene();
    }



    void initScene(){
        createCubes();

    }



    /*
    * draw everything here
    * this scene is called 6 times for the cubemap
    */
   public void drawScene() {
        background(0,0,20);



      pgl.pushMatrix();
      
      if(!pauseAnimation){
      if(moveUp)cubePos*=1.005;
      else cubePos*=0.995f;
      if (cubePos >2000) moveUp=false;
      if (cubePos<10) moveUp=true;
      }

       pgl.translate(0,0, globalZ+cubePos);
       
       pgl.rotateY(frameCount * 0.001f);
       pgl.rotateX(frameCount * 0.002f);
       pgl.rotateZ(frameCount * 0.003f);
       


       pgl.model(cubes);

       pgl.popMatrix();

    
       pgl.pushMatrix();

       pgl.translate(globalX, 0, globalZ);

        // cursorBox
       pgl.strokeWeight(10);
       pgl.noFill();
       pgl.stroke(255);

       pgl.pushMatrix();

       pgl.translate(-mouseP.x, -mouseP.y, mouseP.z-190);
       pgl.box(5);
       pgl.strokeWeight(10);

       int lineSize = 1500;

       pgl.stroke(55);

       pgl.line(-lineSize,0,0,lineSize,0,0);
       pgl.line(0,-lineSize,0,0,lineSize,0);


       pgl.line(0,0,-10,0,0,lineSize);

       pgl.stroke(55,70);
     //  pgl.fill(0,70,55,70);

       pgl.sphereDetail(10);
       pgl.sphere(6);

       pgl.popMatrix();


   }

   public void draw() {

        println(frameRate);
        // main position
        globalX += (destGlobalX - globalX)*.25;
        globalZ += (destGlobalZ - globalZ)*.25;

        background(0, 0, 0);
        if(mousePressed) destGlobalZ += 3;

        mousePos.x += (mouseX - mousePos.x) * mouseSpeed;
        mousePos.y += (mouseY - mousePos.y) * mouseSpeed;
        mouseP = new PVector(-mousePos.x + width*.5f, mousePos.y - height*.5f, 0);


       // if we need to change the box model verticies we should do this here and not in drawscene

       pgl.beginGL();


       //let's use some fog for a better 3d feeling
       gl.glEnable(gl.GL_FOG);
       gl.glFogi(gl.GL_FOG_MODE, gl.GL_LINEAR); 
       gl.glFogf(gl.GL_FOG_START, 350);
       gl.glFogf(gl.GL_FOG_END, 1000.f);

            
       cubeMapUtils.drawCubeMap();
       pgl.endGL();

    }

   public void keyPressed() {
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
        
         if(key == ' ' ) {
            pauseAnimation = !pauseAnimation;
        }
    }


    void createCubes() {
        cubes = new GLModel(this, 24 * cubeCount, QUADS, GLModel.STATIC);
        cubes.beginUpdateVertices();
        for (int i = 0; i < cubeCount; i++) {
            int n0 = 24 * i;
            float x0 = random(-volSize, +volSize);
            float y0 = random(-volSize, +volSize);
            float z0 = random(-volSize, +volSize);
            // Front face
            cubes.updateVertex(n0 + 0, x0 - cubeSize, y0 - cubeSize, z0 + cubeSize);
            cubes.updateVertex(n0 + 1, x0 + cubeSize, y0 - cubeSize, z0 + cubeSize);
            cubes.updateVertex(n0 + 2, x0 + cubeSize, y0 + cubeSize, z0 + cubeSize);
            cubes.updateVertex(n0 + 3, x0 - cubeSize, y0 + cubeSize, z0 + cubeSize);
            // Back face
            cubes.updateVertex(n0 + 4, x0 - cubeSize, y0 - cubeSize, z0 - cubeSize);
            cubes.updateVertex(n0 + 5, x0 + cubeSize, y0 - cubeSize, z0 - cubeSize);
            cubes.updateVertex(n0 + 6, x0 + cubeSize, y0 + cubeSize, z0 - cubeSize);
            cubes.updateVertex(n0 + 7, x0 - cubeSize, y0 + cubeSize, z0 - cubeSize);
            // Rigth face
            cubes.updateVertex(n0 + 8, x0 + cubeSize, y0 - cubeSize, z0 + cubeSize);
            cubes.updateVertex(n0 + 9, x0 + cubeSize, y0 - cubeSize, z0 - cubeSize);
            cubes.updateVertex(n0 + 10, x0 + cubeSize, y0 + cubeSize, z0 - cubeSize);
            cubes.updateVertex(n0 + 11, x0 + cubeSize, y0 + cubeSize, z0 + cubeSize);
            // Left face
            cubes.updateVertex(n0 + 12, x0 - cubeSize, y0 - cubeSize, z0 + cubeSize);
            cubes.updateVertex(n0 + 13, x0 - cubeSize, y0 - cubeSize, z0 - cubeSize);
            cubes.updateVertex(n0 + 14, x0 - cubeSize, y0 + cubeSize, z0 - cubeSize);
            cubes.updateVertex(n0 + 15, x0 - cubeSize, y0 + cubeSize, z0 + cubeSize);
            // Top face
            cubes.updateVertex(n0 + 16, x0 + cubeSize, y0 + cubeSize, z0 + cubeSize);
            cubes.updateVertex(n0 + 17, x0 + cubeSize, y0 + cubeSize, z0 - cubeSize);
            cubes.updateVertex(n0 + 18, x0 - cubeSize, y0 + cubeSize, z0 - cubeSize);
            cubes.updateVertex(n0 + 19, x0 - cubeSize, y0 + cubeSize, z0 + cubeSize);
            // Bottom face
            cubes.updateVertex(n0 + 20, x0 + cubeSize, y0 - cubeSize, z0 + cubeSize);
            cubes.updateVertex(n0 + 21, x0 + cubeSize, y0 - cubeSize, z0 - cubeSize);
            cubes.updateVertex(n0 + 22, x0 - cubeSize, y0 - cubeSize, z0 - cubeSize);
            cubes.updateVertex(n0 + 23, x0 - cubeSize, y0 - cubeSize, z0 + cubeSize);
        }
        cubes.endUpdateVertices();

        cubes.initColors();
        cubes.setColors(200,0,250, 200);
        cubes.setBlendMode(BLEND);
    }



