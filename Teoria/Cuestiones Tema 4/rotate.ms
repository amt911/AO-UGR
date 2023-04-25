-- Definimos un quaternion. Hay dos formas:
q1 = quat 30 [1, 0, 0]	-- Primera forma
q2 = quat (sin(30/2)) 0 0 (cos(30/2))	-- Segunda forma

-- Ahora se lo aplicamos al cubo. Solo una de las dos formas.
rotate $Box001 q1
	
-- rotate $Box001 q2