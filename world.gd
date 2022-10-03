extends Node2D

var cell = preload("res://cell.tscn")

var matrix = []
var width = 10
var effect
var recording
var spectrum
var process = false

# AUDIO SHIT
const VU_COUNT = 64 #n of rects
const FREQ_MAX = 1024.0 #check this is correct for whatever you set in the audio effect
const LEFT_X = 0
const BOTTOM_Y = 256
#make sure width/height fits in your view thing
const TOTAL_WIDTH = 512 
const MAX_BAR_HEIGHT = 256
const MIN_DB = 100
var w = (TOTAL_WIDTH / VU_COUNT)/2
var prev_energy = []
var counter = 0
var leng = 0
####

onready var audio_player = $AudioStreamRecord
onready var process_button = $VBoxContainer/Process
onready var record_button = $VBoxContainer/Record

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
	
	prev_energy.resize(VU_COUNT)
	for i in range(prev_energy.size()):
		prev_energy[i] = 0
	
	for x in range(width):
		matrix.append([])
		for y in range(width):
			matrix[x].append(rand_range(-1.0, 1.0))
	
	var idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)
	spectrum = AudioServer.get_bus_effect_instance(idx, 1)

func _physics_process(delta):
	if process == true:
		update() 
		counter += 1
		if counter > leng:
			process = false
			counter = 0

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		generate_cell()

func _on_Record_pressed():
	if effect.is_recording_active():
		recording = effect.get_recording()
		process_button.disabled = false
		effect.set_recording_active(false)
		record_button.text = "Mutate"
		print("End Recording.")
	else:
		process_button.disabled = true
		effect.set_recording_active(true)
		record_button.text = "Stop"
		print("Recording...")

func _on_Process_pressed():
	var data = recording.get_data()
	audio_player.stream = recording
	audio_player.play()
	leng = data.size()
	process = true

func _draw():
	#warning-ignore:integer_division
	var prev_hz = 0
	for i in range(VU_COUNT):
		var hz = i * FREQ_MAX / VU_COUNT;
		var magnitude: float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy = clamp((MIN_DB + linear2db(magnitude)) / MIN_DB, 0, 1) #a decimal
		if energy < prev_energy[i]:
			energy = clamp(prev_energy[i] - 0.01, 0, MAX_BAR_HEIGHT)
		prev_energy[i] = energy
		var height = energy * MAX_BAR_HEIGHT 
		#rect2 takes in x,y,width,height
		draw_rect(Rect2(LEFT_X - (0.5*w) + (2*w * i), BOTTOM_Y - height, w, height), Color(1,1,1)) 
		prev_hz = hz
