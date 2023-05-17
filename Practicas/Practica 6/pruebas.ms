	/*
	-- v = pelota.radius * (normalize (guia.pos - pelota.pos))
	v = pelota.radius * colision.dir
	move pelota v
	*/
	
fn dibujar_linea p1 p2 = (
	linea = SplineShape pos:p1
	addNewSpline linea
	addKnot linea 1 #corner #line p1
	addKnot linea 1 #corner #line p2
	updateShape linea
	linea
)
	
pelota = $Sphere001
punto = $Point001
caja = $Box001

dibujar_linea pelota.pos punto.pos

va = normalize (punto.pos - pelota.pos)

rayo = ray pelota.pos va

colision = intersectRay caja rayo

pelota.pos = colision.pos

print colision

-- v = pelota.radius * (normalize (pelota.pos - punto.pos))
v = pelota.radius * colision.dir
move pelota v

-- se puede normalizar esto
anguloRayoNormal = acos (dot colision.dir (normalize (-1 * va)))
	
-- Ahora viene lo cutre, se obtiene el cross de los dos vectores y se normaliza el resultado
normalizadoV = normalize (cross colision.dir (normalize (-1 * va)))
	
distanciaFinal = pelota.radius * cos anguloRayoNormal

vectorParalelo = distanciaFinal * (normalize (cross normalizadoV colision.dir))
	
move pelota vectorParalelo

	
