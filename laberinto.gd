extends Node2D

var lastCell
# Called when the node enters the scene tree for the first time.
func _ready():
	var cell = $Exploracion.local_to_map( $Personaje.global_position ) as Vector2i
	cell.x += 1
	cell.y += 1
	var data = $Exploracion.get_cell_tile_data(0, cell) as TileData
	if data:
		lastCell = cell
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var cell = $Exploracion.local_to_map( $Personaje.global_position ) as Vector2i
	var data = $Exploracion.get_cell_tile_data(0, cell) as TileData
	if cell != lastCell:
		print(cell)
		if lastCell != null:
			$Exploracion.set_cell(
				0,
				lastCell,
				0,
				Vector2i(1,0)
				)
		lastCell = cell
	"""
	if data:
		var explorado = data.get_custom_data("Explorado")
		if not explorado:
			data.set_custom_data("Explorado", true)
			print("cambiado")
			print(explorado)
		else:
			print(cell, "ya explorado")
	"""
	pass


func _on_personaje_collided(collision):
	pass
	"""
	if collision.collider is TileMap:
		var cell = $Exploracion.local_to_map( $Personaje.global_position ) as Vector2i
		var data = $Exploracion.get_cell_tile_data(0, cell) as TileData
		if data:
			# Marca el area como explorado.
			$Exploracion.set_cell(0,lastCell,0,Vector2i(1,0))
	"""
