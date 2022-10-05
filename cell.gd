extends KinematicBody2D


# vars
var dir
var pos
var direction_vector = Vector2(0,0)
var current_direction = Vector2(0,0)
var neighbours = []
var colliders = []
var velocity = Vector2(0,0)

var colors = [
	Color("#e8f1a6"),
	Color("#cad670"),
	Color("#a3c255"),
	Color("#6fa341"),
	Color("#498f45"),
	Color("#387450"),
	Color("#2d5c56"),
	Color("#1f3741"),
	Color("#1e2029"),
	Color("#16161c")
]

# GENES
var type = 1 
var attraction_mod = 0
var speed = 3
var radius = 0.1
var size = PI*pow(radius,2)
var split_size = size*2

onready var screen_size = get_viewport_rect().size
onready var colisionRadius = $collisions
onready var attractionRadius = $Area2D 
onready var color = $Sprite.modulate
onready var minimum_speed = GlobalWorld.min_speed

func try_reproduction():
	if size > split_size:
		var remainder = size - split_size
		self.update_size((split_size/2)+remainder)
		var daughter_pos = Vector2(self.position.x + (5*self.radius)*((-1)*sign(self.velocity.x)), self.position.y + (5*self.radius)*((-1)*sign(self.velocity.y)))
		var daughter_rad = sqrt((split_size/2)/PI)
		GlobalWorld.generate_specific_cell(self.type,self.speed,daughter_rad,self.attraction_mod,-self.velocity,daughter_pos)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func lerp(a, b, t):
	return (1 - t) * a + t * b

func _process(delta):
	handle_forces(delta)
	try_reproduction()
#	wrap()

func _physics_process(delta):
	velocity = move_and_slide(velocity,Vector2(0, 0))

func wrap():
	position.x = wrapf(position.x, 0, screen_size.x)
	position.y = wrapf(position.y, 0, screen_size.y)

func handle_predation():
	colliders = colisionRadius.get_overlapping_bodies()
	if colliders != []:
		for c in colliders:
			if "size" in c:
				if c.size > self.size and c.type != self.type:
					c.update_size(c.size+self.size)
					self.queue_free()
			elif c.name == "boundary":
				direction_vector = Vector2(960,540) - self.position
				current_direction.x = lerp(current_direction.x,direction_vector.x,0.1)
				current_direction.y = lerp(current_direction.y,direction_vector.y,0.1)
				velocity = current_direction*speed
				velocity.x = max(velocity.x,minimum_speed)*sign(velocity.x)
				velocity.y = max(velocity.y,minimum_speed)*sign(velocity.y)
				

func handle_forces(_delta):
	neighbours = attractionRadius.get_overlapping_bodies()
	if neighbours != []:
		var current_winner = 0
		var winning_neighbour = null
		for i in len(neighbours):
			if "type" in neighbours[i]:
				var neighbour = neighbours[i]
				var val = GlobalWorld.matrix[self.type][neighbour.type]
				if abs(val) > abs(current_winner):
					current_winner = val
					winning_neighbour = neighbour
			if winning_neighbour != null:
				if sign(current_winner) < 0:
					#run away
					direction_vector = self.position - winning_neighbour.position
				else:
					#come closer
					direction_vector = winning_neighbour.position - self.position
				current_direction.x = lerp(current_direction.x,direction_vector.x,0.1)
				current_direction.y = lerp(current_direction.y,direction_vector.y,0.1)
				velocity = current_direction*speed
				velocity.x = max(velocity.x,minimum_speed)*sign(velocity.x)
				velocity.y = max(velocity.y,minimum_speed)*sign(velocity.y)
		handle_predation()

func update_size(new_size):
	var newTween = create_tween()
	radius = sqrt(new_size/PI)
	newTween.tween_property(self,"scale",Vector2(radius,radius),0.2)
	size = new_size
	attractionRadius.scale = Vector2(radius + (attraction_mod*radius),radius + (attraction_mod*radius))

