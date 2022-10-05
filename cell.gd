extends KinematicBody2D


# vars
var dir
var pos
var direction_vector = Vector2(0,0)
var current_direction = Vector2(0,0)
var neighbours = []
var colliders = []
var velocity = Vector2(0,0)



var colors2 = [
	Color("#000000"),
	Color("#141415"),
	Color("#252525"),
	Color("#444443"),
	Color("#6e6e6e"),
	Color("#9b9c9b"),
	Color("#c4c4c5"),
	Color("#ffffff"),
	Color("#c9c2a3"),
	Color("#75776c"),
	Color("#404945"),
	Color("#27272c"),
	Color("#18181a"),
	Color("#121214"),
	Color("#1e2028"),
	Color("#3d3f4b"),
	Color("#67656d"),
	Color("#8f8685"),
	Color("#b3a49a"),
	Color("#dacdc1"),
	Color("#dad4bc"),
	Color("#b5a793"),
	Color("#897a71"),
	Color("#625353"),
	Color("#3e373d"),
	Color("#28252a"),
	Color("#2a2236"),
	Color("#373448"),
	Color("#424961"),
	Color("#5a748d"),
	Color("#6e95a9"),
	Color("#abd5da"),
	Color("#d8ceeb"),
	Color("#a5a4d0"),
	Color("#888cbc"),
	Color("#7270ab"),
	Color("#575191"),
	Color("#3d2d58"),
	Color("#4c3535"),
	Color("#5e5154"),
	Color("#7b6681"),
	Color("#7c7fae"),
	Color("#e09191"),
	Color("#e3c09d"),
	Color("#e4dcc7"),
	Color("#cab1a8"),
	Color("#7ea095"),
	Color("#667c84"),
	Color("#515457"),
	Color("#3d2929"),
	Color("#23003c"),
	Color("#65005c"),
	Color("#c7005f"),
	Color("#f82542"),
	Color("#fe483c"),
	Color("#f86444"),
	Color("#f8a753"),
	Color("#f2d17c"),
	Color("#dd8944"),
	Color("#c44c26"),
	Color("#ac2027"),
	Color("#6d1f2f"),
	Color("#3f1525"),
	Color("#4d0a1a"),
	Color("#7e0e13"),
	Color("#ba3900"),
	Color("#fc6a08"),
	Color("#fea464"),
	Color("#ffd1ac"),
	Color("#ffdfbf"),
	Color("#f6c4a6"),
	Color("#f6a371"),
	Color("#cb804a"),
	Color("#a15735"),
	Color("#682a19"),
	Color("#371115"),
	Color("#4f291c"),
	Color("#694026"),
	Color("#925c33"),
	Color("#be8f47"),
	Color("#e5c989"),
	Color("#c5c57f"),
	Color("#9c8850"),
	Color("#6f4d2b"),
	Color("#432b23"),
	Color("#261919"),
	Color("#141011"),
	Color("#2e1b00"),
	Color("#512c00"),
	Color("#ae5800"),
	Color("#cd7900"),
	Color("#ffc200"),
	Color("#ffff04"),
	Color("#fcf1d7"),
	Color("#ffdc04"),
	Color("#ffc02a"),
	Color("#c7935d"),
	Color("#636e7c"),
	Color("#363f35"),
	Color("#22130c"),
	Color("#2e2a19"),
	Color("#393f2a"),
	Color("#44563e"),
	Color("#6d7d59"),
	Color("#afb995"),
	Color("#222e14"),
	Color("#39471c"),
	Color("#5d6527"),
	Color("#8e8e37"),
	Color("#beb050"),
	Color("#ebe185"),
	Color("#b0bb5b"),
	Color("#659257"),
	Color("#64754a"),
	Color("#345d41"),
	Color("#37403c"),
	Color("#1b2b3e"),
	Color("#1b4b4f"),
	Color("#327962"),
	Color("#53a96f"),
	Color("#72e27f"),
	Color("#a4ffa6"),
	Color("#c1f567"),
	Color("#6ac81f"),
	Color("#049050"),
	Color("#00666a"),
	Color("#003b62"),
	Color("#001049"),
	Color("#271f4b"),
	Color("#263267"),
	Color("#2a5480"),
	Color("#30787c"),
	Color("#53bf83"),
	Color("#8cd590"),
	Color("#86f1d6"),
	Color("#4ddbc2"),
	Color("#30b3a7"),
	Color("#238585"),
	Color("#1e5459"),
	Color("#162c31"),
	Color("#001717"),
	Color("#003333"),
	Color("#005050"),
	Color("#006f6f"),
	Color("#048e8e"),
	Color("#04aeae"),
	Color("#a5e5da"),
	Color("#6fbdd5"),
	Color("#398dd5"),
	Color("#3056ac"),
	Color("#353287"),
	Color("#251644"),
	Color("#28183c"),
	Color("#392269"),
	Color("#5042ac"),
	Color("#586dd0"),
	Color("#789eec"),
	Color("#a9d4fb"),
	Color("#cbabda"),
	Color("#a27cb7"),
	Color("#745888"),
	Color("#504261"),
	Color("#3a3346"),
	Color("#292236"),
	Color("#26122e"),
	Color("#4e1740"),
	Color("#7c2c52"),
	Color("#ca4464"),
	Color("#f17878"),
	Color("#ecb2a4"),
	Color("#fbb3e6"),
	Color("#cc75af"),
	Color("#a6557b"),
	Color("#834a59"),
	Color("#5a4143"),
	Color("#312e2e"),
	Color("#461623"),
	Color("#681a2f"),
	Color("#891a37"),
	Color("#aa1e42"),
	Color("#c74453"),
	Color("#ea7e82")
]




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

