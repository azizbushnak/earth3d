import http.requests.*;
import java.util.Comparator;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.ParsePosition;
import java.lang.Math;

PImage earth_texture;
PShape earth;
PVector[] strikeCoords;
float[] strikeImpact;
int numMeteorites;
int meteorNum;

float radius = 30;

import peasy.*;

float[] lastPosition = new float[3];
boolean drawMeteorites = false;
float drawIndex = 0;

PeasyCam cam;

void setup() {
  //  frameRate(10);
  size(600, 600, P3D);
  background(0);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(25);
  cam.setMaximumDistance(300);

  lastPosition = new float[] {0, 0, 0}; 

  float cameraZ = ((height/2.0) / tan(PI*60.0/360.0));
  perspective(PI/3.0, width/height, cameraZ/3000.0, cameraZ*10.0);

  stroke(0);
  strokeWeight(0);
  earth = createShape(SPHERE, radius);
  earth_texture = loadImage("Albedo.jpg");
  earth.setTexture(earth_texture);  

  ArrayList<Element> elementList = GetMeteorElements();
}

void draw() {
   
  float[] currentPos = cam.getPosition();
  
  if(currentPos[0] == lastPosition[0] && currentPos[1] == lastPosition[1] && currentPos[2] == lastPosition[2]){
      drawMeteorites = true;
      
        
  } else {
    drawMeteorites = false; 
  }

  meteorNum = int(frameCount/60) % numMeteorites;
  lastPosition = cam.getPosition();
  
  
 if(!drawMeteorites){
    
    background(0);
    drawIndex = 0;
    fill(0, 255, 0);
    box(0.2, 85, 0.2);
    
    fill(255, 0, 0);
    box(0.2, 0.2, 85);
   
    fill(0, 0, 255);
    box(85, 0.2, 0.2);
  
    fill(255, 0, 0);
    shape(earth);
  } else {
    /*if(drawIndex < strikeCoords.length){
      for (int i = 0; i <= drawIndex - 1; i++) {
          pushMatrix();
          translate(-strikeCoords[i].x, -strikeCoords[i].z, strikeCoords[i].y);
          sphere(log(strikeImpact[i]));
          popMatrix();
        drawIndex++;
      } */
      for (int i = 0; i < strikeCoords.length; i++) {
        if(strikeCoords[i] != null){
          pushMatrix();
          translate(-strikeCoords[i].x, -strikeCoords[i].z, strikeCoords[i].y);
          sphere(log(strikeImpact[i]) / 10);
          popMatrix();         
        }
      }
    }  
  
  /*background(0);

  box(0.2, 85, 0.2);

  fill(255, 0, 0);
  shape(earth);

  meteorNum = int(frameCount/60) % numMeteorites;

  pushMatrix();
  translate(-strikeCoords[meteorNum].x, -strikeCoords[meteorNum].z, strikeCoords[meteorNum].y);
  sphere(log(strikeImpact[meteorNum]));
  popMatrix(); */
} 


PVector get_latlong_xyz(float latitude, float longitude) {

  latitude = radians(latitude);
  longitude = radians(longitude);

  PVector coords = new PVector(0, 0, 0);
  coords.x = radius * cos(latitude) * cos(longitude);
  coords.y = radius * cos(latitude) * sin(longitude);
  coords.z = radius * sin(latitude);

  return coords;
}

ArrayList<Element> GetMeteorElements() {
  ArrayList<Element> meteorHitArrayList = new ArrayList<Element>();

  GetRequest getRequest = new GetRequest("https://data.nasa.gov/resource/gh4g-9sfh.json");
  getRequest.send();
  JSONArray jsonBlob = JSONArray.parse(getRequest.getContent());

  numMeteorites = jsonBlob.size();
  strikeCoords = new PVector[numMeteorites];
  strikeImpact = new float[numMeteorites];
  float meteorImpact = 1.0;

  for (int i = 0; i < numMeteorites; i++) {
    JSONObject meteorHit = jsonBlob.getJSONObject(i);
    JSONObject meteorHitGeoLocation = meteorHit.getJSONObject("geolocation");
    String meteorMass = meteorHit.getString("mass");

    if (meteorHitGeoLocation != null) {
      if (meteorMass != null && meteorMass != "") {
        meteorImpact = float(meteorMass)/10000.0;
      } else {
        meteorImpact = 1.0;
      }
      meteorHitArrayList.add(new Element(
        meteorHitGeoLocation.getFloat("latitude"), 
        meteorHitGeoLocation.getFloat("longitude"), 
        meteorHit.getString("year"), 
        meteorImpact)
        );
        
      if(i < meteorHitArrayList.size()){
        strikeCoords[i] = get_latlong_xyz(meteorHitArrayList.get(i).latitude, meteorHitArrayList.get(i).longitude);
        strikeImpact[i] = meteorHitArrayList.get(i).mass;
      }
    }
  }  

  meteorHitArrayList.sort(new ElementComparator());

  return meteorHitArrayList;
}

class Element {
  public float latitude;
  public float longitude;
  public Date timestamp;
  public float mass;

  public Element(float _latitude, float _longitude, String _timestamp, float _mass) {
    SimpleDateFormat df = new SimpleDateFormat( "yyyy-MM-dd'T'HH:mm:ss" );

    latitude = _latitude; 
    longitude = _longitude;
    timestamp = df.parse(_timestamp, new ParsePosition(0));
    mass = _mass;
  }
}

public class ElementComparator implements Comparator<Element> {
  @Override
    public int compare(Element o1, Element o2) {      
    return o1.timestamp.compareTo(o2.timestamp);
  }
}
