extends Node2D

var lastCell = Vector2i()

func getTilePosition():
	var pos = $Exploracion.local_to_map( $Personaje.global_position ) as Vector2i
	return pos

func MarkCellIfPassed():
	var cell = getTilePosition()
	# var data = $Exploracion.get_cell_tile_data(0, cell) as TileData
	if cell != lastCell:
		print(cell)
		if lastCell != null:
			$Exploracion.set_cell(0,lastCell,0,Vector2i(1,0))
		lastCell = cell
		
func ForceSetTileAsPassed(cellPosition : Vector2i):
	$Exploracion.set_cell(0,cellPosition,0,Vector2i(1,0))

# Called when the node enters the scene tree for the first time.
func _ready():
	# Marca el cuadro inicial como ya encontrado, para hacer que el personaje se mueva.
	lastCell = getTilePosition()
	$Exploracion.set_cell(0,lastCell,0,Vector2i(1,0))
	MarkCellIfPassed()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	# MarkCellIfPassed()

func _on_personaje_touched_tile(given_collision : Vector2i):
	ForceSetTileAsPassed(given_collision)
	pass # Replace with function body.
