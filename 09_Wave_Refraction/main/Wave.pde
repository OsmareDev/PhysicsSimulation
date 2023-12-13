abstract class Wave 
{
  PVector _srcDir;
  float _L;
  float _T;
  float _A;
  float _C;
  float _W;
  float _K;
  float _phi;
  float _Q;
  ArrayList<PVector> onda;
  float _D, _D1, _D2;
  float ang;
  float _temp, _temp1 = 0.0, _temp2 = 0.0;
  ArrayList<Wave> extra;
  
  Boolean r1 = false, r2 = false;
  
  Wave (float a, float T, float L, PVector srcDir){
    _C = L/T;
    _A = a;
    _T = T;
    _W = 2 * PI/T;
    _L = L;
    _K = 2* PI / L;
    _srcDir = srcDir;
    _phi = T * 2 * PI;
    _Q = PI*a*_K; // Q_media
    _temp = millis()/1000f;
    ang = radians(90)-asin(L/_TAM_REJA); // difraction angle
    
    extra = new ArrayList<>();
  }
  
  abstract PVector evaluate(float t, PVector punto);
}

class DirectionalWave extends Wave {
  public DirectionalWave(float a, float T, float L, PVector srcDir){
    super(a, T, L, srcDir);
  }
  
  PVector evaluate(float t, PVector punto){
    PVector res = new PVector (punto.x, punto.y, punto.z);
    _D += t * _W/_K;
    
    _srcDir.normalize();
    res.y = _A * sin ((2 * PI / _L) * (PVector.dot(_srcDir, new PVector(punto.x, 0, punto.z))+ _W/_K * t));
    res.x = 0;
    res.z = 0;
    return res;
  }
}

class RadialWave extends Wave {
  public RadialWave(float a, float T, float L, PVector srcDir){
    super(a, T, L, srcDir);
  }
  
  PVector evaluate(float t, PVector punto){
    _D = (((t-_temp)+2) * _W/_K);
    _D1 = (((t-_temp1)+1.5) * _W/_K);
    _D2 = (((t-_temp2)+1.5) * _W/_K);
    
    PVector res = new PVector (punto.x, punto.y, punto.z);
    res.y = 0;
    if (PVector.dist(punto, _srcDir) < _D && punto.z > 0){
      res.y = _A * sin((2*PI/_L) * (PVector.dist(_srcDir, new PVector(punto.x, 0, punto.z)) - _W/_K * (t-_temp+2)));
    }
    else{
      if (punto.z < 0)
      {
        if (r1 && PVector.dist(punto, rendija1) < _D1 && (PVector.angleBetween(PVector.sub(new PVector(punto.x, 0, punto.z), rendija1),PVector.sub(rendija2, rendija1)) > ang && PVector.angleBetween(PVector.sub(new PVector(punto.x, 0, punto.z), rendija1),PVector.sub(rendija2, rendija1)) < PI-ang))
          res.y += _A * sin((2*PI/_L) * (PVector.dist(rendija1, new PVector(punto.x, 0, punto.z)) - _W/_K * (t-_temp1+1.5)));
          
        if (r2 && PVector.dist(punto, rendija2) < _D2 && (PVector.angleBetween(PVector.sub(new PVector(punto.x, 0, punto.z), rendija2),PVector.sub(rendija1, rendija2)) > ang && PVector.angleBetween(PVector.sub(new PVector(punto.x, 0, punto.z), rendija2),PVector.sub(rendija1, rendija2)) < PI-ang))
          res.y += _A * sin((2*PI/_L) * (PVector.dist(rendija2, new PVector(punto.x, 0, punto.z)) - _W/_K * (t-_temp2+1.5)));
      }
    }
    
    if (_D > PVector.dist(rendija1, _srcDir) && !r1){
      _temp1 = millis()/1000f;
      r1 = true;
    }
    
    if (_D > PVector.dist(rendija1, _srcDir) && !r2){
      _temp2 = millis()/1000f;
      r2 = true;
    }
    
    res.x = 0;
    res.z = 0;
    return res;
  }
}

class GerstnerWave extends Wave {
  public GerstnerWave(float a, float T, float L, PVector srcDir){
    super(a, T, L, srcDir);
    _srcDir.normalize();
  }
  
  PVector evaluate(float t, PVector punto){
    PVector res = new PVector (punto.x, punto.y, punto.z);
    
    res.x = -_Q * _A * _srcDir.x * cos((2 * PI / _L) * (PVector.dot(_srcDir, new PVector(punto.x, 0, punto.z))+ _W/_K * t));
    res.y = _A * sin ((2 * PI / _L) * (PVector.dot(_srcDir, new PVector(punto.x, 0, punto.z))+ _W/_K * t));
    res.z = -_Q * _A * _srcDir.z * cos((2 * PI / _L) * (PVector.dot(_srcDir, new PVector(punto.x, 0, punto.z))+ _W/_K * t));

    return res;
  }
}
