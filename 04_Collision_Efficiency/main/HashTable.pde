class HashTable 
{
  ArrayList<ArrayList<Particle>> _table;
  
  int _numCells;
  float _cellSize;
  color[] _colors;
  
  HashTable(int numCells, float cellSize) 
  {
    _table = new ArrayList<ArrayList<Particle>>();
    
    _numCells = numCells; 
    _cellSize = cellSize;

    _colors = new color[_numCells];
    
    for (int i = 0; i < _numCells; i++)
    {
      ArrayList<Particle> cell = new ArrayList<Particle>();
      _table.add(cell);
      _colors[i] = color(int(random(0,256)), int(random(0,256)), int(random(0,256)), 150);
    }
  }
  
  void insert(Particle p)
  {
    _table.get(hash(p._s)).add(p);
  }
  
  ArrayList<Particle> getVecindario(Particle p){
    ArrayList<Particle> vecinos = new ArrayList<Particle>();
    
    // Up
    if (p._s.y > _cellSize) vecinos.addAll(_table.get(hash(new PVector(p._s.x, p._s.y-_cellSize))));  
    // Down
    if (p._s.y < DISPLAY_SIZE_Y-_cellSize) vecinos.addAll(_table.get(hash(new PVector(p._s.x, p._s.y+_cellSize)))); 
    // Left
    if (p._s.x > _cellSize) vecinos.addAll(_table.get(hash(new PVector(p._s.x-_cellSize, p._s.y)))); 
    // Right
    if (p._s.x < DISPLAY_SIZE_X-_cellSize) vecinos.addAll(_table.get(hash(new PVector(p._s.x+_cellSize, p._s.y)))); 
    // Same cell
    vecinos.addAll(_table.get(hash(p._s)));
    
    return vecinos;
  }
  
  void restart()
  {
    for(int i = 0; i < _table.size(); i++){
      _table.get(i).clear();
    }
  }
  
  color getColor(PVector pos){
    return _colors[hash(pos)];
  }

  int hash (PVector pos)
  {
    int xd = (int)floor((float)pos.x/_cellSize);
    int yd = (int)floor((float)pos.y/_cellSize);
    return ((3 * xd + 5 * yd)) % _table.size();
  }
}