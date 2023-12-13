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
  }
  
  abstract PVector evaluate(float t, PVector punto);
}

class DirectionalWave extends Wave {
  public DirectionalWave(float a, float T, float L, PVector srcDir){
    super(a, T, L, srcDir);
  }
  
  PVector evaluate(float t, PVector punto){
    PVector res = new PVector (punto.x, punto.y, punto.z);
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
    PVector res = new PVector (punto.x, punto.y, punto.z);
    res.y = _A * sin((2*PI/_L) * (PVector.dist(_srcDir, punto) - _W/_K * t));
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
    
    res.x = -_Q * _A * _srcDir.x * cos((2 * PI / _L) * (PVector.dot(_srcDir, new PVector(punto.x, 0, punto.z))- _W/_K * t));
    res.y = _A * sin ((2 * PI / _L) * (PVector.dot(_srcDir, new PVector(punto.x, 0, punto.z))+ _W/_K * t));
    res.z = -_Q * _A * _srcDir.z * cos((2 * PI / _L) * (PVector.dot(_srcDir, new PVector(punto.x, 0, punto.z))- _W/_K * t));

    return res;
  }
}
