extends CharacterBody2D

var jump_force := 700.0
var gravity := 1500.0
var speed := 800.0
var double_jump_force := 400.0
var turn_speed_reduction := 0.5

var has_double_jumped = false

@onready var anim = $AnimatedSprite2D

func _physics_process(delta):
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0  # Reset vertical velocity when grounded
	print("Y: ", velocity.y, " | On floor: ", is_on_floor())
	print("GRAVITY:", gravity)

	
	# Horizontal movement
	var move_input := 0
	if Input.is_action_pressed("ui_right"):
		move_input = 1
		anim.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		move_input = -1
		anim.flip_h = true

	velocity.x = move_input * speed * turn_speed_reduction

	# Jump
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = -jump_force
			has_double_jumped = false
			anim.play("jump")
		elif not has_double_jumped:
			velocity.y = -double_jump_force
			has_double_jumped = true
			anim.play("jump")

	# Animation logic
	if not is_on_floor():
		if anim.animation != "jump":
			anim.play("jump")
	elif move_input != 0:
		if anim.animation != "walk":
			anim.play("walk")
	else:
		if anim.animation != "idle":
			anim.play("idle")

	# Apply movement
	move_and_slide()
