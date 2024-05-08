extends CharacterBody3D

# How fast the player moves in meters/sec
@export var speed = 14
# The downward acceleration when in the air, in meters/s^2
@export var fall_acceleration = 75

var target_velocity = Vector3.ZERO

func _physics_process(delta):
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	# Working with the vector's x and z axes
	# In 3D, the XZ plane is the ground plane
	if Input.is_action_pressed("move_up"):
		direction.z -= 1
	if Input.is_action_pressed("move_down"):
		direction.z += 1
	
	if direction != Vector3.ZERO:
		# If feks W and D are pressed simultaneously, the vector will have a length of about 
		# 1.4, but if a single button is pressed it will have a length of 1. the .normalized() will
		# make the vector be consistent and not move faster diagonally
		direction = direction.normalized()
		# Setting the basis will affect the rotation of the node
		$Pivot.basis = Basis.looking_at(direction)
		
	# Ground velocity
	target_velocity.x = direction.x * speed	
	target_velocity.z = direction.z * speed
	
	# Vertical velocity
	if not is_on_floor(): # If in the air, move vertically. Gravity.
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
		
	# Moving the character
	velocity = target_velocity
	move_and_slide()
	
	
