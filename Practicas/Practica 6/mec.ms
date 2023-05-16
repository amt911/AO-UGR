-- Primero se obtienen las pelotas de la escena y el suelo
pelotaGrande = $PelotaSuelo
pelotaGuia = $Guia
suelo = $Suelo

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

	-- Ahora se hace un vector con distancia el radio de la esfera
	v = pelota.radius * (normalize (guia.pos - pelota.pos))

	move pelota v
)

fn girarPelota pelota guia suelo posicionPasada = (
	-- Primero se obtiene el vector de la posicion anterior y la actual, para saber para donde girar y cuanto
	v = guia.pos - posicionPasada
	distancia = distance guia.pos posicionPasada
	vNormalizado = normalize v
	
	ejeGiro = cross guia.dir vNormalizado
	
	-- Ahora para obtener el giro es necesario calcular la longitud del sector circular con la misma distancia que el vector v
	-- De esta formula se extraen los angulos
	anguloGiro = (360 * distancia) / (2 * pi * pelota.radius)
	
	
	rotate pelota (quat anguloGiro ejeGiro)
)

fn animar = (
	deleteKeys pelotaGrande
	posicionPasada = 0		-- Valor simbolico para que no se destruya cuando salga del scope
	animate on for t in 0 to 500 do (
		at time t (
			moverPelota pelotaGrande pelotaGuia suelo
			
			if t > 0 then (
				girarPelota pelotaGrande pelotaGuia suelo posicionPasada
			)
			
			posicionPasada = pelotaGuia.pos
		)
	)
)

animar()