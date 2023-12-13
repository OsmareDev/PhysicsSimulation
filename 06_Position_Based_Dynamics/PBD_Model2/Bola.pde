public class Ball extends Particle
{
  float _r;     //Radius (m)
  color _color;   //Color (RGB)


  Ball(PVector s, PVector v, float m, float r, color c) 
  {
    super(s, v, m);
    
    _r = r;
    _color = c;
  }
  
  float getRadius()
  {
    return _r;
  }
  
  void print()
  {
    pushMatrix();
      stroke(_color);
      fill(_color);
      translate(1000*location.x,
                  -1000*location.y, // The sign is changed, because the px increases downwards
                  1000*location.z);
      sphereDetail(12);
      sphere(1000*_r);
    popMatrix();
  }
}
