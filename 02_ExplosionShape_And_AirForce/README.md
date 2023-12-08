# Explosion Shape And Air Force
![a3](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/e435ba62-2cfb-462b-8448-3c5ec0bfe3c3)

# English

The aim is to implement a particle model that simulates the rise and explosion
of a rocket that is affected by the wind, altering the flight and movement of the rocket
explosion shape

## Wind model implementation

- **Description:**
The force of the wind affects the particle in a particular way in which it affects
The more opposite are the speeds of the particle and the wind.

- **Implementation:**
Our implementation looks at the angle between the speed of the particle and
the wind speed with a processing function called angleBetween that gives
the result is always positive, a value between 0 and Pi, that is, if they go towards the same
direction or if they are in the opposite direction to each other. We use this divided value
by PI and we use it to determine how much the wind contributes to our sum of
forces.

## Types of designed palm trees

- **Description:**
When the particle that acts as the base of the rocket explodes, particles with shapes are formed.
which is achieved by calculating the velocities of each of the particles that
they form the explosion

- **Implementation:**
Our implementation has been carried out through the use of a formula that calculates
forms through an equation, depending on the number of particles per
explosion we calculate a departure angle for all of them. After which we calculate
the module of the speed that they must follow according to their angle to carry out the
formulas following the following equation:

![c1](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/cc8bba5c-8ca9-4a74-afdd-f80329476ea2)

**where:**
- k: rounding factor of the tips [0..1] (0 is a circle)
- m : exit of the tips [1-4] (1 is a straight shape)
- n : number of points [5..infinity]

After this we only have to give random values to the different elements to
form the formulas.


# Español

Se busca implementar un modelo de partículas que simule el ascenso y explosion
de un cohete que se ve afectado por el viento alterando el vuelo y movimiento de la
forma de la explosion

## Implementacion del modelo de viento

- **Descripción:**
La fuerza del viento afecta a la partícula de una forma particular en la que afecta
más contra más contrapuestas están las velocidades de la partícula y del viento

- **Implementación:**
Nuestra implementación mira el ángulo que hay entre la velocidad de la partícula y
la velocidad del viento con una función de processing llamada angleBetween que da
el resultado siempre en positivo, un valor entre 0 y Pi o sea si van hacia la misma
dirección o si están en sentido contrario una a la otra. Usamos este valor dividido
por PI y lo usamos para determinar cuánto contribuye el viento a nuestra suma de
fuerzas.

## Tipos de palmeras diseñadas

- **Descripción:**
Al explotar la partícula que hace de base del cohete se forman partículas con formas
que se consigue calculando las velocidades de cada una de las partículas que
forman la explosion

- **Implementación:**
Nuestra implementación se ha realizado a través del uso de una fórmula que calcula
formas a través de una ecuación, dependiendo de la cantidad de partículas por
explosion calculamos un ángulo de salida para todas ellas. Tras lo cual calculamos
el módulo de la velocidad que deben seguir según su angulo para realizar las
formulas siguiendo la siguiente ecuación:

![c1](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/cc8bba5c-8ca9-4a74-afdd-f80329476ea2)

**donde:**
- k : factor de redondeo de las puntas [0..1] (0 es un circulo)
- m : salida de las puntas [1-4] (1 es una forma recta)
- n : número de puntas [5..infinito]

Tras esto solo nos queda dar valores aleatorios a los diferentes elementos para
formar las fórmulas.
