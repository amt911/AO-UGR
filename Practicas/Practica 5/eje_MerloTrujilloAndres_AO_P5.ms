/*
	Función que genera la interpolación lineal entre dos puntos del espacio 3D, dado el factor de interpolación

	@param pIni Posición inicial en el espacio 3D.
	@param pFin Posición final en el espacio 3D,
	@param factor Factor de interpolación.

	@return Devuelve el punto del espacio 3D interpolado.
*/
fn interpolacion pIni pFin factor = (
	-- Creamos el vector de dirección.
	v1 = pFin - pIni

	-- Devuelvo el vector con la posición interpolada
	return (pIni + ( (normalize v1) * ((length v1) * factor) ))
)


/*
	Función que genera la interpolación cuadrática de Bézier entre tres puntos en el espacio 3D.

	@param pIni Posición inicial en el espacio 3D.
	@param pFin Posición final en el espacio 3D.
	@param factor Factor de interpolación.
	
	@return Punto en el espacio 3D interpolado.
*/
fn interpolacionCuadratica pIni pFinal pInter factor = (
	-- Primero interpolo todos los puntos, para obtener el tercer segmento
	primeraInterpolacion = interpolacion pIni pInter factor
	segundaInterpolacion = interpolacion pInter pFinal factor

	-- El resultado se interpola de nuevo para obtener el valor final
	resultado = interpolacion primeraInterpolacion segundaInterpolacion factor

	return resultado
)


/*
	Función que ajusta el valor al rango pasado como parámetro si se sale del mismo.

	@param minimo Parte inferior del intervalo.
	@param maximo Parte superior del intervalo.
	@param valor Valor a consultar.

	@return El valor sin modificar si se encuentra dentro del intervalo, en otro caso ajustado a uno de los dos extremos,
 */
fn clamp minimo maximo valor = (
	res = valor

	if valor < minimo then 
		res = minimo

	else if valor > maximo then
		res = maximo

	return res
)


/*
	Función que mapea un intervalo de valores a otro intervalo. Mapea el intervalo [a, b] -> [c, d]

	@param a Valor inferior del intervalo primero.
	@param b Valor superior del intervalo primero.
	@param c Valor inferior del intervalo segundo.
	@param d Valor superior del intervalo segundo.
	@param valor Valor del primer intervalor que se desea mapear al segundo.

	@return Un nuevo valor que es proporcional al valor pasado como parámetro, pero en el segundo intervalo
 */
fn mapRangeClamped a b c d valor = (
	-- Función clamp, para que no se salga del intervalo
	valorFinal = clamp a b valor

	-- Función mapeadora
	return (valorFinal-a)/(b-a) * (d-c) + c
)


/*
	Función que elimina los modificadores y animaciones de un objeto.

	@param obj Objeto al que se le desea ejecutar la operación.
 */
fn limpiarObjeto obj = (
	-- Elimino los keyframes que ya tenga el objeto
	deleteKeys obj

	-- Elimino todos los modificadores que pueda tener
	for m in obj.modifiers do
		deleteModifier obj m
)


/*
	Función que permite estirar y aplastar un objeto, dado el factor de interpolación de la parábola.

	@param obj Objeto que se desea aplastar o estirar.
	@param factor Factor de interpolación de la parábola.

	@return La cantidad de estiramiento o aplastamiento que debe tener el objeto.
 */
fn stretchObjeto obj factor = (

	maxPorcentajePrimero = 0.15 -- Hasta que valor de interpolación se tiene que estirar
	maxPorcentajeSegundo = 1 - maxPorcentajePrimero -- Desde que valor se tiene que aplastar
	
	-- Calcula la interpolación lineal para obtener la cantidad de stretch
	stretchCantidad = (1 - (mapRangeClamped 0.0 maxPorcentajePrimero 0.0 1.0 factor)) * -0.5 + (mapRangeClamped 0.0 maxPorcentajePrimero 0.0 1.0 factor) * 0.5

	-- Si esta en fase de bajada, se calcula la fase de aplastamiento
	if factor > maxPorcentajeSegundo then (
		stretchCantidad = (1 - (mapRangeClamped maxPorcentajeSegundo 1.0 0.0 1.0 factor)) * 0.5 + (mapRangeClamped maxPorcentajeSegundo 1.0 0.0 1.0 factor) * -0.5
	)

	return stretchCantidad
)


/*
	Función principal que anima el objeto.

	@param obj El objeto que se desea animar.
	@param inicio Instante inicial de la animación
	@param final Instante final de la animación
 */
fn animarObjeto obj inicio final = (
	limpiarObjeto obj

	-- Modifico la linea temporal para que se ajuste
	animationRange = interval inicio final

	-- Se le añade el modificador stretch para simular aplastamiento y estiramiento
	addModifier obj (Stretch() )
	obj.modifiers[Stretch].Stretch = -0.5

	animate on (
		-- La interpolacion al estar comprendida entre 0 y 1, es necesario saber su duracion
		duracion = final - inicio

		-- El numero de keyframes que debe tener reservados cada salto
		keyframesPorSalto = duracion / (plataformas.count - 1)

		estirarUltimoSalto = false	--Utilizado para los casos en los que los keyframesPorSalto no salgan exactos

		if (mod duracion (plataformas.count - 1)) != 0 then (
			estirarUltimoSalto = true
		)

		-- Se itera sobre las plataformas, de par en par
		for i = 1 to plataformas.count - 1 do (
			pIni = plataformas[i].pos
			-- Se sube la componente Z a la plataforma
			pIni.z = plataformas[i].scale.z*plataformas[i].height + plataformas[i].pos.z
								
			pFin = plataformas[i+1].pos
			
			-- Se sube aqui tambien
			pFin.z = plataformas[i+1].scale.z*plataformas[i+1].height + plataformas[i+1].pos.z

			-- Busco aquella plataforma que tenga la mayor altura, y luego le sumo 80
			maximo = pIni.z

			if pFin.z > maximo then (
				maximo = pFin.z
			)


			pInter = (pIni + pFin) / 2
			pInter.z = maximo + 120		-- Se le suma algo a la altura del punto intermedio

			ultimoKeyframeSalto = inicio + i * keyframesPorSalto

			-- Si la evaluacion de antes indica que no es exacto, se tiene que estirar el ultimo salto
			if (i == (plataformas.count - 1)) and estirarUltimoSalto then (
				ultimoKeyframeSalto = final
			)

			-- Se anima el salto
			for t = inicio + (i - 1) * keyframesPorSalto to ultimoKeyframeSalto do (
				at time t (
					-- Es necesario hacerle el clamp, para que en los casos en el que el ultimo salto
					-- sea algo mas largo de tiempo, no pase el numero por encima de 1.0
					factor = clamp 0.0 1.0 (((t as float - inicio as float ) - (i-1)*keyframesPorSalto) / keyframesPorSalto)
					
					obj.pos = (interpolacionCuadratica pIni pFin pInter factor)
					obj.modifiers[Stretch].Stretch  = (stretchObjeto obj factor)
				)
			)
		)
	)
)


-- Creacion de la interfaz
rollout salto "Configuración del salto" (
	global plataformas = #()
	global actor = undefined
	
	-- Etiqueta del actor
	label etActor "Actor:"
	
	-- Boton del actor
	pickbutton boActor "Seleccione actor"
	
	
	-- Grupo para la lista de plataformas
	group "Plataformas" (
		-- Etiqueta para la lista
		label etPlat "Plataformas a saltar:"
		
		-- Lista de todos los objetos
		listbox liPlat
		
		-- Boton para añadir objetos
		pickbutton boPlat "Añadir plataforma"
		
		
		-- Boton para eliminar alguna plataforma
		button boEliminar "Eliminar plataforma"
	)
	
	group "Duración de la animación" (
		spinner inicio "Inicio: " type:#Integer range:[0,500,1]
		spinner final "Final: " type:#Integer range:[0,500,1]
	)
	
	button animar "Generar"
	
	-- Parte de eventos de los botones
	on boActor picked obj do (
		actor = obj
		
		-- Cambio del texto del boton
		boActor.text = obj.name
	)
	
	on boPlat picked obj do (
		if obj == actor then (
			messageBox "El objeto a animar no puede ser plataforma al mismo tiempo."
		)
		else (
			append plataformas obj
			liPlat.items = append liPlat.items (obj.name as string)
		)
	)
	
	on boEliminar pressed do (
		-- Se obtiene la seleccion en la lista
		seleccion = liPlat.selection
		
		/*
		Si el usuario no ha seleccionado nada
		(por defecto es 0 y la lista comienza en 1)
		*/
		if seleccion != 0 do (
			deleteItem plataformas seleccion
			deleteItem liPlat.items seleccion
			
			-- Esta linea sirva para que se actualice la lista en la interfaz
			liPlat.items = liPlat.items
		)
	)

	on animar pressed do (
		-- Primero se comprueba que todos los datos han sido introducidos correctamente
		if actor == undefined then (
			messageBox "No hay ningún actor seleccionado."
		)
		else if plataformas.count < 2 then (
			messageBox "No hay suficientes plataformas seleccionadas."
		)
		else if (findItem plataformas actor) != 0 then (
			messageBox "El objeto a animar no puede ser plataforma al mismo tiempo."
		)
		else if inicio.value >= final.value then (
			messageBox "El keyframe de inicio debe ser menor que el del final."
		)
		else (
			animarObjeto actor inicio.value final.value
		)
	)
)

CreateDialog salto