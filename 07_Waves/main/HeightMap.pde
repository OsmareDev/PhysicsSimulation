public class HeightMap 
{
  private float _Cellsize;
  private int _n_rows;
  
  private PVector mapa[][];
  private PVector initValues[][];
  private float base;
  private PVector textura[][];
  private PVector esquina;
  
  ArrayList<Wave> waves;
  
  HeightMap (float tamCell, int n_rows){
    _Cellsize = tamCell;
    _n_rows = n_rows;
    base = 200;
    
    waves = new ArrayList<Wave>();
    
    mapa = new PVector[_n_rows][_n_rows];
    initValues = new PVector[_n_rows][_n_rows];
    textura = new PVector[_n_rows][_n_rows];
    esquina = new PVector(-(_n_rows*_Cellsize)/2, -(_n_rows*_Cellsize)/2, 0);
    
    iniciaMapa();
  }
  
  void iniciaMapa(){
    for (int i = 0; i < _n_rows; i++){
      for (int j = 0; j < _n_rows; j++){
        mapa[j][i] = new PVector(esquina.x+j*_Cellsize, base, esquina.y+i*_Cellsize);
        initValues[j][i] = new PVector(esquina.x+j*_Cellsize, base, esquina.y+i*_Cellsize);
        textura[j][i] = new PVector(j*img.width/(float)_n_rows, base, i*img.height/(float)_n_rows);
      }
    }
  }

  void iniciaTextura(){
    for (int i = 0; i < _n_rows; i++){
      for (int j = 0; j < _n_rows; j++){
        
        
      }
    }
  }
  
  void display(){
    for (int i = 0; i < _n_rows; i++){
      for (int j = 0; j < _n_rows; j++){
        stroke(0);
        if (j < _n_rows-1)
          line(mapa[j][i].x, mapa[j][i].y, mapa[j][i].z, mapa[j+1][i].x, mapa[j+1][i].y, mapa[j+1][i].z); // to the right
        if (i < _n_rows-1)
          line(mapa[j][i].x, mapa[j][i].y, mapa[j][i].z, mapa[j][i+1].x, mapa[j][i+1].y, mapa[j][i+1].z); // down
         if (j < _n_rows-1 && i < _n_rows-1)
          line(mapa[j][i].x, mapa[j][i].y, mapa[j][i].z, mapa[j+1][i].x, mapa[j+1][i+1].y, mapa[j+1][i+1].z); // down right
      }
    }
  }
  
  void displayTextured(){
    noStroke();
    for (int i = 0; i < _n_rows-1; i++) {
      beginShape(QUAD_STRIP);
      texture(img);
      for (int j = 0; j < _n_rows; j++) {
        vertex(mapa[j][i].x, mapa[j][i].y, mapa[j][i].z, textura[j][i].x, textura[j][i].z);
        vertex(mapa[j][i+1].x, mapa[j][i+1].y, mapa[j][i+1].z, textura[j][i+1].x, textura[j][i].z);
      }
      endShape();
    }
  }
  
  void addWave(float a, float T, float L, PVector srcDir, int mode){
    if (mode == 1)
      waves.add(new DirectionalWave(a, T, L, srcDir));
    if (mode == 2)
      waves.add(new RadialWave(a, T, L, srcDir));
    if (mode == 3)
      waves.add(new GerstnerWave(a, T, L, srcDir));
  }
  
  void update (){
    float time = millis()/1000f;
    
    for (int i = 0; i < _n_rows; i++){
      for (int j = 0; j < _n_rows; j++){
        // reset positions
        mapa[j][i].y = base;
        mapa[j][i].x = initValues[j][i].x;
        mapa[j][i].z = initValues[j][i].z;
        
        for (int k = 0; k < waves.size(); k++){
          Wave w = waves.get(k);
          mapa[j][i].x += w.evaluate(time, mapa[j][i]).x;
          mapa[j][i].y += w.evaluate(time, mapa[j][i]).y;
          mapa[j][i].z += w.evaluate(time, mapa[j][i]).z;
        }
      }
    }
  }
  
  void reset(){
    waves.clear();
  }
}
