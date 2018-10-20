PImage earth_texture;
PImage moon_texture;

PShape earth;
PShape moon;

float radius = 30;

import peasy.*;

PeasyCam cam;

void setup() {
  size(800,800,P3D);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(35);
  cam.setMaximumDistance(300);
  
  float cameraZ = ((height/2.0) / tan(PI*60.0/360.0));
  perspective(PI/3.0, width/height, cameraZ/3000.0, cameraZ*10.0);

  stroke(0);
  strokeWeight(0);
  earth = createShape(SPHERE, radius);
  earth_texture = loadImage("sphere_texture.jpg");
  earth.setTexture(earth_texture);  
}

void draw() {
  background(0);
  rotateX(-.5);
  rotateY(-.5);
  
  box(0.2, 85, 0.2);

  fill(255,0,0);
  shape(earth);
  /*
  cam.beginHUD();
  translate(width/2, height/2);
  fill(255);
  textSize(23);
  text(, 0, 0);
  cam.endHUD();
  */
  
} 
