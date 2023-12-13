# Waves
![a7](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/bda25ccf-caef-4c5c-8d0e-9f941c1f4dd2)

# English

The aim is to carry out a simulation of waves in water through the use of a height map and different types of waves, among them we find:

<br>

- **directional waves:**
These waves follow a direction, through that direction and with the wavelength and the period we can obtain the following formula that will tell us the height of the wave at each of the points that we pass to it

![c4_1](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/5912b96c-8b68-4eaa-857f-5b218ecece6a)
![c4_2](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/817bfd34-19a8-47fa-a412-c2ce41b53e02)

- **radio waves:**
These waves have a center from which they emerge, following the direction that takes them to the center. The formula is very similar to the previous waves.

![c4_3](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/6f6c005d-540c-46a7-a4cf-0a314b6de82a)
![c4_4](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/06f7e392-0736-4e04-9b77-ae80fd326dfa)

- **geistner waves:**
Finally, we have this type of waves that are more realistic by also modifying the position of the points to generate peaks in the waves. For this, a Q factor is needed, which we have solved from the class pdf formula as:

![c4_5](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/573dfd86-3247-4321-9e64-56214c0c63c2)
![c4_6](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/00b9d240-ead4-4d4b-8f32-7ec31e7b8a2f)

### Parameters used for wave types:
- a / _A : amplitude
- _L : wavelength
- _T : period
- _K : 2 * PI / _L
- _W : 2 * PI / _T

# Español

Se busca la realización de una simulación de ondas en el agua mediante el uso de un mapa de alturas y diferentes tipos de ondas, entre ellas encontramos:

<br>

- **ondas direccionales:**
estas ondas siguen una dirección, a través de esa dirección y con la longitud de onda y el periodo podemos sacar la siguiente fórmula que nos dirá la altura de la onda en cada uno de los puntos que le pasemos

![c4_1](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/5912b96c-8b68-4eaa-857f-5b218ecece6a)
![c4_2](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/817bfd34-19a8-47fa-a412-c2ce41b53e02)

- **ondas radiales:**
estas ondas tienen un centro del que salen, siguiendo la dirección que les lleva al centro la fórmula es muy parecida a las ondas anteriores

![c4_3](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/6f6c005d-540c-46a7-a4cf-0a314b6de82a)
![c4_4](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/06f7e392-0736-4e04-9b77-ae80fd326dfa)

- **ondas geistner:**
por último tenemos este tipo de ondas que son más realistas al modificar también la posición de los puntos para generar picos en las olas, para ello se necesita un factor Q, el cual hemos resuelto de la fórmula del pdf de clase como:

![c4_5](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/573dfd86-3247-4321-9e64-56214c0c63c2)
![c4_6](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/00b9d240-ead4-4d4b-8f32-7ec31e7b8a2f)

### Parámetros utilizados para los tipos de ondas:
- a / _A : amplitud
- _L : longitud de onda
- _T : periodo
- _K : 2 * PI / _L
- _W : 2 * PI / _T
