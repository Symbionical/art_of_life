extends Node2D

var cell = preload("res://cell.tscn")

var matrix = []
var width = 10

func generate_cell():
	
	var newCell = cell.instance()
	newCell.position = Vector2(rand_range(10.0, 1000.0), rand_range(10.0, 500.0))
	add_child(newCell)
	newCell.randomise_genes()

func create_daughter(mother):
	var daughterCell = cell.instance()
	daughterCell.speed = mother.speed
	daughterCell.size = mother.size
	daughterCell.split_size = daughterCell.size*2
	daughterCell.type = mother.type
	daughterCell.modulate = daughterCell.colors[daughterCell.type]
	daughterCell.velocity = -mother.velocity
	daughterCell.position = Vector2(mother.position.x + (5*mother.size)*((-1)*sign(mother.velocity.x)), mother.position.y + (5*mother.size)*((-1)*sign(mother.velocity.y)))
	add_child(daughterCell)
	daughterCell.update_size(daughterCell.size)

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(width):
		matrix.append([])
		for y in range(width):
			matrix[x].append(rand_range(-1.0, 1.0))
			
			

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		generate_cell()


