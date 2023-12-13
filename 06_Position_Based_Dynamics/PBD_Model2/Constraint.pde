abstract class Constraint{

  ArrayList<Particle> particles;
  float stiffness;    // k in Mullers Paper
  float k_coef;       // k' in Mullers Paper
  float C;
  Boolean anulada;
  
  Constraint(){
    particles = new ArrayList<Particle>();
    anulada = false;
  }
  
  void  compute_k_coef(int n){
    k_coef = 1.0 - pow((1.0-stiffness),1.0/float(n));
    //println("Fijamos "+n+" iteraciones   -->  k = "+stiffness+"    k' = "+k_coef+".");
  }

  abstract void proyecta_restriccion();
  abstract void display(float scale_px);
}

class DistanceConstraint extends Constraint{

  float d;
  
  DistanceConstraint(Particle p1,Particle p2,float dist,float k){
    super();
    d = dist;
    particles.add(p1);
    particles.add(p2);
    stiffness = k;
    k_coef = stiffness;
    C=0;
  }
  
  /*
    
  */

  void proyecta_restriccion(){
    if (anulada) return;

    Particle part1 = particles.get(0); 
    Particle part2 = particles.get(1);
    
    float w1 = part1.w;
    float w2 = part2.w;

    if (w1+w2 < 1e-8) return; // both are blocked

    PVector vd = PVector.sub(part1.location,part2.location);
    
    // If we do not know where to correct, we do not correct
    if (vd.mag() < 1e-8) return;
    PVector n = PVector.div(vd,vd.mag());

    // error
    C = vd.mag() - d;
    if (C/d > 0.3) {
      //anulada = true;
      //return;
    }

    PVector delta = PVector.mult(n,C/(w1+w2));

    part1.location.add(PVector.mult(delta,-w1*k_coef));
    part2.location.add(PVector.mult(delta,w2*k_coef));

    if(debug){
      println("PROYECTA: p1="+part1.location);
      println("PROYECTA: p2="+part2.location);
      println("PROYECTA: p1-p2="+vd);
      println("PROYECTA: n="+n);
    }
    
  }
  
  void display(float scale_px){
    if (anulada) return;

    PVector p1 = particles.get(0).location; 
    PVector p2 = particles.get(1).location; 
    strokeWeight(3);
    stroke(255,255*(1-abs(4*C/d)),255*(1-abs(4*C/d)));
    line(scale_px*p1.x, -scale_px*p1.y, scale_px*p1.z,  scale_px*p2.x, -scale_px*p2.y, scale_px*p2.z);
  };
  
}

class ShearConstraint extends Constraint{
  
  float h0;
  PVector cen;
  
  ShearConstraint(Particle p1,Particle p2,Particle p3,float k){
    super();
    particles.add(p1);
    particles.add(p2);
    particles.add(p3);

    cen = PVector.div(PVector.add(PVector.add(p1.location, p2.location), p3.location),3);
    h0 = PVector.sub(p1.location, cen).mag();


    stiffness = k;
    k_coef = stiffness;
    C=0;
  }

  void proyecta_restriccion(){
    if (anulada) return;

    Particle part1 = particles.get(0); 
    Particle part2 = particles.get(1);
    Particle part3 = particles.get(2);
    
    float wv = part1.w;
    float w0 = part2.w;
    float w1 = part3.w;
    float wei = 2*wv+w0+w1;

    if (wei < 1e-8) return; // both are blocked

    cen = PVector.div(PVector.add(PVector.add(part2.location, part3.location), part1.location), 3).copy();

    float h = PVector.sub(cen, part1.location).mag();

    // If we do not know where to correct, we do not correct
    if (h < 1e-8) return;
    


    // error
    C = h - h0;

    PVector delta = PVector.sub(part1.location, cen).mult((1-(h0/h)));

    part1.location.add(PVector.mult(delta.copy(),-4*wv*k_coef/wei));
    part2.location.add(PVector.mult(delta.copy(),2*w0*k_coef/wei));
    part3.location.add(PVector.mult(delta.copy(),2*w1*k_coef/wei));
  }

  void display(float scale_px){
    if (anulada) return;
    strokeWeight(1);
    stroke(125);
    pushMatrix();
      fill(255,0,0);
      stroke(255,0,0);
      translate(scale_px*cen.x,
                  -scale_px*cen.y, // The sign is changed, because the px increases downwards
                  scale_px*cen.z);
      sphereDetail(12);
      sphere(scale_px*0.01);
    popMatrix();
  };
}

class BendConstraint extends Constraint{
  
  float w_Total;
  float angulo_inicial;
  float stiffness;
  float k_coef;
  boolean anulada;
  
  PVector n1_orig;
  PVector n2_orig;

  BendConstraint(Particle v, Particle p2, Particle p3, Particle p4, float k){
    super();
    //particles
    particles.add(v); 
    particles.add(p2);
    particles.add(p3);
    particles.add(p4);

    w_Total = v.w + p2.w + p3.w + p4.w; 

    // precalculate initial angle between the 2 normals
    // normal 1 || formed by the triangle v, p2, p3:
    PVector n1 = PVector.sub(p2.location, v.location).cross(PVector.sub(p3.location, v.location));
    n1.normalize();

    // normal 2 || formed by the triangle v, p2, p4:
    PVector n2 = PVector.sub(p2.location, v.location).cross(PVector.sub(p4.location, v.location));
    n2.normalize();

    
    // initial angle
    angulo_inicial = acos(PVector.dot(n1, n2));

    // stiffness coefficient
    stiffness = k;
    k_coef = stiffness;

    anulada = false;
  }

  void proyecta_restriccion(){
    
    if (anulada) return;

    Particle v = particles.get(0);
    Particle p2 = particles.get(1);
    Particle p3 = particles.get(2);
    Particle p4 = particles.get(3);

    PVector v_local = new PVector(0,0,0);
    PVector p2_local = PVector.sub(p2.location, v.location);
    PVector p3_local = PVector.sub(p3.location, v.location);
    PVector p4_local = PVector.sub(p4.location, v.location);

    // normal 1 || formed by the triangle v, p2, p3:
    PVector n1 = PVector.sub(p2_local, v_local).cross(PVector.sub(p3_local, v_local));
    n1.normalize();
    n1_orig = n1.copy();

    // normal 2 || formed by the triangle v, p2, p4:
    PVector n2 = PVector.sub(p2_local, v_local).cross(PVector.sub(p4_local, v_local));
    n2.normalize();
    n2_orig = n2.copy();

    // current angle
    float d = PVector.dot(n1, n2); // 
    float angulo_actual;
    if (d > 1 - 1e-8) 
      angulo_actual = acos(1);
    else if (d < (-1 + 1e-8))
      angulo_actual = acos(-1);
    else 
      angulo_actual = acos(d);


    // deformation angle
    float angulo_deformacion = angulo_actual - angulo_inicial;

    if (p2_local.cross(p3_local).mag() < 1e-8 && p2_local.cross(p3_local).mag() > -1e-8) return;

    // deformation force per particle
    PVector q3 = PVector.div( 
      p2_local.cross(n2).add(n1.cross(p2_local).mult(d)),
      p2_local.cross(p3_local).mag()
    );

    if (p2_local.cross(p4_local).mag() < 1e-8 && p2_local.cross(p4_local).mag() > -1e-8) return;

    PVector q4 = PVector.div( 
      p2_local.cross(n1).add(n2.cross(p2_local).mult(d)) , 
      p2_local.cross(p4_local).mag()
    );
    
    if (p2_local.cross(p3_local).mag() < 1e-8 && p2_local.cross(p3_local).mag() > -1e-8 || p2_local.cross(p4_local).mag() < 1e-8 && p2_local.cross(p4_local).mag() > -1e-8) return;
    
    PVector q2 = PVector.div( 
      p3_local.cross(n2).add(n1.cross(p3_local).mult(d)) , 
      p2_local.cross(p3_local).mag()
    );

    q2.add(
      PVector.div( 
        p4_local.cross(n1).add(n2.cross(p4_local).mult(d)) , 
        p2_local.cross(p4_local).mag()
      )
    );

    q2.mult(-1);

    PVector q1 = PVector.add(q2, q3).add(q4).mult(-1);
    
    // total deformation force
    // float q_total_mag = q1.mag()*q1.ma() + q2.mag()*q2.mag() + q3.mag()*q3.mag() + q4.mag()*q4.mag();
    float q_total_mag = pow(q1.mag(),2) + pow(q2.mag(),2) + pow(q3.mag(),2) + pow(q4.mag(),2);

    if ((w_Total * q_total_mag) < 1e-8 || 1-(d*d) < 1e-8) return;

    // deformation force
    float fuerza_deformacion = -k_coef * sqrt(1-(d*d)) * angulo_deformacion /  (w_Total * q_total_mag);

    PVector delta_v = PVector.mult(q1, fuerza_deformacion * 4 * v.w);
    PVector delta_p2 = PVector.mult(q2, fuerza_deformacion * 4 * p2.w);
    PVector delta_p3 = PVector.mult(q3, fuerza_deformacion * 4 * p3.w);
    PVector delta_p4 = PVector.mult(q4, fuerza_deformacion * 4 * p4.w);

    if(debug){
      println("N1="+n1);
      println("N2="+n2);
      println("AN="+angulo_actual);
      println("Q1="+q1);
      println("Q2="+q2);
      println("Q3="+q3);
      println("Q4="+q4);
      println("D1="+delta_v);
      println("D2="+delta_p2);
      println("D3="+delta_p3);
      println("D4="+delta_p4);
    }

    // apply deformation force
    v.location.add(delta_v);
    p2.location.add(delta_p2);
    p3.location.add(delta_p3);
    p4.location.add(delta_p4);
  }
  
  void display(float scale_px){
    if (anulada) return;
    PVector v = particles.get(0).location;
    stroke(255,255,0);
    //line(scale_px*v.x, -scale_px*v.y, scale_px*v.z,  scale_px*(v.x+n1_orig.x), -scale_px*(v.y+n1_orig.y), scale_px*(v.z+n1_orig.z));
    //line(scale_px*v.x, -scale_px*v.y, scale_px*v.z,  scale_px*(v.x+n2_orig.x), -scale_px*(v.y+n2_orig.y), scale_px*(v.z+n2_orig.z));
  };  
}
