enum EstructuraDatos 
{
  NONE,
  GRID,
  HASH
}

EstructuraDatos type = EstructuraDatos.NONE;

PrintWriter _output;
Boolean MUESTRA = false;

// Grid
Grid grid;
int rows = 30;
int cols = 30;

//Hash
HashTable hash;

int frame; // Frame counter

final float Gc = 9.801;   // Gravity constant (m/(s*s))
final PVector G = new PVector(0.0, Gc);   // Acceleration due to gravity (m/(s*s))

ParticleSystem _system;   // Particle system
ArrayList<PlaneSection> _planes;    // Planes representing the limits
boolean _computePlaneCollisions = true;

// Time control:
int _lastTimeDraw = 0;   // Last measure of time in draw() function (ms)
float _deltaTimeDraw = 0.0;   // Time between draw() calls (s)
// float _deltaTime
float _simTime = 0.0;   // Simulated time (s)
float _elapsedTime = 0.0;   // Elapsed (real) time (s)
final float SIM_STEP = 0.05;   // Simulation step (s)

// for printing
float time_colisiones = 0.0;
float time_estructuras = 0.0;
float time_integracion = 0.0;
float time_draw_scene = 0.0;

// Display values:

String modelo_liquido = "GAS";
final boolean FULL_SCREEN = false;
final int DRAW_FREQ = 50;   // Draw frequency (Hz or Frame-per-second)
int DISPLAY_SIZE_X = 1500;   // Display width (pixels)
int DISPLAY_SIZE_Y = 1080;   // Display height (pixels)
final int BACKGROUND_COLOR = 5;

final int padding = 100;
final int padding_puerta = (DISPLAY_SIZE_X/2)-padding;
Boolean puerta = true;
final int r_part = 5;
final int n_part = 1600;
float m_part = 0.05;
float k = 0.4;
float ke = 1;
float k_pared = 0.1;
float L = r_part;    

Boolean shower = false;


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

  frame = 0;
}

void setup()
{
  initSimulation();
}

void initSimulation()
{
  _system = new ParticleSystem(n_part);
  _planes = new ArrayList<PlaneSection>();

  _planes.add(new PlaneSection(padding*2, padding, width-padding*2, padding, true)); //Up
  _planes.add(new PlaneSection(padding*2, padding, padding, padding*3,false)); //Left 1
  _planes.add(new PlaneSection(padding, padding*3, padding_puerta, height/2, false)); //Left 2
  _planes.add(new PlaneSection(width-padding*2, padding, width-padding, padding*3,true)); //Right 1
  _planes.add(new PlaneSection(width-padding, padding*3, width-padding_puerta, height/2, true)); //Right 2
  
  _planes.add(new PlaneSection(padding_puerta, height/2, padding_puerta+padding*2, height/2, false)); //Door
  
  _elapsedTime = 0.0;
  _simTime = 0.0;
  
  grid = new Grid(rows, cols); 
  hash = new HashTable(_system.getNumParticles()*2, width/rows);
  type = EstructuraDatos.HASH;
  transformLiquid();
  _output = createWriter("data.csv");
  _output.println("tiempo,paso,framerate,n_part,tiemposindraw,tiempocondraw");
}

void drawStaticEnvironment()
{
  //hacer que se pueda activar y desactivar
  grid.display();
  
  for(int i = 0; i < _planes.size(); i++)
  {
      _planes.get(i).draw();
  }
}


void drawInfo(){
  float padding = 40;
  float init_height = height * 0.5;
  float init_width = width * 0.035;
  float init_width2 = width * 0.7;
  // fps
  textSize(40);
  fill(0, 408, 612);
  text("Frame rate = " + 1.0/_deltaTimeDraw + " fps", init_width, init_height);
  // simulated time
  text("Simulated time = " + _simTime + " s ", init_width, init_height+padding*1);
  // particle number
  text("Num particle = " + _system._n, init_width, init_height+padding*2);
  // ms
  text("Delta time = " + _deltaTimeDraw + " ms", init_width, init_height+padding*3);
  // collision time
  text("Time colisiones = " + time_colisiones + " ms", init_width, init_height+padding*4);
  // structure time
  text("Time estructuras = " + time_estructuras + " ms", init_width, init_height+padding*5);
  // integration time
  text("Time integracion = " + time_integracion + " ms", init_width, init_height+padding*6);
  // draw time
  text("Time draw = " + time_draw_scene + " ms", init_width, init_height+padding*7);
  
  textSize(60);
  fill(0, 408, 612);
  text("Estruct: " + type, width/2-150, height/2+100);
  text("Tipo: " + modelo_liquido, width/2-150, height/2+180);

  // Commands
  textSize(40);
  fill(0, 408, 612);
  // Change Fluids (1, 2 and 3)
  // 1-GAS
  text("1 - GAS", init_width2, init_height+padding*0);
  // 2-LIQUID
  text("2 - LIQUID", init_width2, init_height+padding*1);
  // 3-SOLID
  text("3 - VISCOUS", init_width2, init_height+padding*2);

  // Remove/Place Door (p)
  text("p - Quitar/Poner plano", init_width2, init_height+padding*3);
  // Display Normal (n)
  text("n - Display Normal", init_width2, init_height+padding*4);
  // Display Grid (g)
  text("g - Display Grid", init_width2, init_height+padding*5);
  // Display Hash (h)
  text("h - Display Hash", init_width2, init_height+padding*6);
  // Add Particle (Click)
  text("Click - Añadir particula", init_width2, init_height+padding*7);
  
  text("m - mostrar/ocultar lineas grid", init_width2, init_height+padding*8);
}

void printInfo(){
  // framerate and number of particles per iteration
  float time_woutDraw = time_colisiones+time_integracion;
  float time_withDraw = time_woutDraw+time_draw_scene;
  _output.println(_elapsedTime + "," + SIM_STEP + "," + 1.0/_deltaTimeDraw + "," +_system._n + "," + time_woutDraw + "," + time_withDraw);
}

void draw() 
{
  background(BACKGROUND_COLOR);

  int now = millis();
  _deltaTimeDraw = (now - _lastTimeDraw)/1000.0;
  _elapsedTime += _deltaTimeDraw;
  _lastTimeDraw = now;  
    
  if (shower) {
    for (int i = 0; i < 20; i++){
      _system.addParticle(_system._n, new PVector(mouseX+random(-1,1), mouseY+random(-1,1)), new PVector(), m_part, r_part);
      _system._n++;
    }
  }

  // collision detection
  time_colisiones = millis();
  _system.computeCollisions(_planes, _computePlaneCollisions);  
  time_colisiones = millis() - time_colisiones;

  _system.run();

  // draw 
  time_draw_scene = millis();
  drawStaticEnvironment();
  _system.display();  
  time_draw_scene = millis() - time_draw_scene;
  
  // Drawing info separated from the scene
  drawInfo();
  printInfo();
  
  _simTime += SIM_STEP;
  frame++;
}

void keyPressed()
{
  if (key == 'p')
  {
    if (puerta)
    {
      _planes.remove(5);
      puerta = false;
    }
    else
    {
      _planes.add(new PlaneSection(padding_puerta, height/2, padding_puerta+padding*2, height/2, false));
      puerta = true;
    }
  }
  
  if (key == 'n') {
    type = EstructuraDatos.NONE;
  }
  if (key == 'g') {
    type = EstructuraDatos.GRID;
  }
  if (key == 'h') {
    type = EstructuraDatos.HASH;
  }
  if (key == 'm') {
    MUESTRA = !MUESTRA;
  }

  // Change particle behavior
  if (key == '1') {
    transformGas();
  }
  if (key == '2') {
    transformLiquid();
  }
  if (key == '3') {
    transformViscoso();
  }

  if (key == 'r'){
    restart();
  }

  if (key == 'e'){
    _output.flush(); // Writes the remaining data to the file 
    _output.close(); // Finishes the file 
    exit(); // Stops the program 
  }
}

void transformGas()
{
  // Gaseous
  m_part = 0.02;
  L = r_part;
  ke = 0.7;
  k_pared = 0.1;
  k = 0.4;
  modelo_liquido = "GAS";
}

void transformLiquid()
{
  // Liquido
  m_part = 10;
  L = r_part*2;
  ke = 25;
  k_pared = 0.5;
  modelo_liquido = "LÍQUIDO";
}

void transformViscoso()
{
  // Viscous
  m_part = 20;
  L = r_part;
  ke = 10;
  k_pared = 0.3;
  modelo_liquido = "VISCOSO";
}

void restart()
{
  initSimulation();
}

void mousePressed()
{
  shower = true;
}

void mouseReleased()
{
  shower = false;
}
