// Problem description:
// Inclined plane with a spring at each end of the plane

// Differential equations:
// The ecuations we will need are:
// Weight force:
// magnitude: mass * gravity
// x: 0
// y: -1
// 
// Normal force:
// magnitude: mass * gravity * cos(alpha)
// x: sin(angle)
// y: cos(angle)
// 
// Plane friction force:
// magnitude: Mu * Normal force
// x: -v,x
// y: -v.y (in the opposite direction of velocity)
// 
//Air friction force:
// magnitude: Kd * velocity^2
// x: -v.x
// y: -v.y (in the opposite direction of velocity)
// 
// Spring force:
// magnitude: Kei * elongation
// x: resting position - current position (in the x axis)
// y: resting position - current position (in the y axis)

// Definitions:

enum IntegratorType 
{
  NONE,
  EXPLICIT_EULER, 
  SIMPLECTIC_EULER, 
  HEUN, 
  RK2, 
  RK4
}

// Parameters of the numerical integration:

final boolean REAL_TIME = true;
float SIM_STEP = 0.01;   // Simulation time-step (s)
// IntegratorType _integrator = IntegratorType.EXPLICIT_EULER;   // ODE integration method
IntegratorType _integrator = IntegratorType.RK2;   // ODE integration method

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
// plane length
final float L = 10;
// plane angle
final float alpha = radians(30);
// elastic constant of the springs
final float Ke1 = 0.5;
final float Ke2 = 0.5;
// rest elongation of the spring
final float Lo1 = 3;
final float Lo2 = 3;
// friction constant of the air
final float Kd = 0.1;
// friction constant of the plane
final float Mu = 0.1;
// boolean to know if the plane is active or not
boolean suelo = true;

//final float alpha = (PI/2) - PVector.angleBetween(PVector.sub(C1,C2), C2);
final PVector C1 = new PVector (L*cos(alpha), 0);
final PVector C2 = new PVector (0, L*sin(alpha));
final PVector P0 = PVector.add(C1,C2).div(2);

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
PVector _v = new PVector();   // Velocity of the particle (m/s)
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
  screenPos.x = 0.5*DISPLAY_SIZE_X + (worldPos.x - DISPLAY_CENTER.x)*PIXELS_PER_METER;
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
  
  text("pulsa 'p' para quitar/restaurar el plano", width*0.025, height*0.15);
  text("pulsa 'r' para reiniciar la simulacion", width*0.025, height*0.175);
  text("pulsa '+' para aumentar el sim_step", width*0.025, height*0.200);
  text("pulsa '-' para disminuir el sim_step", width*0.025, height*0.225);
  text("pulsa 'flecha arriba/abajo' para cambiar de integrador", width*0.025, height*0.250);
  
  fill(REFERENCE_COLOR[0], REFERENCE_COLOR[1], REFERENCE_COLOR[2]);
  strokeWeight(1);

  PVector screenPos = new PVector();
  worldToScreen(new PVector(), screenPos);

  circle(screenPos.x, screenPos.y, 20);

  // the plane
  if (suelo) {
    stroke(0);
    PVector C1_pos = new PVector();
    worldToScreen(C1, C1_pos);

    PVector C2_pos = new PVector();
    worldToScreen(C2, C2_pos);

    // plane
    line(screenPos.x, screenPos.y, C1_pos.x, C1_pos.y);
    line(screenPos.x, screenPos.y, C2_pos.x, C2_pos.y);
    line(C1_pos.x, C1_pos.y, C2_pos.x, C2_pos.y);
  }
}

void drawMovingElements()
{
  fill(OBJECTS_COLOR[0], OBJECTS_COLOR[1], OBJECTS_COLOR[2]);
  strokeWeight(1);

  PVector screenPos = new PVector();
  worldToScreen(_s, screenPos);

  // particle
  circle(screenPos.x, screenPos.y, worldToPixels(OBJECTS_SIZE));

  // spring
  stroke(255,0,0);
  PVector C1_pos = new PVector();
  worldToScreen(C1, C1_pos);
  line(screenPos.x, screenPos.y, C1_pos.x, C1_pos.y);

  stroke(0,0,255);
  PVector C2_pos = new PVector();
  worldToScreen(C2, C2_pos);
  line(screenPos.x, screenPos.y, C2_pos.x, C2_pos.y);
  
  
  // decoment to show the resting points of each spring
  
  //PVector Reposo2 = PVector.sub(_s, C2);
  //Reposo2.setMag(Lo2);
  //Reposo2.add(C2);
  //PVector Fm2 = PVector.sub(_s, Reposo2);
  //float Fm2_mag = Ke2 * Fm2.mag();
  //Fm2.setMag(Fm2_mag);
  
  //worldToScreen(Reposo2, C1_pos);
  //circle(C1_pos.x, C1_pos.y, worldToPixels(OBJECTS_SIZE));
  
  //PVector Reposo1 = PVector.sub(_s, C1);
  //Reposo1.setMag(Lo1);
  //Reposo1.add(C1);
  //PVector Fm1 = PVector.sub(_s, Reposo1);
  //float Fm1_mag = Ke1 * Fm1.mag();
  //Fm1.setMag(Fm1_mag);
  
  //worldToScreen(Reposo1, C1_pos);
  //circle(C1_pos.x, C1_pos.y, worldToPixels(OBJECTS_SIZE));
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

  _s.set(PVector.add(C1,C2).div(2));   // Position of the particle (m)
  _v = new PVector();   // Velocity of the particle (m/s)
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
  PVector _a_fin = _a.copy();
  PVector _s_fin = _s.copy();
  PVector _v_fin = _v.copy();

  

  // _s and _v are at the beginning of the interval
  // we compute a at the beginning of the interval
  _a = calculateAcceleration(_s, _v); 
  
  // we calculate _v at the end of the interval
  _v_fin.add(PVector.mult(_a, SIM_STEP)); 
  // we calculate _s at the end of the interval
  _s_fin.add(PVector.mult(_v, SIM_STEP)); 
  // with _v and _s at the end of the interval we calculate _a at the end of the interval
  _a_fin = calculateAcceleration(_s_fin, _v_fin); 

  // we calculate the average of the acceleration at the beginning and at the end of the interval
  PVector _a_media = PVector.add(_a, _a_fin).div(2);
  // we calculate the average of the speed at the beginning and at the end of the interval
  PVector _v_media = PVector.add(_v, _v_fin).div(2); 

  //we update _s with _v_media
  _s.add(PVector.mult(_v_media, SIM_STEP));
  //we update _v with _a_media
  _v.add(PVector.mult(_a_media, SIM_STEP)); 
}

void updateSimulationRK2()
{

  PVector _s_mid = _s.copy();
  PVector _v_mid = _v.copy();
  PVector _a_mid = new PVector();

  // s and v are already at the beginning of the interval
  // calculate a at the beginning of the interval
  _a = calculateAcceleration(_s, _v);

  // calculate v in the middle of the interval
  _v_mid.add(PVector.mult(_a, SIM_STEP/2));
  // calculate s in the middle of the interval
  _s_mid.add(PVector.mult(_v, SIM_STEP/2));
  
  // update to in the middle of the interval
  _a_mid = calculateAcceleration(_s_mid, _v_mid);
  
  // update s with the value of v in the middle of the interval
  _s.add(PVector.mult(_v_mid, SIM_STEP));
  // update v with the value of a from the middle of the interval
  _v.add(PVector.mult(_a_mid, SIM_STEP));
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
  // total forces;
  PVector Ftotal = new PVector();


  // weight force
  PVector Fp = PVector.mult(G, M);
  float Fp_mag = Fp.mag();
  Ftotal.add(Fp);

  // if the plane exists calculate and add the normal force and the fricction of the plane
  if (suelo) {
    // normal force
    PVector Fn = new PVector(sin(alpha), cos(alpha));
    float Fn_mag = Fp_mag * cos(alpha);
    Fn.setMag(Fn_mag);
    Ftotal.add(Fn);

    // plane friction force
    PVector Frs = PVector.mult(v,-1);
    float Frs_mag = Mu * Fn_mag;
    Frs.setMag(Frs_mag);
    Ftotal.add(Frs);
  }

  // air friction force
  PVector Fra = PVector.mult(v,-1);
  float Fra_mag = pow(v.mag(), 2) * Kd;
  Fra.setMag(Fra_mag);
  Ftotal.add(Fra);

  // spring 1 force
  PVector Reposo1 = PVector.sub(s, C1);
  Reposo1.setMag(Lo1);
  Reposo1.add(C1);
  PVector Fm1 = PVector.sub(Reposo1, s);
  float Fm1_mag = Ke1 * Fm1.mag();
  Fm1.setMag(Fm1_mag);
  Ftotal.add(Fm1);

  // spring 2 force
  PVector Reposo2 = PVector.sub(s, C2);
  Reposo2.setMag(Lo2);
  Reposo2.add(C2);
  PVector Fm2 = PVector.sub(Reposo2, s);
  float Fm2_mag = Ke2 * Fm2.mag();
  Fm2.setMag(Fm2_mag);
  Ftotal.add(Fm2);

  // a = sumatorio(Fuerzas) / masa
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

  // Elastic energy of the spring C1:
  PVector Elongation = PVector.sub(_s, C1);
  Elongation.setMag(Lo1);
  Elongation.add(C1);
  _energy += 0.5 * Ke1 * pow(PVector.sub(Elongation, _s).mag(), 2);

  // Elastic energy of the spring C2:
  Elongation = PVector.sub(_s, C2);
  Elongation.setMag(Lo2);
  Elongation.add(C2);
  _energy += 0.5 * Ke2 * pow(PVector.sub(Elongation, _s).mag(), 2);
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

  drawStaticEnvironment();
  drawMovingElements();

  calculateEnergy();
  PrintInfo();
}

void mouseClicked() 
{
  // ...
  // ...
  // ...
}

void keyPressed()
{
  if (key == 'p')
    suelo = !suelo;
  if (key == 'r'){
    print("\nReset\n");
    initSimulation();
  }

  // cambiar el paso de simulacion
  if (key == '+') {
    SIM_STEP += 0.01;
  }
  if (key == '-') {
    SIM_STEP -= 0.01;
  }

  // press up or down to iterate through the integrators
  if (key == CODED) {
    if (keyCode == UP) {
      int index = _integrator.ordinal() + 1;
      index %= _integrator.values().length;
      _integrator = _integrator.values()[index];
    }
    if (keyCode == DOWN) {
      int index = _integrator.ordinal() - 1;
      
      // If index is negative, we need to go to the last element with ternary operator
      index = (index < 0) ? _integrator.values().length - 1 : index;
      _integrator = _integrator.values()[index];
    }
  }
}

void stop()
{
}
