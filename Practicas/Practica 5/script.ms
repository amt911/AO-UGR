fn interpolacion obj pIni pInter pFin = (
	-- Creamos la animación.
	animate on (
		for t in 0 to 100 do (
			at time t (
				local tF = t as float / 100.0
				local P = (1.0 - tF)^2.0 * pIni + 2.0 * tF * (1.0 - tF) * pInter + tF^2.0 * pFin
				obj.pos = P
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
		else if plataformas.count == 0 then (
			messageBox "No hay ninguna plataforma seleccionada."
		)
		else if (findItem plataformas actor) != 0 then (
			messageBox "El objeto a animar no puede ser plataforma al mismo tiempo."
		)
		else if inicio.value >= final.value then (
			messageBox "El keyframe de inicio debe ser menor que el del final."
		)
		else (
			-- interpolacion actor [-100,0,0] [0,0,100] [100,0,0]
			--Aqui va el codigo para saltar entre plataformas
			/*
			-- Cálculo de los puntos de salto
			puntosSalto = #(actor.pos)
			for i = 1 to plataformas.count do (
				append puntosSalto plataformas[i].pos
			)
			append puntosSalto actor.pos

			-- Ordenar los puntos de salto de menor a mayor distancia con respecto al actor
			for i = 1 to puntosSalto.count-1 do (
				for j = i+1 to puntosSalto.count do (
					if distance actor.pos puntosSalto[i] > distance actor.pos puntosSalto[j] then (
						swap puntosSalto[i] puntosSalto[j]
					)
				)
			)

			-- Ejecutar la animación de salto
			animate on (
				for i = 2 to puntosSalto.count do (
					pIni = puntosSalto[i-1]
					pFin = puntosSalto[i]
					pInter = (pIni + pFin)/2.0
					duracion = (final.value-inicio.value)/(puntosSalto.count-1)
					for t = 0 to duracion-1 do (
						at time (inicio.value + (i-2)*duracion + t) (
							local tF = t as float / duracion
							local P = (1.0 - tF)^2.0 * pIni + 2.0 * tF * (1.0 - tF) * pInter + tF^2.0 * pFin
							actor.pos = P
						)
					)
				)
			)
			*/

			animate on (
				for i = 1 to plataformas.count - 1 do (
					pIni = plataformas[i].pos
					-- Recordar que hay que subirlo para que no se solape con el cubo
					pIni.z = plataformas[i].height
					
					
					pFin = plataformas[i+1].pos
					-- Recordar que hay que subirlo para que no se solape con el cubo
					pFin.z = plataformas[i+1].height					
					
					/*
					pInter = plataformas[i].pos.z + plataformas[i].height / 2

					-- Si la altura de la otra plataforma es mayor, se escoge
					if (plataformas[i+1].pos.z + plataformas[i+1].height / 2) > pInter then
						pInter = plataformas[i+1].pos.z + plataformas[i+1].height / 2

					-- Se le da cierta altura
					pInter = pInter + 50
					*/
					pInter = (pIni + pFin) / 2
					pInter.z = 80
					
					-- La interpolacion al estar comprendida entre 0 y 1, es necesario saber su duracion
					duracion = final.value - inicio.value

					-- Aqui no es hasta el final, hace falta dividirlo en trozos para las distintas plataformas
					for t = inicio.value to final.value do (
						at time t (
							tF = ( t as float - inicio.value as float ) / duracion
							P = (1.0 - tF)^2.0 * pIni + 2.0 * tF * (1.0 - tF) * pInter + tF^2.0 * pFin
							actor.pos = P
						)
					)
				)
			)


		)
	)
)

CreateDialog salto