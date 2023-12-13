public class DampedSpring
{
  Particle _p1;   // First particle attached to the spring
  Particle _p2;   // Second particle attached to the spring

  float _Ke;   // Elastic constant (N/m) 
  float _Kd;   // Damping coefficient (kg/m)

  float _lr;   // Rest length (m)
  float _l;    // Current length (m)
  float _lMax; // Maximum allowed distance before breaking apart (m)
  float _v;    // Current rate of change of length (m/s)

  PVector _e;   // Current elongation vector (m)
  PVector _eN;  // Current normalized elongation vector (no units)
  PVector _F;   // Force applied by the spring on particle 1 (the force on particle 2 is -_F) (N)
  float _FMax;  // Maximum allowed force before breaking apart (N)

  boolean _broken;   // True when the spring is broken 
  boolean _repulsionOnly;   // True if the spring only works one way (repulsion only)


  DampedSpring(Particle p1, Particle p2, float Ke, float Kd, boolean repulsionOnly, float maxForce, float maxDist)
  {
    _p1 = p1;
    _p2 = p2;

    _Ke = Ke;
    _Kd = Kd;

    _e = PVector.sub(_p2.getPosition(), _p1.getPosition());
    _eN = _e.copy();
    _eN.normalize();

    _l = _e.mag();
    _lr = _l; 

    _FMax = maxForce;
    _lMax = maxDist;

    _v = 0.0;
    _broken = false;
    _repulsionOnly = repulsionOnly;

    _F = new PVector(0.0, 0.0, 0.0);
  }

  Particle getParticle1()
  {
    return _p1;
  }
  
  Particle getParticle2()
  {
    return _p2;
  }
  
  void setRestLength(float restLength)
  {
    _lr = restLength;
  }
  
  void update(float simStep)
  {
    /*  This method should update all variables of the class
        that change as the simulation progresses (_e, _l, _v, _F, etc.),
        following the equations of a spring with linear damping
        between two particles.
     */
     
    _F.set(0,0,0);
    // If it is broken no updates
    if (_broken) return;

    float l_aux = _l; // longitud anterior

    // calcular distancia entre particulas
    _e = PVector.sub(_p2.getPosition(), _p1.getPosition());
    _l = _e.mag();
    _eN = _e.copy();
    _eN.normalize();

    if (_repulsionOnly && _l > _lr) return;
    
    // damping calculation based on how quickly elongation changes
    _v = (_l - l_aux) / simStep; // elongation change per simulation step
    
    // calculate the force of repulsion
    
    _F.add(PVector.mult(PVector.mult(_eN.copy(), _l-_lr), _Ke));
    _F.add(PVector.mult(PVector.mult(_eN.copy(), _v), _Kd));
    
    // check that the distance is not greater than the distance or the force is greater than permitted
    if ((_l > _lMax || _F.mag() > _FMax) && !NET_IS_UNBREAKABLE && !_repulsionOnly) breakIt();
    // print("_l: " + _l + " _lMax: " + _lMax + " _F.mag(): " + _F.mag() + " _FMax: " + _FMax+"\n");
  }

  void applyForces()
  { 
    _p1.addExternalForce(_F);
    _p2.addExternalForce(PVector.mult(_F, -1.0));
  }

  boolean isBroken()
  {
    return _broken;
  }

  void breakIt()
  {
    _broken = true;
  }

  void fixIt()
  {
    _broken = false;
  }
}
