# Collision Efficiency
![a5_1](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/3d1a3b25-79a5-4689-b34c-9f0ef40faa00)
![a5_2](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/3683def9-b845-4143-ba5a-98f82eb66545)
![a5_3](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/772a0b7b-8686-434f-bae5-dd801ab970e6)

# English

The control structures used are:

- **Grid**
Which consists of, as its name indicates, a grid where they are stored
particles in each of its holes depending on its position

- **Hash**
Which is based on the same concept but is about reducing memory
used when storing several cells within the same cell following a
hashing.

<br>

Both are based on the same concept of saving particles and searching for neighbors.
to carry out the collisions, in our case we have done it with 4 neighbors and 30
horizontal and vertical divisions.

![c2](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/5a67e4cc-4190-4dec-b50c-83786db0576c)

As we can see in the graphs the improvement in performance when applying
structures is notable, the differences between the two are not very noticeable and
Although the grid protrudes a little above it, it may be because having
many particles and being everywhere enters the grid's area of advantage. If
the particles were more still, the hash would benefit.

# Español

Las estructuras de control utilizadas son:

- **Grid** 
Que consta de como su nombre indica una rejilla donde se almacenan
partículas en cada uno de sus huecos dependiendo de su posición

- **Hash** 
Que se basa en el mismo concepto pero se trata de reducir la memoria
utilizada al almacenar varias celdas dentro de la misma siguiendo un algoritmo de
hashing.

<br>

Ambas se basan en el mismo concepto de guardar partículas y buscar las vecinas
para realizar las colisiones, en nuestro caso lo hemos realizado con 4 vecinas y 30
divisiones horizontales y verticales.

![c2](https://github.com/OsmareDev/PhysicsSimulation/assets/50903643/9fbe1bb3-2b34-4bec-a21f-fb03855c3662)

Como podemos observar en las gráficas la mejora en cuanto rendimiento al aplicar
estructuras es notable, las diferencias entre ambas no son muy apreciables y
aunque el grid sobresalga un poco por encima puede ser debido a que al haber
muchas partículas y estar por todas partes entra en el terreno de ventaja del grid. Si
las partículas estuvieran más quietas el hash saldría beneficiado.
