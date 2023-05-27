extends CharacterBody2D	

"""
NOTA

Intentar realizar todo el proceso por medio de tiles, y calcular el normal
basado en la posición del tile disponible de la posición actual del jugador.
"""

var destination = null
const SPEED = 300.0
const DEBUG = true

signal TouchedTile(given_collision)

func getSensorStatus():
	return [
		$SensorIzquierda.is_colliding(),
		$SensorAbajo.is_colliding(),
		$SensorArriba.is_colliding(),
		$SensorDerecha.is_colliding()
	]
	
func allSensorsDisabled():
	return (not $SensorIzquierda.is_colliding() and
		not $SensorAbajo.is_colliding() and
		not $SensorArriba.is_colliding() and
		not $SensorDerecha.is_colliding())
		
func getTilePosition():
	var TileMapExp = get_parent().get_node("Exploracion") as TileMap
	var pos = TileMapExp.local_to_map( global_position ) as Vector2i
	return pos

"""
Retorna verdadero o falso si el bloque pedido de position - offset ya fue explorado.
"""
func wasTileAlreadyExplored(curPosition : Vector2i, offset : Vector2i):
	var TileMapExp = get_parent().get_node("Exploracion") as TileMap
	var ColisionMap = get_parent().get_node("TileMap") as TileMap
	var pos = curPosition
	pos += offset
	var data = TileMapExp.get_cell_atlas_coords(0, pos) as Vector2i
	var colisionData = ColisionMap.get_cell_atlas_coords(0, pos) as Vector2i
	
	if data:
		# print(curPosition, offset, data, colisionData)
		return data == Vector2i(1,0) and colisionData == Vector2i(0,0)
	
	return false
	
func currentTileHasBeenVisited(curPosition : Vector2i):
	return wasTileAlreadyExplored(curPosition, Vector2i(0,0))

func tilePositionToGlobal(tilePosition : Vector2i):
	var TileMapExp = get_parent().get_node("Exploracion") as TileMap
	return TileMapExp.map_to_local(tilePosition)
	
func MoveToNewLocation(delta : float, newposition : Vector2i):
	destination = newposition
	var GlobalNewPosition = tilePositionToGlobal(newposition)
	# print( global_position, GlobalNewPosition )
	global_position = global_position.move_toward(GlobalNewPosition, delta*SPEED )
	
func DetermineNewDestination():
	var current_position = getTilePosition()
	
	# Si estamos actualmente en un bloque ya visitado, encuentra una manera de salir de ahi.
	if currentTileHasBeenVisited(current_position):
		print("Current tile has been visited")
		if not wasTileAlreadyExplored(current_position, Vector2i(0,1)) and not $SensorAbajo.is_colliding():
			# print("abajo")
			current_position.y += 1
			return current_position
		if not wasTileAlreadyExplored(current_position, Vector2i(1,0)) and not $SensorDerecha.is_colliding():
			# print("derecha")
			current_position.x += 1
			return current_position
		if not wasTileAlreadyExplored(current_position, Vector2i(0,-1)) and not $SensorArriba.is_colliding():
			# print("derecha")
			current_position.y -= 1
			return current_position
		return null
	
	# Abajo
	if (wasTileAlreadyExplored(current_position, Vector2i(0,-1))):
		if $SensorAbajo.is_colliding():
			return null
		# print("abajo")
		current_position.y += 1
		return current_position
	# Derecha
	if (wasTileAlreadyExplored(current_position, Vector2i(-1,0))):
		print("Derecha")
		if $SensorDerecha.is_colliding():
			return null
		current_position.x += 1
		return current_position
	# Izquierda
	if (wasTileAlreadyExplored(current_position, Vector2i(1,0))):
		# print("Izquierda")
		if $SensorIzquierda.is_colliding():
			return null
		current_position.x -= 1
		return current_position
	return null
	
func _process(delta):
	#var pos = get_parent().get_node("Exploracion").local_to_map( global_position ) as Vector2i
	## print( wasTileAlreadyExplored(global_position, Vector2i(0,0)) )
	# Situación donde nos quedamos en limbo, dado la distancia de los sensores, no detectan ninguna pared.
	var newposition = getTilePosition()
		
	if DEBUG:
		var stats = getSensorStatus()
		# print(stats)
		$"L-IZQ".set_text( "true" if stats[0] else "false" )
		$"L-ABA".set_text( "true" if stats[1] else "false" )
		$"L-ARR".set_text( "true" if stats[2] else "false" )
		$"L-DER".set_text( "true" if stats[3] else "false" )
	
	if destination != null:
		var GlobalNewPosition = tilePositionToGlobal(destination)
		print(newposition, destination)
		if (destination.y > newposition.y) and $SensorAbajo.is_colliding():
			destination = null
			TouchedTile.emit( newposition )
			return
		# print( newposition, destination )
		global_position = global_position.move_toward(GlobalNewPosition, delta*SPEED )
		if GlobalNewPosition == global_position:
			TouchedTile.emit( newposition )
			destination = null
		return
	else:
		var newLocation = DetermineNewDestination()
		if newLocation:
			MoveToNewLocation(delta, newLocation)
