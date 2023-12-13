// Use PeasyCam for 3D rendering //<>// //<>// //<>//
import peasy.*;


// Spring Layout
enum SpringLayout 
{
  STRUCTURAL, 
  SHEAR, 
  STRUCTURAL_AND_SHEAR, 
  STRUCTURAL_AND_BEND, 
  STRUCTURAL_AND_SHEAR_AND_BEND
}


// Simulation values:

final boolean REAL_TIME = true;
final float TIME_ACCEL = 1.0;   // To simulate faster (or slower) than real-time
float SIM_STEP = 0.001;   // Simulation time-step (s)


// Problem parameters:

final PVector G = new PVector(0.0, 0.0, -9.81);   // Acceleration due to gravity (m/(s*s))

final float NET_LENGTH_X = 600.0;    // Length of the net in the X direction (m)
final float NET_LENGTH_Y = 400.0;    // Length of the net in the Y direction (m)
final float NET_POS_Z = -500.0;   // Position of the net in the Z axis (m)
final int NET_NUMBER_OF_NODES_X = 60;   // Number of nodes of the net in the X direction
final int NET_NUMBER_OF_NODES_Y = 40;   // Number of nodes of the net in the Y direction
final float NET_NODE_MASS = 0.1;   // Mass of the nodes of the net (kg)

final float NET_KE = 150.0;   // Ellastic constant of the net's springs (N/m) 
final float NET_KD = 5.0;   // Damping constant of the net's springs (kg/m)
final float NET_MAX_FORCE = 500.0;   // Maximum force allowed for the net's springs (N)
final float NET_BREAK_LENGTH_FACTOR = 18.0;   // Maximum distance factor (measured in number of times the rest length) allowed for the net's springs

boolean NET_IS_UNBREAKABLE = false;   // True if the net cannot be broken
SpringLayout NET_SPRING_LAYOUT;   // Current spring layout

final PVector BALL_START_POS = new PVector(0.0, 0.0, -200.0);   // Initial position of the sphere (m)
PVector BALL_START_VEL = new PVector(0.0, 0.0, -100.0);   // Initial velocity of the sphere (m/s)
final float BALL_MASS = 120;   // Mass of the sphere (kg)
final float BALL_RADIUS = 50.0;   // Radius of the sphere (m)

final float COLLISION_KE = 100.0;   // Ellastic constant of the collision springs (N/m) 
final float COLLISION_KD = 3;   // Damping constant of the net's springs (kg/m)
final float COLLISION_MAX_FORCE = 500.0;   // Maximum force allowed for the collision springs (N)
final float COLLISION_BREAK_LENGTH_FACTOR = BALL_RADIUS;   // Maximum distance factor (measured in number of times the rest length) allowed for the collision springs


PrintWriter _output;

// Display stuff:

final boolean FULL_SCREEN = false;
final int DRAW_FREQ = 50;   // Draw frequency (Hz or Frame-per-second)
int DISPLAY_SIZE_X = 1000;   // Display width (pixels)
int DISPLAY_SIZE_Y = 1000;   // Display height (pixels)

final float FOV = 60;   // Field of view (º)
final float NEAR = 0.01;   // Camera near distance (m)
final float FAR = 100000.0;   // Camera far distance (m)

final color BACKGROUND_COLOR = color(220, 240, 220);   // Background color (RGB)
final color NET_COLOR = color(0, 0, 0);   // Net lines color (RGB)
final color BALL_COLOR = color(250, 0, 0);   // Ball color (RGB)

PeasyCam _camera;   // mouse-driven 3D camera


// Time control:

int _lastTimeDraw = 0;   // Last measure of time in draw() function (ms)
float _deltaTimeDraw = 0.0;   // Time between draw() calls (s)
float _simTime = 0.0;   // Simulated time (s)
float _elapsedTime = 0.0;   // Elapsed (real) time (s)


// Simulated entities:

Ball _ball;   // Sphere
DeformableSurface _net;   // Deformable mesh

// Main code:

void initSimulation(SpringLayout springLayout)
{
  _simTime = 0.0;
  _elapsedTime = 0.0;
  NET_SPRING_LAYOUT = springLayout;

  _net = new DeformableSurface(NET_LENGTH_X, NET_LENGTH_Y, NET_NUMBER_OF_NODES_X, NET_NUMBER_OF_NODES_Y, NET_POS_Z, NET_NODE_MASS, NET_KE, NET_KD, NET_MAX_FORCE, NET_BREAK_LENGTH_FACTOR, NET_SPRING_LAYOUT, NET_IS_UNBREAKABLE, NET_COLOR);
  _ball = new Ball(BALL_START_POS, BALL_START_VEL, BALL_MASS, BALL_RADIUS, BALL_COLOR);

  _output = createWriter("normal.csv");
  _output.println("elapsed_time,fps,tipo");
}

void resetBall()
{
  _ball.setPosition(BALL_START_POS);
  _ball.setVelocity(BALL_START_VEL);
}

void updateSimulation()
{
  _ball.update(SIM_STEP);
  _net.avoidCollision(_ball, COLLISION_KE, COLLISION_KD, COLLISION_MAX_FORCE, COLLISION_BREAK_LENGTH_FACTOR);
  _net.update(SIM_STEP);

  _simTime += SIM_STEP;
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
  SIM_STEP *= TIME_ACCEL;
  
  float aspect = float(DISPLAY_SIZE_X)/float(DISPLAY_SIZE_Y);  
  perspective((FOV*PI)/180, aspect, NEAR, FAR);
  _camera = new PeasyCam(this, 0);

  initSimulation(SpringLayout.STRUCTURAL);
}

void printInfo()
{
  pushMatrix();
  {
    camera();
    fill(0);
    textSize(20);
    
    text("Frame rate = " + 1.0/_deltaTimeDraw + " fps", width*0.025, height*0.05);
    text("Elapsed time = " + _elapsedTime + " s", width*0.025, height*0.075);
    text("Simulated time = " + _simTime + " s ", width*0.025, height*0.1);
    text("Spring layout = " + NET_SPRING_LAYOUT, width*0.025, height*0.125);
    text("Ball start velocity = " + BALL_START_VEL + " m/s", width*0.025, height*0.15);

    if (NET_IS_UNBREAKABLE)
      text("Net is unbreakable", width*0.025, height*0.175);
    else   
      text("Net is breakable", width*0.025, height*0.175);
      
    text("Botones del 1 al 5 para cambiar tipo de malla", width*0.5, height*0.05);
    text("b - hacer irromplible/rompible la malla", width*0.5, height*0.075);
    text("flechas arriba/abajo - subir/bajar la velocidad inicial", width*0.5, height*0.1);
  }
  popMatrix();
}

void drawStaticEnvironment()
{
  fill(255, 255, 255);
  sphere(1.0);

  fill(255, 0, 0);
  box(200.0, 0.25, 0.25);

  fill(0, 255, 0);
  box(0.25, 200.0, 0.25);

  fill(0, 0, 255);
  box(0.25, 0.25, 200.0);
}

void drawDynamicEnvironment()
{
  _net.draw();
  _ball.draw();
}

void draw()
{
  int now = millis();
  _deltaTimeDraw = (now - _lastTimeDraw)/1000.0;
  _elapsedTime += _deltaTimeDraw;
  _lastTimeDraw = now;
  

  //println("\nDraw step = " + _deltaTimeDraw + " s - " + 1.0/_deltaTimeDraw + " Hz");

  background(BACKGROUND_COLOR);
  //drawStaticEnvironment();
  drawDynamicEnvironment();

  if (REAL_TIME)
  {
    float expectedSimulatedTime = TIME_ACCEL*_deltaTimeDraw;
    float expectedIterations = expectedSimulatedTime/SIM_STEP;
    int iterations = 0; 

    for (; iterations < floor(expectedIterations); iterations++)
      updateSimulation();

    if ((expectedIterations - iterations) > random(0.0, 1.0))
    {
      updateSimulation();
      iterations++;
    }

    //println("Expected Simulated Time: " + expectedSimulatedTime);
    //println("Expected Iterations: " + expectedIterations);
    //println("Iterations: " + iterations);
  } 
  else
    updateSimulation();
  
  _output.println(_elapsedTime + "," + 1.0/_deltaTimeDraw + "," + NET_SPRING_LAYOUT);
  printInfo();
}

void keyPressed()
{
  if (key == '1')
    initSimulation(SpringLayout.STRUCTURAL);

  if (key == '2')
    initSimulation(SpringLayout.SHEAR);

  if (key == '3')
    initSimulation(SpringLayout.STRUCTURAL_AND_SHEAR);

  if (key == '4')
    initSimulation(SpringLayout.STRUCTURAL_AND_BEND);    

  if (key == '5')
    initSimulation(SpringLayout.STRUCTURAL_AND_SHEAR_AND_BEND);  
  
  if (key == 'r')
    resetBall();

  if (keyCode == UP)
    BALL_START_VEL.mult(1.05);

  if (keyCode == DOWN)
    BALL_START_VEL.div(1.05);
    
  if (key == 'B' || key == 'b')
  {
    NET_IS_UNBREAKABLE = !NET_IS_UNBREAKABLE;
    initSimulation(NET_SPRING_LAYOUT);
  }
  
  if (key == 'I' || key == 'i')
    initSimulation(NET_SPRING_LAYOUT);

  if (key == 'F' || key == 'f')
  {
    _output.flush(); // Writes the remaining data to the file 
    _output.close(); // Finishes the file 
    exit(); // Stops the program 
  }
}
