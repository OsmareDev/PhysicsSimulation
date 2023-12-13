import java.util.TreeMap;

public class DeformableSurface 
{
  float _lengthX;   // Length of the surface in X direction (m)
  float _lengthY;   // Length of the surface in Y direction (m)
  
  int _numNodesX;   // Number of nodes in X direction
  int _numNodesY;   // Number of nides in Y direction

  SpringLayout _springLayout;  // Physical layout of the springs that define the surface
  boolean _isUnbreakable;   // True if the surface cannot be broken
  color _color;   // Color (RGB)

  Particle[][] _nodes;   // Particles defining the surface
  ArrayList<DampedSpring> _springsSurface;   // Springs joining the particles
  TreeMap<String, DampedSpring> _springsCollision;   // Springs for collision handling


  DeformableSurface(float lengthX, float lengthY, int numNodesX, int numNodesY, float surfacePosZ, float nodeMass, float Ke, float Kd, float maxForce, float breakLengthFactor, SpringLayout springLayout, boolean isUnbreakable, color c)
  {
    _lengthX = lengthX;
    _lengthY = lengthY;

    _numNodesX = numNodesX;
    _numNodesY = numNodesY;
    
    _springLayout = springLayout;
    _isUnbreakable = isUnbreakable;
    _color = c;

    _nodes = new Particle[_numNodesX][_numNodesY];
    _springsSurface = new ArrayList();
    _springsCollision = new TreeMap<String, DampedSpring>();

    createNodes(surfacePosZ, nodeMass);
    createSurfaceSprings(Ke, Kd, maxForce, breakLengthFactor);
  }

  void createNodes(float surfacePosZ, float nodeMass)
  {
    /* This method should give values to the vector of nodes ('_nodes') based on the
        size of the mesh and its properties (number of nodes,
        mass thereof, etc.).
     */
     
     for (int i = 0; i < _numNodesY; i++){
        for (int j = 0; j < _numNodesX; j++){
          PVector pos = new PVector(j*(_lengthX/_numNodesX)-_lengthX/2, i*(_lengthY/_numNodesY)-_lengthY/2, surfacePosZ);
          PVector vel = new PVector(0,0,0);
          Boolean clamp = (i == 0 || i == _numNodesY-1 || j == 0 || j == _numNodesX-1);
          
          _nodes[j][i] = new Particle(pos, vel, nodeMass, clamp);
       }
     }
  }

  void createSurfaceSprings(float Ke, float Kd, float maxForce, float breakLengthFactor)
  {
    /* This method should add springs to the mesh's spring list ('_springsSurfaces')
        depending on the desired arrangement for these within the mesh, and the parameters
        of the springs (Ke, Kd, etc.).
     */
     
     switch(_springLayout)
     {
       case STRUCTURAL:
          createStruct(Ke, Kd, maxForce, breakLengthFactor);
       break;
       
       case SHEAR:
          createShear(Ke, Kd, maxForce, breakLengthFactor);
       break;
       
       case STRUCTURAL_AND_SHEAR:
          createStructShear(Ke, Kd, maxForce, breakLengthFactor);
       break;
       
       case STRUCTURAL_AND_BEND:
         createStructBend(Ke, Kd, maxForce, breakLengthFactor);
       break;
       
       case STRUCTURAL_AND_SHEAR_AND_BEND:
         createStructShearBend(Ke, Kd, maxForce, breakLengthFactor);
       break;
     }
  }

  void update(float simStep)
  {
    int i, j;

    for (i = 0; i < _numNodesX; i++)
      for (j = 0; j < _numNodesY; j++)
        if (_nodes[i][j] != null)
          _nodes[i][j].update(simStep);

    for (DampedSpring s : _springsSurface) 
    {
      s.update(simStep);
      s.applyForces();
    }

    for (DampedSpring s : _springsCollision.values()) 
    {
      s.update(simStep);
      s.applyForces();
    }
  }

  void createStruct(float Ke, float Kd, float maxForce, float breakLengthFactor)
  {
    for (int i = 0; i < _numNodesY; i++){
      for (int j = 0; j < _numNodesX; j++){
        if (j < _numNodesX-1)
          _springsSurface.add(new DampedSpring(_nodes[j][i], _nodes[j+1][i], Ke, Kd, false, maxForce, breakLengthFactor));
        if (i < _numNodesY-1)
          _springsSurface.add(new DampedSpring(_nodes[j][i], _nodes[j][i+1], Ke, Kd, false, maxForce, breakLengthFactor));
      }
    }
  }

  void createShear(float Ke, float Kd, float maxForce, float breakLengthFactor)
  {
    for (int i = 0; i < _numNodesY-1; i++){
      for (int j = 0; j < _numNodesX; j++){
        if (j != 0)
          _springsSurface.add(new DampedSpring(_nodes[j][i], _nodes[j-1][i+1], Ke, Kd, false, maxForce, breakLengthFactor));
        if (j != _numNodesX-1)
          _springsSurface.add(new DampedSpring(_nodes[j][i], _nodes[j+1][i+1], Ke, Kd, false, maxForce, breakLengthFactor));
      }
    }
  }

  void createBend(float Ke, float Kd, float maxForce, float breakLengthFactor)
  {
    for (int i = 0; i < _numNodesY; i++){
      for (int j = 0; j < _numNodesX; j++){
        if (j < _numNodesX-2)
          _springsSurface.add(new DampedSpring(_nodes[j][i], _nodes[j+2][i], Ke, Kd, false, maxForce, breakLengthFactor));
        if (i < _numNodesY-2)
          _springsSurface.add(new DampedSpring(_nodes[j][i], _nodes[j][i+2], Ke, Kd, false, maxForce, breakLengthFactor));
      }
    }
  }

  void createStructShear(float Ke, float Kd, float maxForce, float breakLengthFactor)
  {
    createStruct(Ke, Kd, maxForce, breakLengthFactor);
    createShear(Ke, Kd, maxForce, breakLengthFactor);
  }

  void createStructBend(float Ke, float Kd, float maxForce, float breakLengthFactor)
  {
    createStruct(Ke, Kd, maxForce, breakLengthFactor);
    createBend(Ke, Kd, maxForce, breakLengthFactor);
  }
  
  void createStructShearBend(float Ke, float Kd, float maxForce, float breakLengthFactor)
  {
    createStruct(Ke, Kd, maxForce, breakLengthFactor);
    createShear(Ke, Kd, maxForce, breakLengthFactor);
    createBend(Ke, Kd, maxForce, breakLengthFactor);
  }

  void avoidCollision(Ball b, float Ke, float Kd, float maxForce, float breakLengthFactor)
  {
    /* This method should avoid collision between the sphere and the deformable mesh. For it
        collision springs should be created when a collision is detected. These springs
        They will be stored in the '_springsCollision' dictionary. To prevent springs from being created
        duplicates, the dictionary allows you to check if a dock already exists previously and
        so use it instead of creating a new one.
     */

     // collision with the ball

     for (int i = 0; i < _numNodesY; i++){
       for (int j = 0; j < _numNodesX; j++){
         // If the distance with the ball is enough, a spring is created
         if (_nodes[j][i].getPosition().dist(_ball.getPosition()) < _ball.getRadius())
         {
           if (!_springsCollision.containsKey(_nodes[j][i].getId()+";")){
             _springsCollision.put(_nodes[j][i].getId()+";", new DampedSpring(_ball, _nodes[j][i], Ke, Kd, true, maxForce, breakLengthFactor));
              // print("se crea muelle");
           }
         }
         else {
           _springsCollision.remove(_nodes[j][i].getId()+";");
         }
       }
     }
  }
 
  void draw()
  {
    if (_isUnbreakable) 
        drawWithQuads();
    else
        drawWithSegments();
  }
 
  void drawWithQuads()
  {
    int i, j;
    
    fill(255);
    stroke(_color);
 
    for (j = 0; j < _numNodesY - 1; j++)
    {
      beginShape(QUAD_STRIP);
      for (i = 0; i < _numNodesX; i++)
      {
        if ((_nodes[i][j] != null) && (_nodes[i][j] != null))
        {
          PVector pos1 = _nodes[i][j].getPosition();
          PVector pos2 = _nodes[i][j+1].getPosition();
 
          vertex(pos1.x, pos1.y, pos1.z);
          vertex(pos2.x, pos2.y, pos2.z);
        }
      }
      endShape();
    }
  }
 
  void drawWithSegments()
  {
    stroke(_color);
 
    for (DampedSpring s : _springsSurface) 
    {
      if (!s.isBroken())
      {
        PVector pos1 = s.getParticle1().getPosition();
        PVector pos2 = s.getParticle2().getPosition();
 
        line(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z);
      }
    }
  }
}
