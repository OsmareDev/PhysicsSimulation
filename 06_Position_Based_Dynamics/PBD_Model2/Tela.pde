

PBDSystem crea_tela(float alto,
    float ancho,
    float dens,
    int n_alto,
    int n_ancho,
    float stiffness,
    float display_size){
   
  int N = n_alto*n_ancho;
  float masa = dens*alto*ancho;
  PBDSystem tela = new PBDSystem(N,masa/N);
  
  float dx = ancho/(n_ancho-1.0);
  float dy = alto/(n_alto-1.0);
  
  int id = 0;
  for (int i = 0; i< n_ancho;i++){
    for(int j = 0; j< n_alto;j++){
      Particle p = tela.particles.get(id);
      //p.location.set(dx*i,dy*j,0); // vertical fabric
      p.location.set((-n_ancho*dx/2)+dx*i,0.25,(-n_alto*dy/2)+dy*j); // horizontal fabric
      p.display_size = display_size;

      id++;
    }
  }
  
  /**
   * I create distance restrictions. Only structure constraints are created here.
   * Shear and bending would be missing.
   */
  id = 0;

  for (int i = 0; i< n_ancho;i++){
    for(int j = 0; j< n_alto;j++){
      CreateDistanceRestrictions(id, i, j, n_alto, n_ancho, dx, dy, tela);
      CreateShearRestrictions(id, i, j, n_alto, n_ancho, tela);
      CreateBendRestrictions(id, i, j, n_alto, n_ancho, tela);

      id++;
    }
  }


  
  // We fix two corners
  /*
  id = n_alto-1;
  tela.particles.get(id).set_bloqueada(true); 
  
  id = N-1;
  tela.particles.get(id).set_bloqueada(true); 
  */
  
  /*
  id = 0;
  tela.particles.get(id).set_bloqueada(true); 

  id = N-n_alto;
  tela.particles.get(id).set_bloqueada(true); 
  */
  print("Tela creada con " + tela.particles.size() + " partículas y " + tela.constraints.size() + " restricciones."); 
  
  return tela;
}

void CreateDistanceRestrictions(int id,
                                int i,
                                int j,
                                int n_alto,
                                int n_ancho,
                                float dx,
                                float dy,
                                PBDSystem tela) {
  Particle p = tela.particles.get(id);

  if(i>0){
    Particle pLf = tela.particles.get(id - n_alto);
    Constraint c = new DistanceConstraint(p,pLf,dx,stiffness1);
    tela.add_constraint(c);
  }

  if(j>0){
    Particle pUp = tela.particles.get(id - 1);
    Constraint c = new DistanceConstraint(p,pUp,dy,stiffness1);
    tela.add_constraint(c);
  }
}

void CreateShearRestrictions(int id,
                             int i,
                             int j,
                             int n_alto,
                             int n_ancho,
                             PBDSystem tela) {
  Particle p = tela.particles.get(id);
  
  if (i > 0 && j > 0) {
    Particle pLf = tela.particles.get(id - n_alto);
    Particle pUp = tela.particles.get(id - 1);
    Constraint c = new ShearConstraint(p, pUp, pLf, stiffness2);
    tela.add_constraint(c);
  }

  if (i < n_ancho-1 && j > 0) {
    Particle pRt = tela.particles.get(id + n_alto);
    Particle pUp = tela.particles.get(id - 1);
    Constraint c = new ShearConstraint(p, pUp, pRt, stiffness2);
    tela.add_constraint(c);
  }

  if (i > 0 && j < n_alto-1) {
    Particle pLf = tela.particles.get(id - n_alto);
    Particle pDw = tela.particles.get(id + 1);
    Constraint c = new ShearConstraint(p, pDw, pLf, stiffness2);
    tela.add_constraint(c);
  }

  if (i < n_ancho-1 && j < n_alto-1) {
    Particle pRt = tela.particles.get(id + n_alto);
    Particle pDw = tela.particles.get(id + 1);
    Constraint c = new ShearConstraint(p, pDw, pRt, stiffness2);
    tela.add_constraint(c);
  }
}

void CreateBendRestrictions(int id,
                             int i,
                             int j,
                             int n_alto,
                             int n_ancho,
                             PBDSystem tela) {
  Particle p = tela.particles.get(id);

  if (i > 0 && i < n_ancho-1 && j > 0) {
    Particle pLf = tela.particles.get(id - n_alto);
    Particle pRt = tela.particles.get(id + n_alto);
    Particle pUp = tela.particles.get(id - 1);
    Constraint c = new BendConstraint(p, pUp, pLf, pRt, stiffness3);
    tela.add_constraint(c);
  }

  if (i > 0 && i < n_ancho-1 && j < n_alto-1) {
    Particle pLf = tela.particles.get(id - n_alto);
    Particle pRt = tela.particles.get(id + n_alto);
    Particle pDw = tela.particles.get(id + 1);
    Constraint c = new BendConstraint(p, pDw, pLf, pRt, stiffness3);
    tela.add_constraint(c);
  }

  if (j > 0 && j < n_alto-1 && i > 0) {
    Particle pLf = tela.particles.get(id - n_alto);
    Particle pUp = tela.particles.get(id - 1);
    Particle pDw = tela.particles.get(id + 1);
    Constraint c = new BendConstraint(p, pLf, pUp, pDw, stiffness3);
    tela.add_constraint(c);
  }

  if (j > 0 && j < n_alto-1 && i < n_ancho-1) {
    Particle pRt = tela.particles.get(id + n_alto);
    Particle pUp = tela.particles.get(id - 1);
    Particle pDw = tela.particles.get(id + 1);
    Constraint c = new BendConstraint(p, pRt, pUp, pDw, stiffness3);
    tela.add_constraint(c);
  }
}