# Explosion Shape And Air Force
![a2](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/d02ef0ef-1d24-4c6b-bdfb-c17864184c05)

# English

The simulation will consist of calculating the trajectory followed by a particle that is
It launches with an initial velocity and is affected by the force of weight and friction.
with air or water

The formulas for the different forces are:

### *Weight strength:*
- magnitude: mass * gravity
- x: 0
- and: -1

### *Air friction force:*
- magnitude: Kd * velocity (it is not squared since it is requested to be linear)
- x: -v.x
- y: -v.y (in the opposite direction to the speed)

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

La simulación consistirá en calcular la trayectoria que sigue una partícula que se
lanza con una velocidad inicial y es afectada por la fuerza del peso y del rozamiento
con el aire o con el agua

Las fórmulas de las diferentes fuerzas son:

### *Fuerza peso:*
- magnitud: masa * gravedad
- x: 0
- y: -1

### *Fuerza fricción del aire:*
- magnitud: Kd * velocidad (no es al cuadrado dado que se pide que sea lineal)
- x: -v.x
- y: -v.y (en dirección contraria a la velocidad)

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
