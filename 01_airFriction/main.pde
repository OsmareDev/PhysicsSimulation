// Problem description:
// The simulation will consist of calculating the trajectory followed by a particle that is launched
// with an initial velocity and is affected by the force of weight and friction with the air or the water

// Differential equations:
// Weight force:
// magnitude: mass * gravity
// x: 0
// y: -1
// 
// Fuerza fricción del aire:
// magnitude: Kd * velocity (is not squared since it is required to be linear)
// x: -v.x
// y: -v.y (in the opposite direction of velocity)



// Definitions:

enum IntegratorType 
{
  NONE,
  EXPLICIT_EULER, 
  SIMPLECTIC_EULER, 
  HEUN, 
  RK2, 
  RK4;
}

// Parameters of the numerical integration:

final boolean REAL_TIME = true;
float SIM_STEP = 0.01;   // Simulation time-step (s)
// IntegratorType _integrator = IntegratorType.EXPLICIT_EULER;   // ODE integration method
IntegratorType _integrator = IntegratorType.NONE;   // ODE integration method

// Display values:

final boolean FULL_SCREEN = false;
final int DRAW_FREQ = 50;   // Draw frequency (Hz or Frame-per-second)
int DISPLAY_SIZE_X = 1000;   // Display width (pixels)
int DISPLAY_SIZE_Y = 1000;   // Display height (pixels)

// Draw values:

final int [] BACKGROUND_COLOR = {200, 200, 255};
final int [] REFERENCE_COLOR = {0, 255, 0};
final int [] OBJECTS_COLOR = {255, 0, 0};
final float OBJECTS_SIZE = 1.0;   // Size of the objects (m)
final float PIXELS_PER_METER = 20.0;   // Display length that corresponds with 1 meter (pixels)
final PVector DISPLAY_CENTER = new PVector(0.0, 0.0);   // World position that corresponds with the center of the display (m)

// Parameters of the problem:

final float M = 1.0;   // Particle mass (kg)
final float Gc = 9.801;   // Gravity constant (m/(s*s))
final PVector G = new PVector(0.0, -Gc);   // Acceleration due to gravity (m/(s*s))

// ------- DEFINIR --------
float alpha = radians(50);
final float h = 3;
final float Ka = 0.1; // Friction air
final float Kw = 3.7; // Friction water
final float padding_left = 30.0; 
// size of the ship
final PVector size_ship = new PVector(4, 2);
// upper left corner of the ship
final PVector upper_left_ship = new PVector(10, 1);


//final float alpha = (PI/2) - PVector.angleBetween(PVector.sub(C1,C2), C2);

// Time control:
int _lastTimeDraw = 0;   // Last measure of time in draw() function (ms)
float _deltaTimeDraw = 0.0;   // Time between draw() calls (s)
float _simTime = 0.0;   // Simulated time (s)
float _elapsedTime = 0.0;   // Elapsed (real) time (s)

// Output control:

PrintWriter _output;
final String FILE_NAME = "data.txt";

// Auxiliary variables:

float _energy;   // Total energy of the particle (J);

// Variables to be solved:
PVector _s = new PVector();   // Position of the particle (m)
PVector _stopMove = new PVector();
PVector _v = new PVector();   // Velocity of the particle (m/s)
float _v0 = 15;   // Velocity of the particle (m/s)
PVector _a = new PVector();   // Accleration of the particle (m/(s*s))


// Main code:

// Converts distances from world length to pixel length
float worldToPixels(float dist)
{
  return dist*PIXELS_PER_METER;
}

// Converts distances from pixel length to world length
float pixelsToWorld(float dist)
{
  return dist/PIXELS_PER_METER;
}

// Converts a point from world coordinates to screen coordinates
void worldToScreen(PVector worldPos, PVector screenPos)
{
  // screenPos.x = 0.5*DISPLAY_SIZE_X + (worldPos.x - DISPLAY_CENTER.x)*PIXELS_PER_METER;
  screenPos.x = padding_left + (worldPos.x - DISPLAY_CENTER.x)*PIXELS_PER_METER;
  screenPos.y = 0.5*DISPLAY_SIZE_Y - (worldPos.y - DISPLAY_CENTER.y)*PIXELS_PER_METER;
}

// Converts a point from screen coordinates to world coordinates
void screenToWorld(PVector screenPos, PVector worldPos)
{
  worldPos.x = ((screenPos.x - 0.5*DISPLAY_SIZE_X)/PIXELS_PER_METER) + DISPLAY_CENTER.x;
  worldPos.y = ((0.5*DISPLAY_SIZE_Y - screenPos.y)/PIXELS_PER_METER) + DISPLAY_CENTER.y;
}

void drawStaticEnvironment()
{
  background(BACKGROUND_COLOR[0], BACKGROUND_COLOR[1], BACKGROUND_COLOR[2]);

  textSize(20);
  text("Sim. Step = " + SIM_STEP + " (Real Time = " + REAL_TIME + ")", width*0.025, height*0.075);  
  text("Integrator = " + _integrator, width*0.025, height*0.1);
  text("Energy = " + _energy + " J", width*0.025, height*0.125);
  
  text("pulsa '+' para aumentar el sim_step", width*0.025, height*0.200);
  text("pulsa '-' para disminuir el sim_step", width*0.025, height*0.225);
  text("pulsa 'flecha arriba/abajo' para cambiar de integrador", width*0.025, height*0.250);
  text("pulsa 'r' para reiniciar la simulacion", width*0.025, height*0.275);
  text("pulsa 'w' para aumentar el angulo", width*0.025, height*0.15);
  text("pulsa 's' para disminuir el angulo", width*0.525, height*0.15);
  text("pulsa 'a' para aumentar la fuerza", width*0.025, height*0.175);
  text("pulsa 'd' para disminuir la fuerza", width*0.525, height*0.175);
  
  fill(REFERENCE_COLOR[0], REFERENCE_COLOR[1], REFERENCE_COLOR[2]);
  strokeWeight(1);

  PVector screenPos = new PVector();
  worldToScreen(new PVector(), screenPos);
  circle(screenPos.x, screenPos.y, 10);

  PVector upper_pos = new PVector();
  worldToScreen(upper_left_ship, upper_pos);


  // Draw the ship
  fill(255, 100, 55);
  strokeWeight(1);
  rect(upper_pos.x, upper_pos.y, worldToPixels(size_ship.x), worldToPixels(size_ship.y));
  
  // Draw the water
  fill(0, 0, 255, 100);
  strokeWeight(1);
  PVector leftcorner = new PVector(-padding_left/PIXELS_PER_METER, 0);
  worldToScreen(leftcorner, screenPos);
  rect(screenPos.x, screenPos.y, width, height);
}

void drawMovingElements()
{
  fill(OBJECTS_COLOR[0], OBJECTS_COLOR[1], OBJECTS_COLOR[2]);
  strokeWeight(1);

  PVector screenPos = new PVector();
  worldToScreen(_s, screenPos);

  circle(screenPos.x, screenPos.y, worldToPixels(OBJECTS_SIZE));

  
  PVector position = new PVector(0, h);
  for (float t = 0; t < 5; t += 0.05)
  {
    analiticFunction(position, t);

    worldToScreen(position, screenPos);
    circle(screenPos.x, screenPos.y, worldToPixels(OBJECTS_SIZE/3));
  }
}

void PrintInfo()
{
  _output.println("[" + _simTime + "] Position: " + _s);
  _output.println("[" + _simTime + "] Velocidad: " + _v);
  _output.println("[" + _simTime + "] Energia: " + _energy);
  _output.println("------------------------------------");
  
  // used print to convert to excel
  // _output.println(_simTime + "," + _integrator + "," + SIM_STEP + "," + _s.x + "," + _s.y + "," + _v.x + "," + _v.y + "," + _a.x + "," + _a.y + "," + _energy);
}

void initSimulation()
{
  // Time control:
  _lastTimeDraw = millis();   // Last measure of time in draw() function (ms)
  _deltaTimeDraw = 0.0;   // Time between draw() calls (s)
  _simTime = 0.0;   // Simulated time (s)
  _elapsedTime = 0.0;   // Elapsed (real) time (s)

  // Auxiliary variables:
  _energy = 0;   // Total energy of the particle (J)
  
  // Prepare the printing:
  _output = createWriter("data.txt");
  
  //outputs for the conversion to excel to make the graph
  //_output = createWriter("data.csv");
  //_output.println("tiempo,integrador,paso,pos_x,pos_y,vel_x,vel_y,ace_x,ace_y,energia");
  
  // Variables to be solved:

  _s.set(0, h);   // Position of the particle (m)
  _v = new PVector(_v0 * cos(alpha), _v0 * sin(alpha));;
  _a = new PVector();   // Accleration of the particle (m/(s*s))  
}

void updateSimulation()
{
  switch (_integrator)
  {
  case EXPLICIT_EULER:
    updateSimulationExplicitEuler();
    break;

  case SIMPLECTIC_EULER:
    updateSimulationSimplecticEuler();
    break;

  case HEUN:
    updateSimulationHeun();
    break;

  case RK2:
    updateSimulationRK2();
    break;

  case RK4:
    updateSimulationRK4();
    break;
  }
  
  _simTime += SIM_STEP;
}

void updateSimulationExplicitEuler()
{
  // s(t+h) = s(t) + h*v(t)
  // v(t+h) = v(t) + h*a(s(t),v(t))
  
  _a = calculateAcceleration(_s, _v);
  
  _s.add(PVector.mult(_v, SIM_STEP));
  _v.add(PVector.mult(_a, SIM_STEP));
}

void updateSimulationSimplecticEuler()
{
  // v(t+h) = v(t) + h*a(s(t),v(t))
  // s(t+h) = s(t) + h*v(t+h) 
  
  _a = calculateAcceleration(_s, _v);
  
  _v.add(PVector.mult(_a, SIM_STEP));
  _s.add(PVector.mult(_v, SIM_STEP));
}

void updateSimulationHeun()
{
  _a = calculateAcceleration(_s, _v);
  
  PVector _v_aux = new PVector();
  _v_aux.set(_v);
    
  _v.add(PVector.mult(_a, SIM_STEP));
  _v_aux.add(_v).div(2);
  _s.add(PVector.mult(_v_aux, SIM_STEP));
}

void updateSimulationRK2()
{
  PVector _s_aux = _s.copy();
  PVector _v_aux = _v.copy();
  
  _a = calculateAcceleration(_s, _v);
  
  _s_aux.add(PVector.mult(_v, SIM_STEP/2));
  _v_aux.add(PVector.mult(_a, SIM_STEP/2));
  
  _a = calculateAcceleration(_s_aux, _v_aux);
  
  _s.add(PVector.mult(_v_aux, SIM_STEP));
  _v.add(PVector.mult(_a, SIM_STEP));
}

void updateSimulationRK4()
{
  _a = calculateAcceleration(_s, _v);

  PVector _s_aux = _s.copy();
  PVector _v_aux = _v.copy();

  // k1
  PVector k1v = PVector.mult(_a, SIM_STEP);
  PVector k1s = PVector.mult(_v, SIM_STEP);

  // k2
  _s_aux.add(PVector.div(k1s,2));
  _v_aux.add(PVector.div(k1v,2));
  _a = calculateAcceleration(_s_aux, _v_aux);

  PVector k2v = PVector.mult(_a, SIM_STEP);;
  PVector k2s = PVector.mult(_v_aux, SIM_STEP);
  
  // k3
  _s_aux.set(_s);
  _v_aux.set(_v);

  _s_aux.add(PVector.div(k2s,2));
  _v_aux.add(PVector.div(k2v,2));
  _a = calculateAcceleration(_s_aux, _v_aux);

  PVector k3v = PVector.mult(_a, SIM_STEP);;
  PVector k3s = PVector.mult(_v_aux, SIM_STEP);

  // k4
  _s_aux.set(_s);
  _v_aux.set(_v);

  _s_aux.add(k2s);
  _v_aux.add(k2v);
  _a = calculateAcceleration(_s_aux, _v_aux);

  PVector k4v = PVector.mult(_a, SIM_STEP);;
  PVector k4s = PVector.mult(_v_aux, SIM_STEP);

  _v.add(PVector.mult(k1v, 1/6.0));
  _v.add(PVector.mult(k2v, 1/3.0));
  _v.add(PVector.mult(k3v, 1/3.0));
  _v.add(PVector.mult(k4v, 1/6.0));
  
  _s.add(PVector.mult(k1s, 1/6.0));
  _s.add(PVector.mult(k2s, 1/3.0));
  _s.add(PVector.mult(k3s, 1/3.0));
  _s.add(PVector.mult(k4s, 1/6.0));
}

PVector calculateAcceleration(PVector s, PVector v)
{
  PVector a = new PVector();
  PVector Fp = PVector.mult(G, M);
  PVector Fr = new PVector();
  
  
  if (s.y > 0) {
    // Air friction
    Fr.set(PVector.mult(v,-1));
    float Fr_mag = Ka * pow(v.mag(), 1);
    Fr.setMag(Fr_mag);
  }
  else {
    // water friction
    Fr.set(PVector.mult(v,-1));
    float Fr_mag = Kw * pow(v.mag(), 1);
    Fr.setMag(Fr_mag);
  }

  PVector Ftotal = Fp.copy(); // Applying weigth force
  Ftotal.add(Fr); // Applying air resistance force


  a.set(PVector.div(Ftotal,M));  

  return a;
}

void calculateEnergy()
{  
  // Reset Energy
  _energy = 0;

  // Cinetic energy:
  _energy += 0.5 * M * pow(_v.mag(), 2);

  // Potential energy:
  _energy += M * Gc * (_s.y);
}

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

  initSimulation();
}

void draw()
{
  _stopMove.set(_s);
  
  int now = millis();
  _deltaTimeDraw = (now - _lastTimeDraw)/1000.0;
  _elapsedTime += _deltaTimeDraw;
  _lastTimeDraw = now;

  // println("\nDraw step = " + _deltaTimeDraw + " s - " + 1.0/_deltaTimeDraw + " Hz");

  if (REAL_TIME)
  {
    float expectedSimulatedTime = 1.0*_deltaTimeDraw;
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

  if (hitShip())
    stop();

  drawStaticEnvironment();
  drawMovingElements();
    
  calculateEnergy();
  PrintInfo();
}

void mouseClicked() 
{
}

void keyPressed()
{
  if (key == 'r'){
    initSimulation();
  }
  
  // change the initial velocity
  if (key == 'd') {
    _v0 += 1;
  }
  if (key == 'a') {
    _v0 -= 1;
  }
  
  // change the angle of the trajectory
  if (key == 'w') {
    if (alpha < PI/2)
      alpha += radians(1);
  }
  if (key == 's') {
    if (alpha > 0)
      alpha -= radians(1);
  }
  
  // change the step of the simulation
  if (key == '+') {
    SIM_STEP += 0.01;
  }
  if (key == '-') {
    SIM_STEP -= 0.01;
  }

  // cambiar de integrador
  if (key == CODED) {
    if (keyCode == UP) {
      int index = _integrator.ordinal() + 1;
      index %= _integrator.values().length;
      _integrator = _integrator.values()[index];
      
      if (_integrator == _integrator.values()[1])
        initSimulation();
    }
    if (keyCode == DOWN) {
      int index = _integrator.ordinal() - 1;
      
      // If index is negative, we need to go to the last element with ternary operator
      index = (index < 0) ? _integrator.values().length - 1 : index;
      _integrator = _integrator.values()[index];
      
      if (_integrator == _integrator.values()[5])
        initSimulation();
    }
  }
}

void stop()
{
  _s.set(_stopMove);
  _v = new PVector(0,0);
  _a = new PVector(0,0);
}

boolean hitShip()
{
  // size_ship = new PVector(20, 20);
  // botom_left_ship = new PVector(600, 0);
  // size_ship = new PVector(20, 20);
  // bottom_left_ship = new PVector(600, 0);

  PVector upperShip = new PVector();
  worldToScreen(upper_left_ship, upperShip);
  Boolean hit = false;

  if (_s.x > upper_left_ship.x)
    if (_s.x < upper_left_ship.x + size_ship.x)
      if (_s.y < upper_left_ship.y)
        if (_s.y > upper_left_ship.y - size_ship.y)
          hit = true;
  
  if(hit) {
    print("Has dado en el blanco");
    print("\n");
  }
  
  return hit;
}

// analitic function to compare with the trajectory of the simulations
void analiticFunction(PVector posicion, float t){

  PVector _pos = new PVector();

  float vt = (M * Gc)/(Ka);

  _pos.x = ((_v0 * vt * cos(alpha))/(Gc))*(1 - exp((-Gc*t)/vt));
  _pos.y = (vt/Gc)*(_v0 * sin(alpha) + vt) * (1 - exp((-Gc * t)/vt)) - (vt * t) + h;

  posicion.set(_pos);
  
}
