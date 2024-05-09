extends CharacterBody3D

# Emitted when the player jumps on the mob
signal squashed

# Minimum speed of the mob in meters per second
@export var min_speed = 10
# Maximum speed of the mob in meters per second
@export var max_speed = 18

func _physics_process(delta):
	move_and_slide()
	
	
func squash():
	squashed.emit()
	queue_free()


func initialize(start_position, player_position):
	# Position the mob by placing it at the start_position
	# and rotate it towards the players position
	look_at_from_position(start_position, player_position, Vector3.UP)
	# Rotate the mob +- 45 degrees so that it doesn't move directly
	# towards the player
	rotate_y(randf_range(-PI / 4, PI /4))
	
	# Get a random speed as an integer
	var random_speed = randi_range(min_speed, max_speed)
	# Calculate the forward velocity that represents the speed
	velocity = Vector3.FORWARD * random_speed
	# Rotate the velocity vector based on the mobs Y rotation
	# in order to move in the direction the mob is looking 
	velocity = velocity.rotated(Vector3.UP, rotation.y)


func _on_visible_on_screen_notifier_3d_screen_exited():
	queue_free()
