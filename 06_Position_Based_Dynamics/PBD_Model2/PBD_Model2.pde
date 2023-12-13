import peasy.*;

PeasyCam cam;
float scale_px = 1000;

boolean debug = false;

PBDSystem system;
Ball _ball;

//final PVector BALL_START_POS = new PVector(0.3, 0.3, -0.5);   // Initial position of the sphere (m)
final PVector BALL_START_POS = new PVector(0.0, 0.0, 0.0);   // Initial position of the sphere (m)
//PVector BALL_START_VEL = new PVector(0.0, 0.0, 0.4);   // Initial velocity of the sphere (m/s)
PVector BALL_START_VEL = new PVector(0.0, 0.0, 0.0);   // Initial velocity of the sphere (m/s)
final float BALL_MASS = 500.1;   // Mass of the sphere (kg)
final float BALL_RADIUS = 0.1;   // Radius of the sphere (m)
final color BALL_COLOR = color(250, 0, 0);   // Ball color (RGB)
  
float dt = 0.02;

PVector vel_viento= new PVector(0,0,0);

//wind intensity module
float viento;

// Scenario triggers
String s = "./v1/";

// Fabric properties
float ancho_tela = 0.5;
float alto_tela = 0.5;
int n_ancho_tela = 10;
int n_alto_tela = 10;
float densidad_tela = 0.1; // kg/m^2 Could be thick cotton fabric, 100g/m^2
float sphere_size_tela = ancho_tela/n_ancho_tela*0.4;
float stiffness1 = 0.9; // distance
float stiffness2 = 0.9; // shear
float stiffness3 = 0.2; // bend


void setup(){

  size(960,540,P3D);
  //size(720,480,P3D);

  cam = new PeasyCam(this,scale_px);
  cam.setMinimumDistance(1);
  // The sign of the y is changed, because the px increases downwards
  cam.pan(0.5*ancho_tela*scale_px, - 0.5*alto_tela*scale_px);
  
  //cam.rotateY(PI/1.2); // camara en posicion diagonal mas de espaldas
  //cam.rotateY(PI/1.5); // camara en posicion diagonal de espaldas
  //cam.rotateY(PI/2); // camara en posicion de perfil
  //cam.rotateY(PI/4); // camara en posicion diagonal al frente
  cam.rotateY(PI/6); // camara en posicion diagonal mas al frente
  cam.rotateX(PI/6); // camara en posicion diagonal mas al frente
  //cam.rotateX(-PI/4); // camara en posicion diagonal mas al frente

  // to zoom the camera in or out modify variable
  cam.setDistance(1 * scale_px);
  
  
  system = crea_model(densidad_tela,
                      stiffness1,
                      sphere_size_tela,
                      "cubo8x8x8.obj");
  /*system = crea_model(densidad_tela,
                      stiffness1,
                      sphere_size_tela,
                      "sphere.obj");*/
  /*system = crea_model(densidad_tela,
                      stiffness1,
                      sphere_size_tela,
                      "cono.obj");*/
  /*system = crea_model(densidad_tela,
                      stiffness1,
                      sphere_size_tela,
                      "toro.obj");*/
  /*system = crea_model(densidad_tela,
                      stiffness1,
                      sphere_size_tela,
                      "suzanne.obj");*/
  /*system = crea_model(densidad_tela,
                      stiffness1,
                      sphere_size_tela,
                      "toro.obj");*/
  /*system = crea_tela(alto_tela,
                      ancho_tela,
                      densidad_tela,
                      n_alto_tela,
                      n_ancho_tela,
                      stiffness1,
                      sphere_size_tela);*/
                      
  system.set_n_iters(10);
  
  //_ball = new Ball(BALL_START_POS, BALL_START_VEL, BALL_MASS, BALL_RADIUS, BALL_COLOR);
}

void aplica_viento(){
  // We apply a force that is proportional to the area.
  // We do not calculate the normal. It is left as an exercise
  // The area is calculated as the total area, divided by the number of particles
  int npart = system.particles.size();
  float area_total = ancho_tela*alto_tela;
  float area = area_total/npart;
  for(int i = 0; i < npart; i++){
    float x = (0.5 + random(0.5))*vel_viento.x * area;
    float y = (0.5 + random(0.5))*vel_viento.y * area;
    float z = (0.5 + random(0.5))*vel_viento.z * area;
    PVector fv = new PVector(x,y,z); 
    system.particles.get(i).force.add(fv);
  }
  
  
}

void draw(){
  background(20,20,55);
  lights();

  system.apply_gravity(new PVector(0.0,-0.81,0.0));
  aplica_viento();

  //system.avoidCollision();
  system.run(dt);  
  
  //apply gravity to the ball too
  //_ball.force.add(PVector.mult(new PVector(0.0,-0.81,0.0),_ball.masa));
  //_ball.update(dt);
  //_ball.update_pbd_vel(dt);

  display();

  //stats();
  //saveFrame(s + "line-######.png");
}



void stats(){
  

// Writes the number of current particles on the screen
  int npart = system.particles.size();
  fill(255);
  text("Frame-Rate: " + int(frameRate), -175, 15);

  text("Vel. Viento=("+vel_viento.x+", "+vel_viento.y+", "+vel_viento.x+")",-175,35);
  text("s - Arriba",-175,55);
  text("x - Abajo",-175,75);
  text("c - Derecha",-175,95);
  text("z - Izquierda",-175,115);
}

void display(){
  int npart = system.particles.size();
  int nconst = system.constraints.size();

  for(int i = 0; i < npart; i++){
    system.particles.get(i).display(scale_px);
  }
  
  for(int i = 0; i < nconst; i++)
      system.constraints.get(i).display(scale_px);
      
  //_ball.print();
}

void mousePressed(){
  PVector pos = new PVector(mouseX, height);
  color miColor = color(200,0,0);
}

void keyPressed()
{
 if(key == '1'){
    //println(key);
 }
  if(key == 'Y'){
    vel_viento.y -= 0.01;
  }else if(key == 'y'){
    vel_viento.y += 0.01;
  }else if(key == 'z'){
    vel_viento.z -= 0.01;
  }else if(key == 'Z'){
    vel_viento.z += 0.01;
  }else if(key == 'X'){
    vel_viento.x += 0.01;
  }else if(key == 'x'){
    vel_viento.x -= 0.01;
  }
  
}  
