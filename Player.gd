extends CharacterBody2D	

"""
NOTA

- Intentar realizar todo el proceso por medio de tiles, y calcular el normal
basado en la posición del tile disponible de la posición actual del jugador.

- Realizar un historial que toma el registro de los lugares ya utilizados.
"""

var destination = null
const SPEED = 700.0
const DEBUG = true
var expected_goal = null
var hasReachedGoal = true

var lastVisitedLocations = []
# Mantiene la utilma ubicación que contiene un lugar no explorado.
var lastPossibleFreeLocation = null

signal TouchedTile(given_collision)
signal ReachedGoal()

func setExpectedGoal(goal):
	expected_goal = goal
	hasReachedGoal = false

func getSensorStatus():
	return [
		$SensorIzquierda.is_colliding(),
		$SensorAbajo.is_colliding(),
		$SensorArriba.is_colliding(),
		$SensorDerecha.is_colliding()
	]

func getAvailableLocations():
	var neighbours = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	var sensors = getSensorStatus()
	var pos = getTilePosition()
	var result = []
	
	for i in range(len(neighbours)):
		result.append( wasTileAlreadyExplored(pos, neighbours[i]) )
			
	return result

func hasAnyPossibleLocations():
	var neighborPositions = getAvailableLocations()
	var sensors = getSensorStatus()
	for i in range(len(neighborPositions)):
		if not neighborPositions[i] and not sensors[i]:
			return true
			
	return false
	
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
func wasTileAlreadyExplored(curPosition : Vector2i, offset : Vector2i, debugInfo : bool = false):
	var TileMapExp = get_parent().get_node("Exploracion") as TileMap
	var ColisionMap = get_parent().get_node("TileMap") as TileMap
	var pos = curPosition
	pos += offset
	var data = TileMapExp.get_cell_atlas_coords(0, pos) as Vector2i
	var colisionData = ColisionMap.get_cell_atlas_coords(0, pos) as Vector2i
	
	if data:
		#if debugInfo:
			#print( data, colisionData )
			
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
	# print( global_position, GlobalNewPosition )
	global_position = global_position.move_toward(GlobalNewPosition, delta*SPEED )
	
func DetermineNewDestination():
	var current_position = getTilePosition()
	
	#print("\n")
	# Si estamos actualmente en un bloque ya visitado, encuentra una manera de salir de ahi.
	if currentTileHasBeenVisited(current_position):
		# print("already visited")
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
		
	# If we reached here, we need to go back.
	if (wasTileAlreadyExplored(current_position, Vector2i(0,-1))):
		if $SensorArriba.is_colliding():
			return null
		current_position.y -= 1
		return current_position
	# Derecha
	if (wasTileAlreadyExplored(current_position, Vector2i(1,0))):
		if $SensorDerecha.is_colliding():
			return null
		current_position.x += 1
		return current_position
	# Izquierda
	if (wasTileAlreadyExplored(current_position, Vector2i(-1,0))):
		if $SensorIzquierda.is_colliding():
			return null
		current_position.x -= 1
		return current_position
	# Abajo
	if (wasTileAlreadyExplored(current_position, Vector2i(0,1))):
		if $SensorAbajo.is_colliding():
			return null
		current_position.y += 1
		return current_position
	return null
	
func _process(delta):
	if hasReachedGoal:
		return
		
	var newposition = getTilePosition()
		
	if DEBUG:
		var stats = getSensorStatus()
		$"L-IZQ".set_text( "true" if stats[0] else "false" )
		$"L-ABA".set_text( "true" if stats[1] else "false" )
		$"L-ARR".set_text( "true" if stats[2] else "false" )
		$"L-DER".set_text( "true" if stats[3] else "false" )
	
	if destination != null:
		var GlobalNewPosition = tilePositionToGlobal(destination)
		# print(newposition, destination)
		if (destination.y > newposition.y) and $SensorAbajo.is_colliding():
			destination = null
			TouchedTile.emit( newposition )
			return
		global_position = global_position.move_toward(GlobalNewPosition, delta*SPEED )
		if GlobalNewPosition == global_position:
			TouchedTile.emit( newposition )
			
			if hasAnyPossibleLocations():
				lastPossibleFreeLocation = newposition
			
			if not lastVisitedLocations.has(destination):
				lastVisitedLocations.append( destination )
				
			if destination == expected_goal:
				hasReachedGoal = true
				ReachedGoal.emit()
				
			destination = null
			# print( hasAnyPossibleLocations() )
		return
	else:
		var newLocation = DetermineNewDestination()
		if newLocation:
			MoveToNewLocation(delta, newLocation)
		else:
			# Hay que volver.
			MoveToNewLocation(delta, lastPossibleFreeLocation)
