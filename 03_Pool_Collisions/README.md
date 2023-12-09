# Pool Collisions
![a4](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/05b2c5c5-007e-4092-97ec-c107693a356f)

# English

The aim is to implement a model of particles that collide with each other and various
planes following different methods of collisions. For the first part we search
perform the collisions that a billiard table follows (collisions between the sides and the
particles) the model used for collisions between particles is a model
based on speeds where a concept quite similar to that of the
walls.

For the collision between particles, the mass of each one will be taken into account, making a distribution of energy

### **Collision Detection**
- dist = (p2 − p1).magnitude() < r1 + r2

Decomposition of speed into normal and tangential:
- normal = speed.project(dist);
- tangential = speed - normal;

### **Restitution**
- Calculation of L = r1 + r2 − dist.magnitude()
- Calculation of vrel = (normalp1 − normalp2).magnitude()
- New position: p1 = p1.addScaled(normalp1, −L/vrel)

### **Calculation of final speed**
- Scalar: u1 = normal.projection(dist)
- Module: v1 = ((m1−m2)∗u1+2∗m2∗u2)/(m1+m2)
- Normal vector' = dist.for(v1);
- Vector v1' = normal′ + tangential


# Español

Se busca implementar un modelo de partículas que colisionan entre sí y diversos
planos siguiendo diferentes métodos de colisiones. Para la primera parte se busca
realizar las colisiones que sigue una mesa de billar (colisiones entre los lados y las
partículas) el modelos usado para las colisiones entre partículas es un modelo
basado en velocidades donde se aplica un concepto bastante similar al de las
paredes.

Para el choque entre particulas se tendra en cuenta la masa de cada una haciendo un reparto de energia 

### **Detección de colisión**
- dist = (p2 − p1).magnitude() < r1 + r2

Decomposicion de la velocidad en normal y tangencial:
- normal = velocidad.project(dist);
- tangencial = velocidad - normal;

### **Restitución**
- Cálculo de L = r1 + r2 − dist.magnitude()
- Cálculo de vrel = (normalp1 − normalp2).magnitude()
- Nueva posición: p1 = p1.addScaled(normalp1, −L/vrel)

### **Calculo de la velocidad final**
- Escalar: u1 = normal.projection(dist)
- Módulo: v1 = ((m1−m2)∗u1+2∗m2∗u2)/(m1+m2)
- Vector normal' = dist.para(v1);
- Vector v1' = normal′ + tangencial
