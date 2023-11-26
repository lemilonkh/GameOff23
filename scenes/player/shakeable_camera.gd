extends Camera2D
class_name ShakeableCamera

@export var decay := 0.4 # How quickly the shaking stops [0, 1]
@export var max_offset := Vector2(256, 256) # Maximum hor/ver shake in pixels
@export var max_roll := 0.1 # Maximum rotation in radians (use sparingly)
@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var noise_speed := 17.4

var trauma := 0.0 # Current shake strength
var trauma_power := 2 # Trauma exponent. Use [2, 3]
var time := 0.0
var noise_x := 0.0

func add_trauma(trauma_amount: float) -> void:
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)
	noise_x = randf_range(0, 100)

func _ready() -> void:
	randomize()
	noise.seed = randi()

func _process(delta) -> void:
	time += delta
	if trauma > 0:
		trauma = max(trauma - decay * delta, 0)
		_shake()
	else:
		offset = Vector2.ZERO
		rotation = 0

func _shake() -> void:
	var noise_y := noise_speed * time
	var amount := pow(trauma, trauma_power)
	rotation = max_roll * amount * noise.get_noise_2d(noise_x * 1.3, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise_x * 2.1, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise_x * 3.7, noise_y)
