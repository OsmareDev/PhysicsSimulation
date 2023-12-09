class PlaneSection 
{ 
  PVector _pos1;
  PVector _pos2;
  PVector _normal;
  float[] _coefs = new float[4];
  
  
  
  // Constructor to make a plane from two points (assuming Z = 0)
  // The two points define the edges of the finite plane section
  PlaneSection(float x1, float y1, float x2, float y2, boolean invert) 
  {
    _pos1 = new PVector(x1, y1);
    _pos2 = new PVector(x2, y2);
    
    setCoefficients();
    calculateNormal(invert);
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
    if(c.x-R_bolas < padding || c.x+R_bolas > padding+ancho || c.y+R_bolas < altura || c.y-R_bolas > altura+alto)
      return true;
      
    return false;
    */

    if (_pos1.x == _pos2.x) // VERTICAL
    {
      if(abs(c.x-_pos1.x) < R_bolas*3)
        return true;
    } else { // HORIZONTAL
      if(abs(c.y-_pos1.y) < R_bolas*3)
        return true;
    } 
    
    return false;
    
    /*
    if (c.x > _pos1.x && c.x < _pos2.x && c.y > _pos1.y && c.y < _pos2.y)
      return true;
      
    return false;
    */
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
    stroke(0, 0, 0);
    strokeWeight(5);
    
    // Plane representation:
    line(_pos1.x, _pos1.y, _pos2.x, _pos2.y); 
    
    float cx = _pos1.x*0.5 + _pos2.x*0.5;
    float cy = _pos1.y*0.5 + _pos2.y*0.5;

    // Normal vector representation:
    line(cx, cy, cx + 5.0*_normal.x, cy + 5.0*_normal.y);    
  }
} 
