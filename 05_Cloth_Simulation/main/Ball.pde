public class Ball extends Particle
{
  float _r;     // Radius (m)
  color _color;   // Color (RGB)


  Ball(PVector s, PVector v, float m, float r, color c) 
  {
    super(s, v, m, false);
    
    _r = r;
    _color = c;
  }
  
  float getRadius()
  {
    return _r;
  }
  
  void draw()
  {
    pushMatrix();
    {
       translate(_s.x, _s.y, _s.z);
       fill(_color);
       stroke(0);
       sphereDetail(20);
       sphere(_r); 
    }
    popMatrix();
  }
}
