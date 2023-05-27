extends CharacterBody2D	

const SPEED = 300.0
#var direction = Vector2(0,0)
# const JUMP_VELOCITY = -400.0
# const TileSize = 128
# var curPos = Vector2i(0,0)
# var VisitedPositions = []
# var children = []
var LastPosition = Vector2(0,0)
const DEBUG = true

signal collided(given_collision)

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

"""
Retorna verdadero o falso si el bloque pedido de position - offset ya fue explorado.
"""
func wasTileAlreadyExplored(position : Vector2, offset : Vector2i):
	var TileMapExp = get_parent().get_node("Exploracion") as TileMap
	var pos = TileMapExp.local_to_map( global_position ) as Vector2i
	pos += offset
	var data = TileMapExp.get_cell_atlas_coords(0, pos) as Vector2i
	
	if data:
		print(data)
		return data == Vector2i(1,0)
	
	return false

func _physics_process(delta):
	#var pos = get_parent().get_node("Exploracion").local_to_map( global_position ) as Vector2i
	#print( wasTileAlreadyExplored(global_position, Vector2i(0,0)) )
	# Situación donde nos quedamos en limbo, dado la distancia de los sensores, no detectan ninguna pared.
	if allSensorsDisabled():
		velocity = Vector2(0,0)
		
		if not wasTileAlreadyExplored(global_position, Vector2i(0,1)):
			velocity.y = SPEED * 1
		if not wasTileAlreadyExplored(global_position, Vector2i(0,-1)):
			velocity.y = SPEED * -1
		
		move_and_slide()
		pass
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision:
			collided.emit(collision)
			
	# Situacion donde el personaje se encuentra en una area horizontal.
	if $SensorArriba.is_colliding() != $SensorAbajo.is_colliding():
		if not $SensorAbajo.is_colliding():
			velocity.y = SPEED * 1
		if not $SensorArriba.is_colliding():
			velocity.y = SPEED * -1
	# Situación donde el personaje se encuentra en una area vertical.
	if $SensorDerecha.is_colliding() != $SensorIzquierda.is_colliding():
		if not $SensorDerecha.is_colliding():
			velocity.x = SPEED * 1
		if not $SensorIzquierda.is_colliding():
			velocity.x = SPEED * -1
	
	if DEBUG:
		var stats = getSensorStatus()
		# print(stats)
		$"L-IZQ".set_text( "true" if stats[0] else "false" )
		$"L-ABA".set_text( "true" if stats[1] else "false" )
		$"L-ARR".set_text( "true" if stats[2] else "false" )
		$"L-DER".set_text( "true" if stats[3] else "false" )
		
	move_and_slide()
	
	LastPosition = self.position

"""
# Determine if the current position given has never been seen before.
func calculate_pos_and_determine( currentPosition : Vector2i, pastPositions ):
	if currentPosition in pastPositions:
		return false
	return
	
func generateChildren():
	$TileMap.
	var sStatus = getSensorStatus()
	
	print(sStatus)
	if not sStatus[0]:
		var aux = self
		aux.curPos[0] -= 1
		children.append(aux)
		
	if not sStatus[1]:
		var aux = self
		aux.curPos[1] += 1
		children.append(aux)
	
	if not sStatus[2]:
		var aux = self
		aux.curPos[1] -= 1
		children.append(aux)
		
	if not sStatus[3]:
		var aux = self
		aux.curPos[0] += 1
		children.append(aux)
		
	print(children)
	
var testResult = [1,4]
func searchBPP(goal):
	if ConvertVectorToPosition(self.position) == goal:
		print("goal")
		return [self]
	if self in VisitedPositions:
		print("already visited")
		return null
	generateChildren()
	VisitedPositions.append( self )
	for c in children:
		var res = c.searchBPP(goal)
		if res != null:
			return res
	print("faled")
	return null
	
func ConvertPositionToVector(pos : Vector2i):
	print(pos)
	var newpos = pos
	newpos.x *= TileSize
	newpos.y *= TileSize
	return newpos
	
func ConvertVectorToPosition(pos : Vector2):
	print(pos)
	var newpos = pos
	newpos.x /= TileSize
	newpos.y /= TileSize
	return newpos

func _ready():
	print( searchBPP( Vector2(1,4) ) )
	self.position = ConvertPositionToVector(curPos)
"""

# func _physics_process(delta):
	#velocity.x = SPEED * direction.x
	#velocity.y = SPEED * direction.y
	#print(self.position)
	
	#move_and_slide()
