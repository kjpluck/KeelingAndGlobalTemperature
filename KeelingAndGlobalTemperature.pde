import com.hamoid.*;

VideoExport videoExport;

FloatDict _co2Data = new FloatDict();
FloatDict _temperatureData = new FloatDict();

color _coolColour = color(12, 182, 190);//color(75, 104, 166);
color _mediColour = color(252, 211, 127);
color _warmColour = color(221, 21, 58);
color _lowColour = color(12, 182, 190);
color _highColour = color(193,97,9);
public void setup()
{
  size(1920, 1060, P3D);
  loadCo2Data();
  loadTemperatureData();

  float fov = PI/6;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, float(width)/float(height), cameraZ/10.0, cameraZ*10.0);
  camera(width/2, height/2 - 500, 3000, width/2, height/2, 0, 0, 1, 0);

  textAlign(CENTER);
  textSize(64);
  strokeWeight(4);
  fill(235, 250, 254);
  noStroke();
  
  videoExport = new VideoExport(this);
  videoExport.setFrameRate(60);
  videoExport.startMovie();
}

float co2Scale = 15;
float co2YPos = -500;
float tempScale = 1000;
float tempPos = -100;
int pauseFrameCount = 300;

public void draw() {

  background(25, 41, 64);
  stroke(235, 250, 254);
  int maxD = frameCount;
  Data lastData = new Data();
  float lastX = 0.0;
  float lastZ = 0.0;
  int year=1958;
  float currentMaxCo2 = 312;
  float currentMaxTemp = -0.81;

  for (int d=1; d<=maxD; d++)
  {

    year = 1958 + d / 12;


    String month = nf(d % 12 + 1, 2);
    String date = year + "/" + month;

    Data data = getData(date);
    if (!data.hasData)
      continue;

    if(data.co2 > currentMaxCo2)
      currentMaxCo2 = data.co2;
    if(data.temperature > currentMaxTemp)
      currentMaxTemp = data.temperature;

    float r = (2*PI * d/12.0) - frameCount/200.0;
    float x = (float) Math.sin(r) * 600;
    float z = (float) Math.cos(r) * 600;

    if (!lastData.hasData) 
    {
      lastData = new Data(data.temperature, data.co2);
      lastX = x;
      lastZ = z;
    }


    pushMatrix();
      translate( width/8, 1000, -1000 );
      renderScales();
      pushStyle();
        color lerpColour = lerpColor(_lowColour, _highColour, (data.co2 - 300)/100);
        stroke(lerpColour);
        line(x, -(data.co2 - 300) * co2Scale - co2YPos, z, lastX, -(lastData.co2 - 300) * co2Scale - co2YPos, lastZ);
      popStyle();
    popMatrix();
    
    pushMatrix();
      translate( 7*width/8, 1000, -1000 );
      renderScales();
      pushStyle();
        float range = (data.temperature - -0.81) / (1.34 - -0.81);
        lerpColour = color(0);
        if(range < 0.5) lerpColour = lerpColor(_coolColour, _mediColour, range / 0.5);
        if(range >= 0.5) lerpColour = lerpColor(_mediColour, _warmColour, (range-0.5) / 0.5);
        stroke(lerpColour);
        line(x, -data.temperature * tempScale - tempPos, z, lastX, -lastData.temperature * tempScale - tempPos, lastZ);
      popStyle();
    popMatrix();
    
    
    lastX = x;
    lastZ = z;
    lastData = new Data(data.temperature, data.co2);
  }

  pushStyle();
    textSize(80);
    pushMatrix();
      translate( width/8, 1000, -1000 );
      text("Atmospheric CO₂\nconcentration (ppm)", -200,-1000,-800);
      renderScales();
    popMatrix();
  
    pushMatrix();
      translate( 7*width/8, 1000, -1000 );
      text("Global mean land-ocean\ntemperature (°C)\n deviation from 1951-1980 mean", 160,-1000,-800);
      renderScales();
    popMatrix();
  popStyle();
  
  if (year > 2017) 
  {
    year = 2017;
    pauseFrameCount--;
  }
  
  
  text(year, width/2, 100);
  text("@kevpluck", width/2,1600,-1000);
  pushStyle();
    textSize(40);
    text("GISS Surface Temperature Analysis (GISTEMP). NASA Goddard Institute for Space Studies.\nScripps CO₂ Program 2017", width/2, 1750, -1000);
  popStyle();
  renderCo2ScaleUpTo(currentMaxCo2);
  renderTemperatureScaleUpTo(currentMaxTemp);
  
  videoExport.saveFrame();
  if(pauseFrameCount < 0)
  {
    videoExport.endMovie();
    exit();
  }
}


public void renderCo2ScaleUpTo(float maxCo2)
{
  pushMatrix();
    translate(width/8 - 800, 1000, -1000 );
    for(int co2ppm = 300; co2ppm <= maxCo2; co2ppm+=10)
      text(co2ppm,0, -(co2ppm - 300) * co2Scale - co2YPos, 0);
  popMatrix();
}


public void renderTemperatureScaleUpTo(float maxTemp)
{
  pushStyle();
  textAlign(RIGHT);
  pushMatrix();
    translate(7*width/8 + 850, 1000, -1000 );
    for(float temp = -0.40; temp <= maxTemp; temp+=0.1)
    {
      String textTemp = nf(temp,1,1);
      if(textTemp.equals("-0.0")) textTemp = "0.0";
      text(textTemp+"°",0, -temp * tempScale - tempPos, 0);
    }
  popMatrix();
  popStyle();
}

public void renderScales()
{
  pushStyle();
  textSize(95);
  pushMatrix();
  translate(0,200,0); 
  rotateX(PI/2);
  //text("January",0,600,0);
  rotateZ(frameCount/200.0);
  text("Jan", 0, 600, -200);
  rotateZ(-PI/6);
  text("Feb", 0, 600, -200);
  rotateZ(-PI/6);
  text("Mar", 0, 600, -200);
  rotateZ(-PI/6);
  text("Apr", 0, 600, -200);
  rotateZ(-PI/6);
  text("May", 0, 600, -200);
  rotateZ(-PI/6);
  text("Jun", 0, 600, -200);
  rotateZ(-PI/6);
  text("Jul", 0, 600, -200);
  rotateZ(-PI/6);
  text("Aug", 0, 600, -200);
  rotateZ(-PI/6);
  text("Sep", 0, 600, -200);
  rotateZ(-PI/6);
  text("Oct", 0, 600, -200);
  rotateZ(-PI/6);
  text("Nov", 0, 600, -200);
  rotateZ(-PI/6);
  text("Dec", 0, 600, -200);

  popMatrix();
  popStyle();
}

class Data
{
  Data() {
  }
  Data(float temperature, float co2)
  {
    this.temperature = temperature;
    this.co2 = co2;
    this.hasData = true;
  }
  public boolean hasData = false;
  public float temperature;
  public float co2;
}

Data getData(String date)
{
  if (!_temperatureData.hasKey(date) || !_co2Data.hasKey(date))
    return new Data();

  float temperature = _temperatureData.get(date);
  float co2  = _co2Data.get(date);
  
  if(co2 < 100) 
    return new Data();
  
  return new Data(temperature, co2);
}

void loadCo2Data()
{
  String[] lines = loadStrings("monthly_in_situ_co2_mlo.csv");

  for (String line : lines)
  {
    if (line.charAt(0) == '"' || line.charAt(0) == ' ') continue;

    String[] values = split(line, ',');
    String year = trim(values[0]);
    String month = trim(values[1]);
    String date = year+"/"+month;
    float value = parseFloat(values[8]);
    _co2Data.set(date, value);
  }
}

void loadTemperatureData()
{

  String[] lines = loadStrings("GLB.Ts+dSST.csv");

  for (String line : lines) 
  {
    if (line.charAt(0)=='L' || line.charAt(0) == 'Y') continue;

    String[] values = split(line, ',');
    String year = values[0];
    for (int month = 1; month <= 12; month++)
    {
      float temperature = parseFloat(values[month]);
      String date = year + "/" + nf(month, 2);
      _temperatureData.set(date, temperature);
    }
  }
}