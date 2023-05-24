extends CharacterBody2D


const SPEED = 300.0
var direction = Vector2(0,0)
const JUMP_VELOCITY = -400.0
var curPos = Vector2i(128*1,128*1)

var VisitedPositions = []

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Determine if the current position given has never been seen before.
func calculate_pos_and_determine( currentPosition, pastPositions ):
	if currentPosition in pastPositions:
		return false
	return true

func _physics_process(delta):
	#direction.x = 0
	#direction.y = 0
	"""
	if is_on_wall():
		direction.x = direction.x * -1
		
	if is_on_ceiling():
		direction.y = direction.y * -1
	
	if is_on_floor():
		direction.y = direction.y * -1
	"""
	
	if not curPos in VisitedPositions:
		VisitedPositions.append( curPos )
	
	print( "%s %s %s %s" % 
		[$SensorIzquierda.is_colliding(),
		$SensorAbajo.is_colliding(),
		$SensorArriba.is_colliding(),
		$SensorDerecha.is_colliding()]
	)
	
	var posCalc = curPos
	
	if not $SensorAbajo.is_colliding():
		posCalc[1] += 128
		if calculate_pos_and_determine(posCalc, VisitedPositions):
			curPos = posCalc
			
	if not $SensorDerecha.is_colliding():
		posCalc[0] += 128
		if calculate_pos_and_determine(posCalc, VisitedPositions):
			curPos = posCalc
			
	if not $SensorArriba.is_colliding():
		posCalc[1] -= 128
		if calculate_pos_and_determine(posCalc, VisitedPositions):
			curPos = posCalc
		
	"""
	if not $SensorArriba.is_colliding() and not $SensorAbajo.is_colliding():
		if $SensorArriba.is_colliding() and not $SensorAbajo.is_colliding():
			curPos[1] += 128
		if $SensorAbajo.is_colliding() and not $SensorArriba.is_colliding():
			curPos[1] -= 128
	else:
		if $SensorArriba.is_colliding():
			curPos[1] += 128
		
	if not $SensorDerecha.is_colliding() and not $SensorIzquierda.is_colliding():
		if not $SensorDerecha.is_colliding():
			curPos[0] += 128
		if not $SensorIzquierda.is_colliding():
			curPos[0] -= 128
	"""
	
	self.position = curPos
	#velocity.x = SPEED * direction.x
	#velocity.y = SPEED * direction.y

	move_and_slide()
