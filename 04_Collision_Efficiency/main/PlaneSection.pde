class PlaneSection 
{ 
  PVector _pos1;
  PVector _pos2;
  PVector _normal;
  float[] _coefs = new float[4];
  
  PVector P1;
  PVector P2;
  
  // Constructor to make a plane from two points (assuming Z = 0)
  // The two points define the edges of the finite plane section
  PlaneSection(float x1, float y1, float x2, float y2, boolean invert) 
  {
    _pos1 = new PVector(x1, y1);
    _pos2 = new PVector(x2, y2);
    
    setCoefficients();
    calculateNormal(invert);
    
    P1 = new PVector(0,0);
    P2 = new PVector(0,0);

    // P1.y = (A.y >= B.y) ? A.y : B.y;
    // P1.x = (A.x <= B.x) ? A.x : B.x;

    if (_pos1.y <= _pos2.y){
      P1.y = _pos1.y;
      P2.y = _pos2.y;
    } else {
      P1.y = _pos2.y;
      P2.y = _pos1.y;
    }

    if (_pos1.x <= _pos2.x){
      P1.x = _pos1.x;
      P2.x = _pos2.x;
    } else {
      P1.x = _pos2.x;
      P2.x = _pos1.x;
    }
  } 
  
  PVector getPoint1()
  {
    return _pos1;
  }
 
  PVector getPoint2()
  {
    return _pos2;
  }
  
  public Boolean isInside(PVector c){
    /*
    if (c.x > _pos2.x && c.x < _pos1.x && c.y < _pos2.y && c.y > _pos1.y)
      return true;
      
    if (c.x > _pos1.x && c.x < _pos2.x && c.y > _pos1.y && c.y < _pos2.y)
      return true;
    */
    
    if (c.x > P1.x && c.y > P1.y && c.x < P2.x && c.y < P2.y) return true;
    
    if (_pos1.x == _pos2.x) // VERTICAL
    {
      if(abs(c.x-_pos1.x) < r_part*3)
        return true;
    } else { // HORIZONTAL
      if(abs(c.y-_pos1.y) < r_part*3)
        return true;
    } 
    
    return false;
  }
  
  void setCoefficients()
  {
    PVector v = new PVector(_pos2.x - _pos1.x, _pos2.y - _pos1.y, 0.0);
    PVector z = new PVector(_pos2.x - _pos1.x, _pos2.y - _pos1.y, 1.0);
    
    _coefs[0] = v.y*z.z - z.y*v.z;
    _coefs[1] = -(v.x*z.z - z.x*v.z);
    _coefs[2] = v.x*z.y - z.x*v.y;
    _coefs[3] = -_coefs[0]*_pos1.x - _coefs[1]*_pos1.y - _coefs[2]*_pos1.z;
  }
  
  void calculateNormal(boolean inverted)
  {
    _normal = new PVector(_coefs[0], _coefs[1], _coefs[2]);
    _normal.normalize();
    
    if (inverted)
      _normal.mult(-1);
  }
  
  float getDistance(PVector p)
  {
    float d = (_coefs[0]*p.x + _coefs[1]*p.y + _coefs[2]*p.z + _coefs[3]) / (sqrt(_coefs[0]*_coefs[0] + _coefs[1]*_coefs[1] + _coefs[2]*_coefs[2]));
    return abs(d);
  }
  
  PVector getNormal()
  {
    return _normal;
  }

  void draw() 
  {
    
    stroke(200);
    strokeWeight(5);
    
    // Plane representation:
    line(_pos1.x, _pos1.y, _pos2.x, _pos2.y); 
    
    float cx = _pos1.x*0.5 + _pos2.x*0.5;
    float cy = _pos1.y*0.5 + _pos2.y*0.5;

    // Normal vector representation:
    line(cx, cy, cx + 5.0*_normal.x, cy + 5.0*_normal.y);    
  }
} 