extends Node2D

var lastCell = Vector2i()
	
func getGlobalTilePosition(given_pos):
	var pos = $Exploracion.local_to_map( given_pos ) as Vector2i
	return pos
	
func isValidBlock(cursorTilePos):
	var data = $TileMap.get_cell_atlas_coords(0, cursorTilePos) as Vector2i
	return data == Vector2i(0,0)

func MarkCellIfPassed():
	var cell = getGlobalTilePosition($Personaje.global_position)
	if cell != lastCell:
		if lastCell != null:
			ForceSetTileAsPassed(lastCell)
		lastCell = cell
		
func ForceSetTileAsPassed(cellPosition : Vector2i):
	$Exploracion.set_cell(0,cellPosition,0,Vector2i(1,0))

# Called when the node enters the scene tree for the first time.
func _ready():
	$GuiInformation.set_visible(true)
	# Marca el cuadro inicial como ya encontrado, para hacer que el personaje se mueva.
	lastCell = getGlobalTilePosition($Personaje.global_position)
	$Exploracion.set_cell(0,lastCell,0,Vector2i(1,0))
	MarkCellIfPassed()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(ev):
	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
		var position_cursor = getGlobalTilePosition(get_global_mouse_position())
		if not isValidBlock( position_cursor ):
			return
		$GuiInformation.set_visible(false)
		$Personaje.setExpectedGoal( position_cursor )

func _on_personaje_touched_tile(given_collision : Vector2i):
	ForceSetTileAsPassed(given_collision)

func _on_personaje_reached_goal():
	$GuiInformation.set_visible(true)
	$GuiInformation/Label.set_text("¡Alcancé al objetivo!")
