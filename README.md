# Godot-Labyrinth
A small program that tells a CharacterBody2D to move around a maze on its own. 
Homework for an AI class.

## Calculations

To perform it's calculations, it performs a conversion from a global space to a map space relative to the TileMap being used in the project. This in term allows for easier calculation of neighbors than using an entire infinite-like space enviroment.

```gdscript
func getGlobalTilePosition(given_pos):
	var pos = $Exploracion.local_to_map( given_pos ) as Vector2i
	return pos
```

This also uses sensors, as requested in the assignment, which are used for collision detection, given `move_and_collide` turned out to be an annoying function to use for this kind of activity. So instead, the movement is done manually via an approach with `move_toward`.

```gdscript
var GlobalNewPosition = tilePositionToGlobal(destination)
if (destination.y > newposition.y) and $SensorAbajo.is_colliding():
    destination = null
    TouchedTile.emit( newposition )
    return
global_position = global_position.move_toward(GlobalNewPosition, delta*SPEED )
```