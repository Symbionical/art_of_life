extends Node2D

var rng = RandomNumberGenerator.new()
var cell = preload("res://cell.tscn")
var audio = preload("res://audio.tscn")

var n_cell_types = 182
var n_attributes = n_cell_types + 4 # n colours + type + speed + radius + attr_rad_mod
var max_speed = 20
var min_speed = 10
var max_rad = 1.5
var min_rad = 0.2
var max_attr_mod = 0.1 #fraction of radius
var min_attr_mod = -0.1 #fraction of radius

var matrix = []
var audio_stream_sample
var spectrum_short_buffer
var spectrum_long_buffer
var recording
var process = false

# AUDIO SHIT
const VU_COUNT = 64 #n of rects
const FREQ_MAX = 1024.0 #check this is correct for whatever you set in the audio effect
const LEFT_X = 0
const BOTTOM_Y = 500
const TOTAL_WIDTH = 512 #make sure width fits in your view thing
const MAX_BAR_HEIGHT = 256 #make sure height fits in your view thing
const MIN_DB = 100
var w = (TOTAL_WIDTH / VU_COUNT)/2
var prev_energy = []
var counter = 0
var leng = 0

####

onready var audio_player = $AudioRecord
onready var process_button = $VBoxContainer/Process
onready var record_button = $VBoxContainer/Record

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	prev_energy.resize(VU_COUNT)
	for i in range(prev_energy.size()):
		prev_energy[i] = 0
	
	for x in range(n_cell_types):
		matrix.append([])
		for y in range(n_cell_types):
			matrix[x].append(rand_range(-1.0, 1.0))
	
	var idx = AudioServer.get_bus_index("Record")
	audio_stream_sample = AudioServer.get_bus_effect(idx, 0)
	spectrum_short_buffer = AudioServer.get_bus_effect_instance(idx, 1)
	spectrum_long_buffer = AudioServer.get_bus_effect_instance(idx, 2)

func refresh_audio():
	audio_player = audio.instance()
	self.add_child(audio_player)
	var idx = AudioServer.get_bus_index("Record")
	audio_stream_sample = AudioServer.get_bus_effect(idx, 0)
	spectrum_short_buffer = AudioServer.get_bus_effect_instance(idx, 1)
	spectrum_long_buffer = AudioServer.get_bus_effect_instance(idx, 2)

func generate_random_cell():
	rng.seed = hash("Godot")
	rng.state = 100 # Restore to some previously saved state.
	rng.randomize()
	var screen_size = get_viewport_rect().size
	var init_pos  = Vector2(rand_range(10.0, screen_size.x - 10), rand_range(10.0, screen_size.y - 10))
	var init_vel = Vector2(rand_range(-min_speed,min_speed),rand_range(-min_speed,min_speed))
	generate_specific_cell(rng.randi_range(0,n_cell_types-1), rand_range(min_speed,max_speed), rand_range(min_rad,max_rad), rand_range(min_attr_mod,max_attr_mod), init_vel, init_pos)

func generate_specific_cell(type,speed,radius,attraction_mod,velocity,pos):
	var newCell = cell.instance()
	newCell.type = type
	newCell.modulate = newCell.colors2[type]
	newCell.speed = speed
	newCell.size = PI*pow(radius,2)
	newCell.split_size = newCell.size*2
	newCell.attraction_mod = attraction_mod
	newCell.direction_vector = velocity
	newCell.position = pos
	add_child(newCell)
	newCell.update_size(newCell.size)
	
############################### SOUND STUFF

func _physics_process(_delta):
	if process == true:
		update() 
		counter += 1
		if counter > leng:
			process = false
			counter = 0
			voice_to_genes()

func _process(delta):
	if Input.is_action_just_pressed("generate"):
		generate_random_cell()
	

func _on_Record_pressed():
	if audio_stream_sample.is_recording_active():
		recording = audio_stream_sample.get_recording()
		audio_stream_sample.set_recording_active(false)
		process_button.disabled = false
		record_button.text = "Mutate"
		print("End Recording.")
	else:
		audio_stream_sample.set_recording_active(true)
		process_button.disabled = true
		record_button.text = "Stop"
		print("Recording...")

func _on_Process_pressed():
	audio_player.stream = recording
	audio_player.play()
	leng = audio_player.stream.get_length() * Performance.get_monitor(Performance.TIME_FPS)
	process = true

func get_freq_range_energy(spectrum, min_hz, max_hz):
	var magnitude: float = spectrum.get_magnitude_for_frequency_range(min_hz, max_hz, 0).length()
	var energy = clamp((MIN_DB + linear2db(magnitude)) / MIN_DB, 0, 1) #a decimal
	return energy

func voice_to_genes():
	var prev_hz = 0
	var type
	var speed
	var radius
	var attraction_mod
	
	var total_energy = get_freq_range_energy(spectrum_long_buffer,0,FREQ_MAX)
	if total_energy != 0:
		for i in range(n_attributes): 
			var hz = (i+1) * FREQ_MAX / n_attributes
			var energy = get_freq_range_energy(spectrum_long_buffer,prev_hz,hz)
			prev_hz = hz
			var frac = fposmod(((energy/total_energy)*n_attributes),1)
			if i == 0:
				type = floor(frac*n_cell_types) 
			elif i == 1:
				speed = min_speed + ((max_speed-min_speed)*frac)
			elif i == 2:
				radius = min_rad + ((max_rad-min_rad)*frac)
			elif i == 3:
				attraction_mod = min_attr_mod + ((max_attr_mod-min_attr_mod)*frac)
			elif i > 4: #these are the relational attributes
				matrix[type][i-4] = (frac*2)-1
		var screen_size = get_viewport_rect().size
		var init_pos = Vector2(rand_range(10,screen_size.x-10),rand_range(10,screen_size.y-10))
		var init_vel = Vector2(rand_range(-min_speed,min_speed),rand_range(-min_speed,min_speed))
		generate_specific_cell(type,speed,radius,attraction_mod,init_vel,init_pos)
	else: 
		generate_random_cell() 
		print("Warning: couldn't generate a mutant cell. Nothing was in the recording buffer. Maybe microphone issue? Generating random cell instead...")
	
	audio_player.queue_free()
	refresh_audio()


func _draw():
	#warning-ignore:integer_division
	if process == true:
		var prev_hz = 0
		for i in range(VU_COUNT):
			var hz = i * FREQ_MAX / VU_COUNT
			var energy = get_freq_range_energy(spectrum_short_buffer,prev_hz,hz)
			if energy < prev_energy[i]:
				energy = clamp(prev_energy[i] - 0.01, 0, MAX_BAR_HEIGHT)
			prev_energy[i] = energy
			var height = energy * MAX_BAR_HEIGHT 
			#rect2 takes in x,y,width,height
			draw_rect(Rect2(LEFT_X - (0.5*w) + (2*w * i), BOTTOM_Y - height, w, height), Color(1,1,1)) 
			prev_hz = hz
