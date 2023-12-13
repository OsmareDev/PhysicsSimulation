import java.util.TreeMap;

class PBDSystem {
  // System particles
  ArrayList<Particle> particles;
  ArrayList<Constraint> constraints;
  TreeMap<String, DistanceConstraint> _springsCollision;

  int niters;

  PBDSystem(int n,float mass) {
    particles = new ArrayList<Particle>(n);
    constraints = new ArrayList<Constraint>();
    _springsCollision = new TreeMap<String, DistanceConstraint>();
    
    niters = 5;
    
    PVector p = new PVector(0,0,0);
    PVector v = new PVector(0,0,0);

    for(int i=0;i<n;i++){
      particles.add(new Particle(p,v,mass));
    }
  }

  void set_n_iters(int n){
   niters = n;
   for(int i = 0; i < constraints.size()-1; i++)
     constraints.get(i).compute_k_coef(n);
  }

  void add_constraint(Constraint c){
     constraints.add(c);
     c.compute_k_coef(niters);
  }

  void apply_gravity(PVector g){
    Particle p;
    for(int i = 0 ; i<particles.size() ; i++){
      p = particles.get(i);
      if(p.w > 0) // If the mass at infinity, it does not apply
        p.force.add(PVector.mult(g,p.masa));
    }
  }

  void run(float dt) {
    //Simulation
    for (int i = 0; i < particles.size(); i++){
      //println(i);
      particles.get(i).update(dt);
    }

    for(int it = 0; it< niters; it++)
      for(int i = 0; i< constraints.size(); i++)
        constraints.get(i).proyecta_restriccion();

    for(int it = 0; it< niters; it++)
      for (DistanceConstraint c : _springsCollision.values()) 
      {
        c.proyecta_restriccion();
      }
     
    for (int i = 0; i < particles.size(); i++)
      particles.get(i).update_pbd_vel(dt);
  }

  void avoidCollision()
  {
    for (int i = 0; i < particles.size(); i++){
        // If the distance with the ball is enough to create a distance restriction
        if (particles.get(i).getLocation().dist(_ball.getLocation()) < _ball.getRadius())
        {
          if (!_springsCollision.containsKey((i)+";")){
            _springsCollision.put((i)+";", new DistanceConstraint(particles.get(i), _ball, _ball.getRadius(), 1));
          }
        }
        else {
          if (_springsCollision.containsKey((i)+";"))
            _springsCollision.remove((i)+";");
        }
     }
  }
}
