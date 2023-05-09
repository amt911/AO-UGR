fn interpolacion pIni pFin porcentaje = (
	-- Creamos el vector de dirección.
	v1 = pFin - pIni

	return (pIni + ( (normalize v1) * ((length v1) * porcentaje) ))
)

fn interpolacionCuadratica pIni pFinal pInter porcentaje = (
	-- Otra opcion para hacer la interpolacion cuadratica es haciendo tres interpolaciones lineales.
	primeraInterpolacion = interpolacion pIni pInter porcentaje
	segundaInterpolacion = interpolacion pInter pFin porcentaje

	resultado = interpolacion primeraInterpolacion segundaInterpolacion porcentaje

	return resultado
)

fn mapRangeClamped a b c d valor = (
	valorFinal = valor

	if valor < a then 
		valorFinal = a

	else if valor > b then
		valorFinal = b

	return (valorFinal-a)/(b-a) * (d-c) + c
)

fn limpiarObjeto obj = (
	-- Elimino los keyframes que ya tenga el objeto
	deleteKeys obj
	
	for m in obj.modifiers do
		deleteModifier obj m

	obj.rotation.x_rotation = 0
	obj.rotation.y_rotation = 0
	obj.rotation.z_rotation = 0
)

fn stretchObjeto obj porcentajeSalto = (
	maxPorcentajePrimero = 0.15
	maxPorcentajeSegundo = 1 - maxPorcentajePrimero
	
	-- (1-t) * Pini + t * Pfin
	stretchCantidad = (1 - (mapRangeClamped 0.0 maxPorcentajePrimero 0.0 1.0 porcentajeSalto)) * -0.5 + (mapRangeClamped 0.0 maxPorcentajePrimero 0.0 1.0 porcentajeSalto) * 0.5

	-- Si esta en fase de bajada, se hace otra cosa
	if porcentajeSalto > maxPorcentajeSegundo then (
		stretchCantidad = (1 - (mapRangeClamped maxPorcentajeSegundo 1.0 0.0 1.0 porcentajeSalto)) * 0.5 + (mapRangeClamped maxPorcentajeSegundo 1.0 0.0 1.0 porcentajeSalto) * -0.5
	)

	return stretchCantidad
)

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

		keyframesPorSalto = duracion / (plataformas.count - 1)

		for i = 1 to plataformas.count - 1 do (
			pIni = plataformas[i].pos
			-- Recordar que hay que subirlo para que no se solape con el cubo
			pIni.z = plataformas[i].scale.z*plataformas[i].height + plataformas[i].pos.z
								
			pFin = plataformas[i+1].pos
			-- Recordar que hay que subirlo para que no se solape con el cubo
			pFin.z = plataformas[i+1].scale.z*plataformas[i+1].height + plataformas[i+1].pos.z

			-- Busco aquella plataforma que tenga la mayor altura, y luego le sumo 50
			maximo = (plataformas[i].scale.z*plataformas[i].height + plataformas[i].pos.z)

			if (plataformas[i+1].scale.z*plataformas[i+1].height + plataformas[i+1].pos.z) > maximo then
				maximo = plataformas[i+1].scale.z*plataformas[i+1].height + plataformas[i+1].pos.z


			pInter = (pIni + pFin) / 2
			pInter.z = maximo + 80
			
			-- Aqui no es hasta el final, hace falta dividirlo en trozos para las distintas plataformas
			for t = inicio + (i - 1) * keyframesPorSalto to inicio + i * keyframesPorSalto do (
				at time t (
					porcentaje = ((t as float - inicio as float ) - (i-1)*keyframesPorSalto) / keyframesPorSalto
					
					obj.pos = (interpolacionCuadratica pIni pFinal pInter porcentaje)
					obj.modifiers[Stretch].Stretch  = (stretchObjeto obj porcentaje)
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
		button boEliminar "Eliminar plataforma seleccionada"
	)
	
	group "Duración de la animación" (
		spinner inicio "Inicio: " type:#Integer range:[0,500,1]
		spinner final "Final: " type:#Integer range:[0,500,1]
	)
	
	button animar "Ejecutar animación"
	
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
			-- DEBUG
			print plataformas
			print "cambio"
			print liPlat.items
			
			deleteItem plataformas seleccion
			deleteItem liPlat.items seleccion
			
			-- Esta linea sirva para que se actualice la lista
			liPlat.items = liPlat.items
		)
	)

	on animar pressed do (
		-- Hacer restriccion para que haya al menos dos plataformas
		-- Primero se comprueba que todos los datos han sido introducidos
		if actor == undefined then (
			messageBox "No hay ningún actor seleccionado."
		)
		else if plataformas.count < 2 then (
			messageBox "No hay suficientes plataforma seleccionada."
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