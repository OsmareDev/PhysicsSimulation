class ParticleSystem 
{
  ArrayList<Particle> _particles;
  int _n;
  int _r;
  float _m;
  
  // ... (G, Kd, Ke, Cr, etc.)
  // ...
  // ...

  ParticleSystem(int n, int r, float m)  
  {
    _particles = new ArrayList<Particle>();
    _n = n;
    _r = r;
    _m = m;_elapsedTime = 0.0;
    
    // create the balls
    for(int i = 0; i < n; i++)
    {
      // initial velocity
      PVector Vel0 = new PVector(0,0);
      // initial position
      PVector Pos0 = new PVector(random(padding+_r, padding+ancho-_r), random(altura+_r, altura+alto-_r));
      addParticle(i, Pos0, Vel0, m, r);
    }
  }

  void addParticle(int id, PVector initPos, PVector initVel, float mass, float radius) 
  {
    _particles.add(new Particle(this, id, initPos, initVel, mass, radius));
  }
  
  void restart()
  {
  }
  
  int getNumParticles()
  {
    return _n;
  }
  
  ArrayList<Particle> getParticleArray()
  {
    return _particles;
  }

  void run() 
  {
    for (int i = _n - 1; i >= 0; i--) 
    {
      Particle p = _particles.get(i);
      p.update();
    }
  }
  
  void computeCollisions(ArrayList<PlaneSection> planes, boolean computeParticleCollision) 
  { 
    for(int i = 0; i < _n; i++)
    {
      Particle p = _particles.get(i);
      if (computeParticleCollision){
        p.particleCollisionVelocityModel();
      }
      p.planeCollision(planes);
    }
  }

  void velocidadesRand(){
    for(int i = 0; i < _n; i++)
    {
      Particle p = _particles.get(i);
      PVector v = new PVector(random(-40,40), random(-40,40));
      p.setVel(v);
    }
  }
    
  void display() 
  {
    for (int i = _n - 1; i >= 0; i--) 
    {
      Particle p = _particles.get(i);      
      p.display();
    }    
  }
}
