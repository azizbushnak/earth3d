import http.requests.*;
import java.util.Comparator;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.ParsePosition;

PImage earth_texture;
PShape earth;
PVector[] strikeCoords;
int numMeteorites;
int meteorNum;

float radius = 30;

import peasy.*;

PeasyCam cam;

void setup() {
  //  frameRate(10);
  size(600, 600, P3D);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(25);
  cam.setMaximumDistance(300);

  float cameraZ = ((height/2.0) / tan(PI*60.0/360.0));
  perspective(PI/3.0, width/height, cameraZ/3000.0, cameraZ*10.0);

  stroke(0);
  strokeWeight(0);
  earth = createShape(SPHERE, radius);
  earth_texture = loadImage("Albedo.jpg");
  earth.setTexture(earth_texture);  

  ArrayList<Element> elementList = GetMeteorElements();
  numMeteorites = elementList.size();

  strikeCoords = new PVector[numMeteorites];
  for (int i = 0; i < numMeteorites; i++) {
    println(elementList.get(i).latitude + "-" + elementList.get(i).longitude + "-" + elementList.get(i).timestamp);
    strikeCoords[i] = get_latlong_xyz(elementList.get(i).latitude, elementList.get(i).longitude);
  }
}

void draw() {
  background(0);
  
  fill(0, 255, 0);
  box(0.2, 85, 0.2);
  
  fill(255, 0, 0);
  box(0.2, 0.2, 85);
 
  fill(0, 0, 255);
  box(85, 0.2, 0.2);

  fill(255, 0, 0);
  shape(earth);
  //  PVector c = get_latlong_xyz(40.7128, -74.0060); // New York
  //  PVector c = get_latlong_xyz(50.7184, -3.5339); // Exeter
  //  PVector c = get_latlong_xyz(0, 0); // Greenwich, Equator
  //  PVector c = get_latlong_xyz(0, 90); // ~Singapore
  //  PVector c = get_latlong_xyz(90, 0); // N Pole
  //  PVector c = get_latlong_xyz(-90, 0); // S Pole
  //  translate(-c.x, -c.z, c.y);
  //  sphere(1);

 meteorNum = int(frameCount/60) % numMeteorites;

  pushMatrix();
  translate(-strikeCoords[meteorNum].x, -strikeCoords[meteorNum].z, strikeCoords[meteorNum].y);
  sphere(1);
  popMatrix();
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

  for (int i = 0; i < jsonBlob.size(); i++) {
    JSONObject meteorHit = jsonBlob.getJSONObject(i);
    JSONObject meteorHitGeoLocation = meteorHit.getJSONObject("geolocation");

    if (meteorHitGeoLocation != null) {
      meteorHitArrayList.add(new Element(
        meteorHitGeoLocation.getFloat("latitude"), 
        meteorHitGeoLocation.getFloat("longitude"), 
        meteorHit.getString("year"))
        );
    }
  }  

  meteorHitArrayList.sort(new ElementComparator());

  return meteorHitArrayList;
}

class Element {
  public float latitude;
  public float longitude;
  public Date timestamp;

  public Element(float _latitude, float _longitude, String _timestamp) {
    SimpleDateFormat df = new SimpleDateFormat( "yyyy-MM-dd'T'HH:mm:ss" );

    latitude = _latitude; 
    longitude = _longitude;
    timestamp = df.parse(_timestamp, new ParsePosition(0));
  }
}

public class ElementComparator implements Comparator<Element> {
  @Override
    public int compare(Element o1, Element o2) {      
    return o1.timestamp.compareTo(o2.timestamp);
  }
}
