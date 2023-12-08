public class FireWorks 
{
  ArrayList<Rocket> _rockets;

  FireWorks() 
  {
    _rockets = new ArrayList<Rocket>();
  }
  
  void addRocket(RocketType type, PVector pos, PVector vel, color c)
  {
    // Código para añadir un cohete a la simulación
    _rockets.add(new Rocket(type, pos, vel, c));
  }
  
  int getNumRockets()
  {
    return _rockets.size();
  }
  
  void run()
  {
    for (int i = 0; i < _rockets.size(); i++)
    {
      Rocket r = _rockets.get(i);
      r.run();
    }
    
    _simTime += SIM_STEP;    
  }
}
