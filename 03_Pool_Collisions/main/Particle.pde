class Particle  //<>//
{
  ParticleSystem _ps;
  int _id;

  PVector _s;
  PVector _v;
  PVector _a;
  PVector _f;

  float _m;
  float _radius;
  color _color;
  
  final float k = 0.1;
  
  Particle(ParticleSystem ps, int id, PVector initPos, PVector initVel, float mass, float radius) 
  {
    _ps = ps;
    _id = id;

    _s = initPos.copy();
    _v = initVel.copy();
    _a = new PVector(0.0, 0.0);
    _f = new PVector(0.0, 0.0);

    _m = mass;
    _radius = radius;
    // always 0 green to contrast with the background
    _color = color(255*id/ps.getNumParticles(), 0, 255-255*id/ps.getNumParticles());
  }

  void update() 
  {  
    updateForce();
    PVector a = PVector.div(_f, _m);
    _v.add(PVector.mult(a, SIM_STEP));
    _s.add(PVector.mult(_v, SIM_STEP));
  }

  void updateForce()
  {  
    //Friction so that they stop
    PVector FRoz = PVector.mult(_v, -k);
    
    _f = FRoz.copy();

    if (gravedad)
      _f.add(Fg);
  }

  PVector getPos() {
    return _s;
  }

  float getRadius() {
    return _radius;
  }
  
  PVector getVel(){
    return _v;
  }
  
  void setVel(PVector vel) {
    _v = vel;
  }

  void planeCollision(ArrayList<PlaneSection> planes)
  { 
    for(int i = 0; i < planes.size(); i++)
    {
      PlaneSection p = planes.get(i);
      PVector N;
      
      if (p.isInside(_s)){
        
        // We don't need the side since they will always be locked in the table
        N = p.getNormal();
        
        PVector _PB = PVector.sub(_s, p.getPoint1());
        float dist = N.dot(_PB);
        
        if (abs(dist) < _radius){
          //we reposition the particle
          float mover = _radius-abs(dist);
          _s.add(PVector.mult(N, mover));          
          
          //Response to collision
          float nv = (N.dot(_v));
          PVector Vn = PVector.mult(N, nv);
          PVector vt = PVector.sub(_v, Vn);
          //we change the direction
          Vn.mult(-1);
          _v = PVector.add(vt, Vn);
        }
      }
    }
  } 

  void particleCollisionVelocityModel()
  {
    ArrayList<Particle> sistema = _ps.getParticleArray();
    
    for (int i = 0; i < sistema.size(); i++){
      // we verify that it does not verify itself
      if (_id != i)
      {
        Particle p = sistema.get(i);
        
        PVector dist = PVector.sub(p.getPos(), _s);
        float distValue = dist.mag();
        PVector normal = dist.copy();
        normal.normalize();
        
        if (distValue < p.getRadius()+_radius){ // detection

          // response
          PVector velNorm1 = PVector.mult(normal, PVector.dot(_v, normal));
          PVector velNorm2 = PVector.mult(normal, PVector.dot(p.getVel(), normal));

          PVector velTang1 = PVector.sub(_v, velNorm1);
          PVector velTang2 = PVector.sub(p.getVel(), velNorm2);
          
          //p._s.add(PVector.mult(velNorm2, L/v_rel));
          //float v_rel = PVector.sub(velNorm1, velNorm2).mag();
          // restitution
          float L = (p.getRadius()+_radius - distValue);
          _s.add(PVector.mult(normal, -L));
          
          //exit speeds
          float u1 = PVector.dot(velNorm1, dist)/distValue;
          float u2 = PVector.dot(velNorm2, dist)/distValue;
          
          float v1 = ((_m-_m)*u1+2*_m*u2)/(_m+_m);
          velNorm1 = PVector.mult(normal, v1);
          
          float v2 = ((_m - _m)*u2 + 2*_m*u1) / (_m+_m);
          velNorm2 = PVector.mult(normal, v2);
          
          _v = PVector.add(velNorm1.mult(0.5), velTang1);
          p._v = PVector.add(velNorm2.mult(0.5), velTang2);
        }
      }
    }
  }
  
  void display() 
  {
    noStroke();
    fill(_color);
    circle(_s.x, _s.y, 2.0*_radius);
  }
}
