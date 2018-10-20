import http.requests.*;

PImage earth_texture;
PShape earth;

float radius = 30;

import peasy.*;

PeasyCam cam;

void setup() {
  size(600,600,P3D);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(35);
  cam.setMaximumDistance(300);
  
  float cameraZ = ((height/2.0) / tan(PI*60.0/360.0));
  perspective(PI/3.0, width/height, cameraZ/3000.0, cameraZ*10.0);

  stroke(0);
  strokeWeight(0);
  earth = createShape(SPHERE, radius);
  earth_texture = loadImage("earth_flat_map.jpg");
  earth.setTexture(earth_texture);  
  
  ArrayList<Element> elementList = GetMeteorElements();
  
  for (int i = 0; i < elementList.size(); i++) {
    println(elementList.get(i).latitude + "-" + elementList.get(i).latitude + "-" + elementList.get(i).timestamp);
  }
}

void draw() {
  background(0);

  box(0.2, 85, 0.2);

  fill(255,0,0);
  shape(earth);
  PVector c = get_longlat_xyz(0, 0);
  translate(c.x, c.y, c.z);
  sphere(1);
} 


PVector get_longlat_xyz(float latitude, float longitude){
  
  latitude += 180;
  
  
  latitude = radians(latitude);
  longitude = radians(longitude);
  
  

  PVector coords = new PVector(0, 0, 0);
  coords.x = radius * cos(latitude) * cos(longitude);
  coords.y = radius * cos(latitude) * sin(longitude);
  coords.z = radius * sin(latitude);
  
  coords.z = -coords.z;
  
  return coords;
}

ArrayList<Element> GetMeteorElements(){
  ArrayList<Element> meteorHitArrayList = new ArrayList<Element>();
  
  GetRequest getRequest = new GetRequest("https://data.nasa.gov/resource/gh4g-9sfh.json");
  getRequest.send();
  JSONArray jsonBlob = JSONArray.parse(getRequest.getContent());
  
  for (int i = 0; i < jsonBlob.size(); i++) {
    JSONObject meteorHit = jsonBlob.getJSONObject(i);
    JSONObject meteorHitGeoLocation = meteorHit.getJSONObject("geolocation");
    
    if(meteorHitGeoLocation != null){
          meteorHitArrayList.add(new Element(
            meteorHitGeoLocation.getFloat("latitude"),
            meteorHitGeoLocation.getFloat("longitude"),
            meteorHit.getString("year"))
            );
    } 
  }  
  return meteorHitArrayList;
}

class Element{
 public float latitude;
 public float longitude;
 public String timestamp;
 
 public Element(float _latitude, float _longitude, String _timestamp){
   latitude = _latitude; 
   longitude = _longitude;
   timestamp = _timestamp;
 }
  
}
