static int _lastParticleId = 0;

public class Particle 
{
  int _id;    // Unique id for each particle
  
  float _k = 0.05; // air resistance
  PVector _s;   // Position (m)
  PVector _v;   // Velocity (m/s)
  PVector _a;   // Acceleration (m/(s*s))
  PVector _F;   // Force (N)
  float _m;     // Mass (kg)
  boolean _clamped;   // If true, the particle will not move


  Particle(PVector s, PVector v, float m, boolean clamped) 
  {
    _id = _lastParticleId++;
    
    _s = s.copy();
    _v = v.copy();
    _m = m;
    _clamped = clamped;
    
    _a = new PVector(0.0, 0.0, 0.0);
    _F = new PVector(0.0, 0.0, 0.0);
  }

  void update(float simStep) 
  {
    if (_clamped)
      return;

    updateForce();

    // Simplectic Euler:
    // v(t+h) = v(t) + h*a(s(t),v(t))
    // s(t+h) = s(t) + h*v(t+h)

    _a = PVector.div(_F, _m);
    _v.add(PVector.mult(_a, simStep));  
    _s.add(PVector.mult(_v, simStep));  

    _F.set(0.0, 0.0, 0.0);
  }
  
  int getId()
  {
    return _id;
  }
  
  PVector getPosition()
  {
    return _s;
  }
  
  void setPosition(PVector s)
  {
    _s = s.copy();
    _a.set(0.0,0.0,0.0);
    _F.set(0.0,0.0,0.0);
  }
  
  void setVelocity(PVector v)
  {
    _v = v.copy();
  }

  void updateForce()
  {
    PVector weigthForce = PVector.mult(G, _m);
    _F.add(weigthForce);
    
    PVector airResistance = PVector.mult(_v, -_k);
    //_F.add(airResistance);
  }
  
  void addExternalForce(PVector F)
  {
    _F.add(F);
  }
}
