/*
	Lanza un rayo desde la guia que colisiona con el suelo.
	
	@param guia Referencia a la guía de la pelota.
	@param suelo Referencia al suelo por donde rodará la pelota.
	
	@return El objeto con toda la información de la colisión.
*/
fn lanzarRayo guia suelo = (
	-- Ahora se obtiene el vector Up y se le cambian las componentes para obtener el vector Down, que es el que necesitamos
	vUp = guia.dir
	vDown = -1 * vUp

	-- Ahora hay que lanzar un rayo al suelo para saber donde se debe posicionar la pelota grande
	rayo = ray guia.pos vDown

	-- Ahora se calcula la colision con el suelo de la escena
	return (intersectRay suelo rayo)
)

/*
	Mueve la pelota a la misma posición que la guía, pero posándola justo encima del suelo.
	
	@param pelota Referencia a la pelota que se desea mover.
	@param guia Referencia a la pelota que actua de guía.
*/
fn moverPelota pelota colision = (
	-- Sabiendo el punto donde ha colisionado, necesitamos ahora mover la pelota grande a ese sitio
	pelota.pos = colision.pos

	-- La pelota ahora mismo se encuentra hundida en el suelo.
	-- Es necesario subirla usando el vector normal de la superficie.
	v = pelota.radius * colision.dir

	-- Se mueve la pelota, para sacarla del suelo.
	move pelota v
)


/*
	Rota la pelota de acuerdo a su posición anterior y actual. Sigue las propiedades físicas
	de la pelota, por lo que la rotación será realista.

	@param pelota Referencia a la pelota que se desea rotar.
	@param colision Objeto con la información de la intersección.
	@param posicionPasada Vector de posición con el valor de guia en el instante anterior.
*/
fn girarPelota pelota colision posicionPasada = (
	-- Primero se obtiene el vector de la posicion anterior y la actual, para saber para donde girar y cuanto
	v = pelota.pos - posicionPasada
	distancia = distance pelota.pos posicionPasada
	vNormalizado = normalize v
	
	-- Con el vector normal al suelo y el vector de dirección de la pelota normalizado
	-- se puede obtener obtener el eje de giro. Además se debe normalizar para que la función
	-- quat funcione correctamente.
	ejeGiro = normalize (cross colision.dir vNormalizado)
	
	-- Se obtiene el ángulo de giro gracias a la fórmula de la longitud del arco de circunferencia, despejando el ángulo.
	-- Se debe usar la longitud de la posición anterior y actual de la pelota
	anguloGiro = (180 * (length v)) / (pi * pelota.radius)
		
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
			-- Se lanza el rayo hacia el suelo, para poner la pelota en su posición
			colision = lanzarRayo guia suelo
			
			-- Se mueve la pelota justo debajo de la guía, pero encima del suelo
			moverPelota pelota colision
			
			-- Esta sección se encarga de animar la rotación, pero necesita saber el valor pasado de posición,
			-- por lo que en el primer instante no se realiza.
			if t > inicio then (
				girarPelota pelota colision posicionPasada
			)
			
			-- Se actualiza el valor de posición pasado de la guía.
			posicionPasada = pelota.pos
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
	-- moverPelota pelotaGrande pelotaGuia suelo
)

main()