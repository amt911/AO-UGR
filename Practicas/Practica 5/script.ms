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
		-- Falta la logica para comprobar que el inicio y el fin estan dentro de un rango, tambien hay que ponerlo en el evento
		else (
		)
	)
)

CreateDialog salto