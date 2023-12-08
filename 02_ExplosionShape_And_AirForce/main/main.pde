enum RocketType 
{
  ALEATORIO
}

final int NUM_ROCKET_TYPES = RocketType.values().length;

enum ParticleType 
{
  CASING,
  REGULAR_PARTICLE 
}

// Particle control:

FireWorks _fw;   // Main object of the program
int _numParticles = 0;   // Number of particles of the simulation
final int N_ROCKETS = 50;

// Problem variables:

final float Gc = 9.801;   // Gravity constant (m/(s*s))
final PVector G = new PVector(0.0, Gc);   // Acceleration due to gravity (m/(s*s))
PVector _windVelocity = new PVector(10.0, 0.0);   // Wind velocity (m/s)
final float WIND_CONSTANT = 1.0;   // Constant to convert apparent wind speed into wind force (Kg/s)
Boolean windMoving = false;

// Display values:

PrintWriter _output;
final boolean FULL_SCREEN = false;
final int DRAW_FREQ = 50;   // Draw frequency (Hz or Frame-per-second)
int DISPLAY_SIZE_X = 1000;   // Display width (pixels)
int DISPLAY_SIZE_Y = 1000;   // Display height (pixels)
final int [] BACKGROUND_COLOR = {10, 10, 25};

// Time control:

int _lastTimeDraw = 0;   // Last measure of time in draw() function (ms)
float _deltaTimeDraw = 0.0;   // Time between draw() calls (s)
float _simTime = 0.0;   // Simulated time (s)
float _elapsedTime = 0.0;   // Elapsed (real) time (s)
final float SIM_STEP = 0.1;   // Simulation step (s)

void settings()
{
  if (FULL_SCREEN)
  {
    fullScreen();
    DISPLAY_SIZE_X = displayWidth;
    DISPLAY_SIZE_Y = displayHeight;
  } 
  else
    size(DISPLAY_SIZE_X, DISPLAY_SIZE_Y);
}

void setup()
{
  frameRate(DRAW_FREQ);
  _lastTimeDraw = millis();

  _fw = new FireWorks();
  _numParticles = 0;

  _output = createWriter("data.csv");
  _output.println("tiempo,paso,n_part");
}

void printInfo()
{ 
  fill(255);
  text("Number of particles : " + _numParticles, width*0.025, height*0.05);
  text("Frame rate = " + 1.0/_deltaTimeDraw + " fps", width*0.025, height*0.075);
  text("Elapsed time = " + _elapsedTime + " s", width*0.025 , height*0.1);
  text("Simulated time = " + _simTime + " s ", width*0.025, height*0.125);
  text("Manten 'flecha arriba' y mueve el raton para cambiar la direccion y fuerza del viento", width*0.025, height*0.15);
  text("Pulsa 'TAB' para lanzar " + N_ROCKETS + " particulas", width*0.525, height*0.15);
}

void drawWind()
{
  // Código para dibujar el vector que representa el viento
  stroke(255);
  PVector dir = _windVelocity.copy();
  dir.normalize();
  PVector arrow = dir.copy();
  line(width/2, height/2, (width/2)+_windVelocity.x, (height/2)+_windVelocity.y);
  arrow.rotate(radians(45));
  line((width/2)+_windVelocity.x, (height/2)+_windVelocity.y, (width/2)+_windVelocity.x-arrow.x*5, (height/2)+_windVelocity.y-arrow.y*5);
  arrow.rotate(radians(-90));
  line((width/2)+_windVelocity.x, (height/2)+_windVelocity.y, (width/2)+_windVelocity.x-arrow.x*5, (height/2)+_windVelocity.y-arrow.y*5);
  stroke(0);
}

void draw()
{
  int now = millis();
  _deltaTimeDraw = (now - _lastTimeDraw)/1000.0;
  _elapsedTime += _deltaTimeDraw;
  _lastTimeDraw = now;

  //background(BACKGROUND_COLOR[0], BACKGROUND_COLOR[1], BACKGROUND_COLOR[2]);
  fill(BACKGROUND_COLOR[0], BACKGROUND_COLOR[1], BACKGROUND_COLOR[2], 50);
  rect(0, 0, width, height);
  fill(0);
  rect(0,0, width, height*0.15);
  
  _fw.run();
  printInfo();  
  drawWind();
  printFile();
}

void mousePressed()
{
  PVector pos = new PVector(mouseX, mouseY);
  PVector vel = new PVector((pos.x - width/2), (pos.y - height)).setMag(200);
  color c = color(random(255),random(255),random(255));

  int type = (int)(random(NUM_ROCKET_TYPES)); 
  _fw.addRocket(RocketType.values()[type], new PVector(width/2, height), vel, c);
}


void printFile(){
  // VARS:
  //tiempo _elapsedTime
  //numero de particulas
  //deltaTimeDraw
  _output.println(_elapsedTime + "," +_deltaTimeDraw + "," + _numParticles);
}

void keyPressed()
{
  if (keyCode == UP) {
    windMoving = true;
  } 
  if (keyCode == TAB) {
    for (int i = 0; i < N_ROCKETS; i++) {
      PVector pos = new PVector(mouseX+random(0,200), mouseY+random(0,200));
      PVector vel = new PVector((pos.x - width/2), (pos.y - height)).setMag(200);
      color c = color(random(255),random(255),random(255));
    
      int type = (int)(random(NUM_ROCKET_TYPES)); 
      _fw.addRocket(RocketType.values()[type], new PVector(width/2, height), vel, c);
    }
  }

  if (key == 'e'){
    _output.flush(); // Writes the remaining data to the file 
    _output.close(); // Finishes the file 
    exit(); // Stops the program 
  }
}

void mouseMoved()
{
    if (windMoving) {
      PVector dir = new PVector(mouseX-(width/2), mouseY-(height/2));
      _windVelocity = dir.copy();
    } 
}

void keyReleased()
{
  windMoving = false;
}
