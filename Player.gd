extends CharacterBody2D

var destination = null
const SPEED = 1500.0
const DEBUG = true
var expected_goal = null
var hasReachedGoal = true
var visitedTilesIndx = -1

var lastVisitedLocations = PackedVector2Array([])
# Mantiene la utilma ubicación que contiene un lugar no explorado.

signal TouchedTile(given_collision)
signal ReachedGoal()

func setExpectedGoal(goal):
	expected_goal = goal
	hasReachedGoal = false
		
func getTilePosition():
	var TileMapExp = get_parent().get_node("Exploracion") as TileMap
	var pos = TileMapExp.local_to_map( global_position ) as Vector2i
	return pos

"""
Retorna verdadero o falso si el bloque pedido de position - offset ya fue explorado.
"""
func wasTileAlreadyExplored(curPosition : Vector2i, offset : Vector2i, debugInfo : bool = false):
	var TileMapExp = get_parent().get_node("Exploracion") as TileMap
	var ColisionMap = get_parent().get_node("TileMap") as TileMap
	var pos = curPosition
	pos += offset
	var data = TileMapExp.get_cell_atlas_coords(0, pos) as Vector2i
	var colisionData = ColisionMap.get_cell_atlas_coords(0, pos) as Vector2i
	
	if data:
		return data == Vector2i(1,0)
	
	return false
	
func currentTileHasBeenVisited(curPosition : Vector2i):
	return wasTileAlreadyExplored(curPosition, Vector2i(0,0))

func tilePositionToGlobal(tilePosition : Vector2i):
	var TileMapExp = get_parent().get_node("Exploracion") as TileMap
	return TileMapExp.map_to_local(tilePosition)
	
func MoveToNewLocation(delta : float, newposition : Vector2i):
	destination = newposition
	var GlobalNewPosition = tilePositionToGlobal(newposition)
	global_position = global_position.move_toward(GlobalNewPosition, delta*SPEED )
	
func DetermineNewDestination():
	var current_position = getTilePosition()
	
	# Si estamos actualmente en un bloque ya visitado, encuentra una manera de salir de ahi.
	if currentTileHasBeenVisited(current_position):
		"""
		NOTA: Aqui puede tener una mejora en la busqueda de posición calculando el normal
		del tile *meta* con el actual.
		"""
		if not wasTileAlreadyExplored(current_position, Vector2i(0,1), true) and not $SensorAbajo.is_colliding():
			current_position.y += 1
			return current_position
		if not wasTileAlreadyExplored(current_position, Vector2i(1,0), true) and not $SensorDerecha.is_colliding():
			current_position.x += 1
			return current_position
		if not wasTileAlreadyExplored(current_position, Vector2i(0,-1), true) and not $SensorArriba.is_colliding():
			current_position.y -= 1
			return current_position
		if not wasTileAlreadyExplored(current_position, Vector2i(-1,0), true) and not $SensorIzquierda.is_colliding():
			current_position.x -= 1
			return current_position
	return null
	
func _process(delta):
	if hasReachedGoal:
		return
		
	var newposition = getTilePosition()
	
	if destination != null:
		var GlobalNewPosition = tilePositionToGlobal(destination)
		if (destination.y > newposition.y) and $SensorAbajo.is_colliding():
			destination = null
			TouchedTile.emit( newposition )
			return
		global_position = global_position.move_toward(GlobalNewPosition, delta*SPEED )
		
		# Si no estamos en la posición destino (local), entonces no hay que realizar
		# las operaciones abajo.
		if GlobalNewPosition != global_position:
			return
			
		# Transmite a Laberinto que el Personaje ha tocado este tile.
		TouchedTile.emit( newposition )
		
		# Si este tile es la meta, termina el programa.
		if destination == expected_goal:
			hasReachedGoal = true
			ReachedGoal.emit()
			
		# Reinicia el destino.
		destination = null
		
		if lastVisitedLocations.has(newposition):
			return
			
		lastVisitedLocations.append( newposition )
		visitedTilesIndx += 1
	else:
		var newLocation = DetermineNewDestination()
		if newLocation:
			MoveToNewLocation(delta, newLocation)
		else:
			# Vamos para atrás.
			visitedTilesIndx -= 1
			MoveToNewLocation(delta,  lastVisitedLocations[visitedTilesIndx] )
			# Quita el elemento de la lista, hay que volver.
			lastVisitedLocations.remove_at(visitedTilesIndx+1)
