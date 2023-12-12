class Grid 
{
  ArrayList<ArrayList<Particle>> _cells;
  color[] _colors;
  
  int _nRows; 
  int _nCols; 
  int _numCells;
  float _cellSize;
  
  Grid(int rows, int cols) 
  {
    _cells = new ArrayList<ArrayList<Particle>>();

    _nRows = rows;
    _nCols = cols;
    _numCells = _nRows*_nCols;
    _cellSize = width/_nRows;
    
    _colors = new color[_numCells];
    
    for (int i = 0; i < _numCells; i++) 
    {
      ArrayList<Particle> cell = new ArrayList<Particle>();
      _cells.add(cell);

      _colors[i] = color(int(random(0,256)), int(random(0,256)), int(random(0,256)), 150);
    }
  }

  int getCelda(PVector pos)
  {
    int celda = 0;
    int fila = int(pos.y / _cellSize);
    int columna = int(pos.x / _cellSize);
    
    celda = fila*_nCols + columna;
    
    if (celda < 0 || celda >= grid._cells.size())
    {
      return 0;
    }
    else
      return celda;
  }
  
  ArrayList<Particle> getVecindario(Particle p){
    int celda = getCelda(p._s);
    ArrayList<Particle> vecinos = new ArrayList<Particle>();
    // IntList celdas_vecinas = new IntList();

    int fila = int(celda / _nCols);
    int columna = celda % _nCols;
    
    // top cell
    if (fila > 0) vecinos.addAll(_cells.get(celda - _nCols));
    // bottom cell
    if (fila < _nRows-1) vecinos.addAll(_cells.get(celda + _nCols));
    // left cell
    if (columna > 0) vecinos.addAll(_cells.get(celda-1));
    // right cell
    if (columna < _nCols-1) vecinos.addAll(_cells.get(celda+1));
    // same cell
    vecinos.addAll(_cells.get(celda));
    
    // for (int i = 0; i < celdas_vecinas.size(); i++){
    //   int tam = _cells.get(celdas_vecinas.get(i)).size();
    //   for (int j = 0; j < tam; j++){
    //     vecinos.add(_cells.get(celdas_vecinas.get(i)).get(j));
    //   }
    // }
    
    return vecinos;
  }
  
  void insert(Particle p){
    _cells.get(getCelda(p._s)).add(p);
  }
  
  void restart()
  {
    for(int i = 0; i < grid._cells.size(); i++)
    {
      _cells.get(i).clear();
    }
  }
  
  color getColor(PVector pos){
    return _colors[getCelda(pos)];
  }

  void display()
  {
    if (MUESTRA){
      strokeWeight(1);
      stroke(250);
      
      for(int i = 0; i < _nRows; i++)
      {
        line(0, i*_cellSize, width, i*_cellSize); // horizontal lines
        line(i*_cellSize, 0, i*_cellSize, height); // vertical lines
      }
    }
  }
}
