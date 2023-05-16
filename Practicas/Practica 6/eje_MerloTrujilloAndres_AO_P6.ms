/*
	Mueve la pelota a la misma posición que la guía, pero posándola justo encima del suelo.
	
	@param pelota Referencia a la pelota que se desea mover.
	@param guia Referencia a la pelota que actua de guía.
	@param suelo Referencia a la malla que actua de suelo.
*/
fn moverPelota pelota guia suelo = (
	-- Ahora se obtiene el vector Up y se le cambian las componentes para obtener el vector Down, que es el que necesitamos
	vUp = guia.dir
	vDown = -1 * vUp

	-- Ahora hay que lanzar un rayo al suelo para saber donde se debe posicionar la pelota grande
	rayo = ray guia.pos vDown

	-- Ahora se calcula la colision con el suelo de la escena
	colision = intersectRay suelo rayo

	-- Sabiendo el punto donde ha colisionado, necesitamos ahora mover la pelota grande a ese sitio
	pelota.pos = colision.pos

	-- La pelota ahora mismo se encuentra hundida en el suelo.
	-- Es necesario hacer el vector de esta pelota a la guía, con una longitud igual al radio de la pelota.
	v = pelota.radius * (normalize (guia.pos - pelota.pos))

	-- Se mueve la pelota, para sacarla del suelo.
	move pelota v
)


/*
	Rota la pelota de acuerdo a la posición anterior y actual de la guía. Sigue las propiedades físicas
	de la pelota, por lo que la rotación será realista.

	@param pelota Referencia a la pelota que se desea rotar.
	@param guia Referencia a la pelota que actua de guía.
	@param posicionPasada Vector de posición con el valor de guia en el instante anterior.
*/
fn girarPelota pelota guia posicionPasada = (
	-- Primero se obtiene el vector de la posicion anterior y la actual, para saber para donde girar y cuanto
	v = guia.pos - posicionPasada
	distancia = distance guia.pos posicionPasada
	vNormalizado = normalize v
	
	ejeGiro = cross guia.dir vNormalizado
	
	-- Ahora para obtener el giro es necesario calcular la longitud del sector circular con la misma distancia que el vector v
	-- De esta formula se extraen los angulos
	
	-- Se obtiene el ángulo de giro gracias a la fórmula de la longitud del arco de circunferencia, despejando el ángulo.
	-- Se debe usar la longitud de la posición anterior y actual de la guía
	anguloGiro = (360 * distancia) / (2 * pi * pelota.radius)
	
	-- Se rota la pelota utilizando los quaternions
	rotate pelota (quat anguloGiro ejeGiro)
)


/*
	Anima la pelota pasada como parámetro por encima del suelo y siguiendo el mismo recorrido que una guía.

	@param pelota Referencia a la pelota que se desea animar para que ruede.
	@param guia Referencia a la pelota encargada de definir la trayectoria para la otra pelota.
	@param suelo Referencia al suelo por donde debe rodar la pelota.
*/
fn animar pelota guia suelo = (
	deleteKeys pelota	-- Se eliminan animaciones anteriores
	posicionPasada = 0		-- Valor simbolico para que no se destruya cuando salga del scope
	inicio = animationRange.start	-- Valor de comienzo de la timeline
	final = animationRange.end		-- Valor al final de la timeline
	
	
	animate on for t in inicio to final do (
		at time t (
			-- Se mueve la pelota justo debajo de la guía, pero encima del suelo
			moverPelota pelota guia suelo
			
			-- Esta sección se encarga de animar la rotación, pero necesita saber el valor pasado de posición,
			-- por lo que en el primer instante no se realiza.
			if t > inicio then (
				girarPelota pelota guia posicionPasada
			)
			
			-- Se actualiza el valor de posición pasado de la guía.
			posicionPasada = guia.pos
		)
	)
)


/*
	Función encargada de ejecutar el código principal. No es necesario en este lenguaje,
	pero es para ser más ordenado.
*/
fn main = (
	-- Primero se obtienen las pelotas de la escena y el suelo
	pelotaGrande = $PelotaSuelo
	pelotaGuia = $Guia
	suelo = $Suelo	
	
	-- Ahora se llama a la función de animación
	animar pelotaGrande pelotaGuia suelo
)

main()