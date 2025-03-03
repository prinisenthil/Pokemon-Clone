extends CharacterBody2D

const speed = 80
var current_dir = "none"

var tilemap  # Reference to the TileMap

var player_moving = false
var can_encounter = true

var camera # Reference to the current camera
var shake_intensity = 5 # How intense the shake is
var shake_duration = 0.5 # How long the shake lasts
var shake_timer = 0.0 # Internal timer to track the shake
var battle_playing = false

var shake_audio

func _ready() -> void:
	$AnimatedSprite2D.play("front_idle")
	tilemap = get_parent().get_node("TileMap")
	camera = $WorldCamera
	shake_audio = $BattleTransitionMusic
	

func _physics_process(delta: float) -> void:
	battle_transition(delta)
	player_movement(delta)
	check_grass_tile()

func player_movement(delta):
	if not battle_playing:
		if Input.is_action_pressed("ui_right"):
			current_dir = "right"
			play_anim(1)
			velocity.x = speed
			velocity.y = 0
		
		elif Input.is_action_pressed("ui_left"):
			current_dir = "left"
			play_anim(1)
			velocity.x = -speed
			velocity.y = 0
			
		elif Input.is_action_pressed("ui_down"):
			current_dir = "down"
			play_anim(1)
			velocity.x = 0
			velocity.y = speed

		elif Input.is_action_pressed("ui_up"):
			current_dir = "up"
			play_anim(1)
			velocity.x = 0
			velocity.y = -speed
			
		else:
			play_anim(0)
			velocity.x = 0
			velocity.y = 0
			
		move_and_slide()
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0
	
func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	if movement == 1:
		player_moving = true
		if dir == "right":
			anim.play("right_walk")
		if dir == "left":
			anim.play("left_walk")
		if dir == "up":
			anim.play("back_walk")
		if dir == "down":
			anim.play("front_walk")
	else:
		player_moving = false
		if dir == "right":
			anim.play("right_idle")
		if dir == "left":
			anim.play("left_idle")
		if dir == "up":
			anim.play("back_idle")
		if dir == "down":
			anim.play("front_idle")


func check_grass_tile():
	if can_encounter:
		var player_position = global_position  # Player's world position
		var tile_position = tilemap.local_to_map(tilemap.to_local(player_position))  # Convert world position to tilemap coordinates
		#print(tile_position)
		var tile_id = tilemap.get_cell_tile_data(1, tile_position)  # Get the Tile ID at that position
		#print(tile_id)
		if not tile_id == null:
			var type = tile_id.get_custom_data("type")
			#print(type)
			if type == "grass" and player_moving:
				can_encounter = false
				$GrassWalking.start()
				randomize_logic()
			

func randomize_logic():
	var random_value = randi() % 5  # 20% chance
	if random_value == 1:
		battle_playing = true
		start_camera_shake()


func _on_grass_walking_timeout() -> void:
	can_encounter = true

func battle_transition(delta):
	if shake_timer > 0:
		shake_timer -= delta
		# Randomly adjust the camera's offset within a small range
		camera.offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		if not shake_audio.playing:
			shake_audio.play()
	else:
		# Reset the camera offset when shaking stops
		camera.offset = Vector2(0, 0)
		shake_audio.stop()

# Call this function to start camera shake transition
func start_camera_shake():
	shake_timer = shake_duration # Set the timer to start shaking
	await get_tree().create_timer(0.5).timeout
	Global.changing_battle = true
	Global.world = "battle"
