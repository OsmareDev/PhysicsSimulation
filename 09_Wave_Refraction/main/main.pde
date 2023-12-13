 //<>//
import peasy.*;

final int MAP_CELLS = 90;
final float MAP_CELL_SIZE = 10;

final float max = (MAP_CELLS * MAP_CELL_SIZE)/2;

final PVector rendija1 = new PVector(-max+200,0,(int)MAP_CELLS/2);
final PVector rendija2 = new PVector(max-200,0,(int)MAP_CELLS/2);
// at 100 the size of the grating will be the same as the wavelength and it will be a total refraction
// if the fence is smaller the wave will not be able to pass
final float _TAM_REJA = 100;

// DISPLAY STUFF
final boolean FULL_SCREEN = false;
final int DRAW_FREQ = 50;   // Draw frequency (Hz or Frame-per-second)
int DISPLAY_SIZE_X = 1000;   // Display width (pixels)
int DISPLAY_SIZE_Y = 1000;   // Display height (pixels)

final float FOV = 60;   // Field of view (º)
final float NEAR = 0.01;   // Camera near distance (m)
final float FAR = 100000.0;   // Camera far distance (m)

final color BACKGROUND_COLOR = color(220, 240, 220);   // Background color (RGB)

PeasyCam _camera;   // mouse-driven 3D camera
PImage img;

// Time control:

int _lastTimeDraw = 0;   // Last measure of time in draw() function (ms)
float _deltaTimeDraw = 0.0;   // Time between draw() calls (s)
float _simTime = 0.0;   // Simulated time (s)
float _elapsedTime = 0.0;   // Elapsed (real) time (s)
float SIM_STEP = 0.01;

HeightMap _mapa;   // Deformable mesh

Boolean w_tex = false;

void initSimulation()
{
  _simTime = 0.0;
  _elapsedTime = 0.0;
  _mapa = new HeightMap(MAP_CELL_SIZE, MAP_CELLS);
}

void settings()
{
  if (FULL_SCREEN)
  {
    fullScreen(P3D);
    DISPLAY_SIZE_X = displayWidth;
    DISPLAY_SIZE_Y = displayHeight;
  } 
  else
  {
    size(DISPLAY_SIZE_X, DISPLAY_SIZE_Y, P3D);
  }
}

void setup()
{
  frameRate(DRAW_FREQ);
  _lastTimeDraw = millis();
  
  float aspect = float(DISPLAY_SIZE_X)/float(DISPLAY_SIZE_Y);  
  perspective((FOV*PI)/180, aspect, NEAR, FAR);
  _camera = new PeasyCam(this, 0);
  img = loadImage("ocean.jpg");

  initSimulation();
}

void draw(){
  int now = millis();
  _deltaTimeDraw = (now - _lastTimeDraw)/1000.0;
  _elapsedTime += _deltaTimeDraw;
  _lastTimeDraw = now;
  
  background(BACKGROUND_COLOR);
  
  if (w_tex)
    _mapa.displayTextured();
  else
    _mapa.display();
  
  _mapa.update();
  printInfo();
}

void printInfo()
{
  pushMatrix();
  {
    camera();
    fill(0);
    textSize(20);
    
    text("r - añadir onda radial", width*0.025, height*0.05);
    text("d - añadir onda direccional", width*0.025, height*0.075);
    text("h - añadir onda de Gerstner", width*0.025, height*0.1);
    text("m - resetear ondas", width*0.025, height*0.125);
    text("t - poner/quitar textura", width*0.025, height*0.15);
    text("refraccion de las ondas radiales, cuando la reja y la longitud de onda son iguales la refraccion es total", width*0.025, height*0.2);
    text("con refraccion total se simula el efecto de doble rendija", width*0.025, height*0.225);
  }
  popMatrix();
}

void keyPressed()
{
  if (key == 's')
  {
    _mapa.addWave(10, 1, 100, new PVector(random(-1,1), 0, random(-1,1)), 1);
  }
  if (key == 'r')
  {
    _mapa.addWave(5, 1, 100, new PVector(0, 0, max), 2);
  }
  if (key == 'h'){
    _mapa.addWave(10, 1, 100, new PVector(random(-450,450), 0, random(-450, 450)), 3);
  }
  if (key == 'm')
  {
    _mapa.reset();
  }
  if (key == 't')
  {
    w_tex = !w_tex;
  }
  if (key == 'l')
  {
    _mapa.addWave(10, 1, 100, new PVector(max, 0, max), 2);
    _mapa.addWave(10, 1, 100, new PVector(max, 0, -max), 2);
    _mapa.addWave(10, 1, 100, new PVector(-max, 0, max), 2);
    _mapa.addWave(10, 1, 100, new PVector(-max, 0, -max), 2);
  }
}
