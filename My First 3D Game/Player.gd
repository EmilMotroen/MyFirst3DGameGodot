extends CharacterBody3D

# Emitted when the player is hit by a mob
signal hit

# How fast the player moves in m/s
@export var speed = 14
# The downward acceleration when in the air, in m/s^2
@export var fall_acceleration = 75
# Vertical impulse applied to the character upon jumping in m/s
@export var jump_impulse = 20
# Vertical impulse applied to the character upon bouncing over a mob in m/s
@export var bounce_impulse = 16

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
		$AnimationPlayer.speed_scale = 4
	else:
		$AnimationPlayer.speed_scale = 1
		
	$Pivot.rotation.x = PI / 6 * velocity.y / jump_impulse
		
	# Ground velocity
	target_velocity.x = direction.x * speed	
	target_velocity.z = direction.z * speed
	
	# Vertical velocity
	if not is_on_floor(): # If in the air, move vertically. Gravity.
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
		
	# Jumping
	if is_on_floor() and Input.is_action_pressed("jump"):
		target_velocity.y = jump_impulse
		
	# Iterate through all collisions that occured in this frame
	for index in range(get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision = get_slide_collision(index)
		
		# If the collision is with the ground
		if collision.get_collider() == null:
			continue
		
		# If the collision is with a mob
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			# Check if we are hitting it from above
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				# If so, squash it and bounce
				mob.squash()
				target_velocity.y = bounce_impulse
				
				# Prevent further duplicate calls
				break
	
	# Moving the character
	velocity = target_velocity
	move_and_slide()
	
	
func die():
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(body):
	die()
