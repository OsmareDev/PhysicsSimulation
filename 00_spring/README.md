# Spring
![a1](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/eb882757-7c99-4ea5-a610-e15053be302b)

# English

It starts from an inclined plane in which there is an object sliding down
The effect of gravity also intervenes in the springs.
The formulas for the different forces are:

### *Weight strength:*
- magnitude: mass * gravity
- x: 0
- y: -1

### *Normal strength:*
- magnitude: mass * gravity * cos(alpha)
- x: sine(angle)
- y: cosine(angle)

### *Friction force of the plane:*
- magnitude: Mu * Normal force
- x: -v,x
- y: -v.y (in the opposite direction to the speed)

### *Air friction force:*
- magnitude: Kd * velocity^2
- x: -v.x
- y: -v.y (in the opposite direction to the speed)

### *Spring strength:*
- magnitude: Kei * elongation
- x: rest position - current position
- y: rest position - current position

### *Integrators*

1. Euler Explicit:
    - y_{n+1} = y_n + h * f(t_n, y_n)


2. Simplectic Euler:
    - v_{n+1/2} = v_n + (h/2) * a_n
    - x_{n+1} = x_n + h * v_{n+1/2}


3. Heun:
    - k_1 = h * f(t_n, y_n)
    - k_2 = h * f(t_n + h, y_n + k_1)
    - y_{n+1} = y_n + (1/2) * (k_1 + k_2)

4. Second Order Runge-Kutta (RK2):
    - k_1 = h * f(t_n, y_n)
    - k_2 = h * f(t_n + (h/2), y_n + (k_1/2))
    - y_{n+1} = y_n + k_2


5. Fourth Order Runge-Kutta (RK4):
    - k_1 = h * f(t_n, y_n)
    - k_2 = h * f(t_n + (h/2), y_n + (k_1/2))
    - k_3 = h * f(t_n + (h/2), y_n + (k_2/2))
    - k_4 = h * f(t_n + h, y_n + k_3)
    - y_{n+1} = y_n + (1/6) * (k_1 + 2k_2 + 2k_3 + k_4)


Where:
- tn​ is the time in the current step.
- ynyn​ is the approximate value of the solution in the current step.
- hh is the step size.
- f(t,y)f(t,y) is the function that defines the differential equation.

# Español

Se parte de un plano inclinado en el cual hay un objeto deslizándose hacia abajo por
efecto de la gravedad intervienen también dos muelles.
Las fórmulas de las diferentes fuerzas son:

### *Fuerza peso:*
- magnitud: masa * gravedad
- x: 0
- y: -1

### *Fuerza normal:*
- magnitud: masa * gravedad * cos(alpha)
- x: seno(angulo)
- y: coseno(angulo)

### *Fuerza fricción del plano:*
- magnitud: Mu * Fuerza normal
- x: -v,x
- y: -v.y (en dirección contraria a la velocidad)

### *Fuerza fricción del aire:*
- magnitud: Kd * velocidad^2
- x: -v.x
- y: -v.y (en dirección contraria a la velocidad)

### *Fuerza muelles:*
- magnitud: Kei * elongación
- x: posición de reposo - posición actual
- y: posición de reposo - posición actual

### *Integradores*

1. Euler Explícito:
    - y_{n+1} = y_n + h * f(t_n, y_n)


2. Euler Simplectico:
    - v_{n+1/2} = v_n + (h/2) * a_n
    - x_{n+1} = x_n + h * v_{n+1/2}


3. Heun:
    - k_1 = h * f(t_n, y_n)
    - k_2 = h * f(t_n + h, y_n + k_1)
    - y_{n+1} = y_n + (1/2) * (k_1 + k_2)

4. Runge-Kutta de Segundo Orden (RK2):
    - k_1 = h * f(t_n, y_n)
    - k_2 = h * f(t_n + (h/2), y_n + (k_1/2))
    - y_{n+1} = y_n + k_2


5. Runge-Kutta de Cuarto Orden (RK4):
    - k_1 = h * f(t_n, y_n)
    - k_2 = h * f(t_n + (h/2), y_n + (k_1/2))
    - k_3 = h * f(t_n + (h/2), y_n + (k_2/2))
    - k_4 = h * f(t_n + h, y_n + k_3)
    - y_{n+1} = y_n + (1/6) * (k_1 + 2k_2 + 2k_3 + k_4)


Donde:
- tn​ es el tiempo en el paso actual.
- ynyn​ es el valor aproximado de la solución en el paso actual.
- hh es el tamaño del paso.
- f(t,y)f(t,y) es la función que define la ecuación diferencial.
