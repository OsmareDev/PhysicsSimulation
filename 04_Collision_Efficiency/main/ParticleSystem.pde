class ParticleSystem 
{
  ArrayList<Particle> _particles;
  int _n;
  int _cols;
  int _rows;
  

  ParticleSystem(int n)  
  {
    _particles = new ArrayList<Particle>();
    _n = n;
    _cols = ((width-5*padding)/(r_part*2));
    float sobrante = n%_cols;
    _rows = n/_cols;
    
    PVector Pos0 = new PVector(2.5*padding, 1.5*padding);
    PVector Vel0 = new PVector(0, 0);
    int ID = 0;
    //add a bunch of initial particles
    for (int i = 0; i < _rows; i++){      
      for(int j = 0; j < _cols ; j++){   
        PVector pos = new PVector(Pos0.x+j*r_part*2, Pos0.y+i*r_part*2);
        
        addParticle(ID, pos, Vel0, m_part, r_part);
        ID++;
      }
    }
    if (sobrante > 0){
      for (int i = 0; i < sobrante; i++){
        PVector pos = new PVector(Pos0.x+i*r_part*2, Pos0.y+_rows*r_part*2);
        addParticle(ID, pos, Vel0, 10, r_part);
        ID++;
      }
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
    time_estructuras = millis();
    actualizarEstructura();
    time_estructuras = millis() - time_estructuras;

    time_integracion = millis();
    updateParticles();
    time_integracion = millis() - time_integracion;
  }
  
  void actualizarEstructura()
  {
    if (type == EstructuraDatos.values()[1]) {
      // GRID
      grid.restart();
    } else if (type == EstructuraDatos.values()[2]) {
      // HASH
      hash.restart();
    }
    
    for (int i = _n - 1; i >= 0; i--) 
    {
      Particle p = _particles.get(i);

      if (isOutside(p)){
        _particles.remove(i);
        _n--;
          
        continue;
      }
      
      if (type == EstructuraDatos.values()[1]) {
        // GRID
        grid.insert(p);
      } else if (type == EstructuraDatos.values()[2]) {
        // HASH
        hash.insert(p);
      }
      
      //p.update(); 
    }
  }

  void updateParticles()
  {
    for (int i = _n - 1; i >= 0; i--) 
    {
      Particle p = _particles.get(i);
      p.update();
    }
  }

  Boolean isOutside(Particle p)
  {
    if (p._s.x < 0 || p._s.y <0 || p._s.y > height || p._s.x > width)
      return true;

    return false;
  }

  void computeCollisions(ArrayList<PlaneSection> planes, boolean computeParticleCollision) 
  { 
    for(int i = 0; i < _n; i++)
    {
      Particle p = _particles.get(i);
      p.particleCollisionSpringModel();
      p.planeCollision(planes);
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