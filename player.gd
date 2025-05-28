extends CharacterBody2D

var jump_force := 500.0
var gravity := 1300.0
var speed := 1000.0
var double_jump_force := 400.0
var turn_speed_reduction := 0.5

var has_double_jumped = false
var current_color = Color.RED

var has_color_shield = false
var shield_timer: Timer

# 🧱 Solid platform hit tracking
var solid_platform_hit_count := 0
const MAX_SOLID_HITS := 3

@onready var anim = $AnimatedSprite2D
@onready var jump_sound = $JumpSound

func _ready():
	shield_timer = Timer.new()
	shield_timer.wait_time = 5.0
	shield_timer.one_shot = true
	shield_timer.timeout.connect(_on_shield_timeout)
	add_child(shield_timer)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0

	var move_input := 0
	if Input.is_action_pressed("ui_right"):
		move_input = 1
		anim.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		move_input = -1
		anim.flip_h = true

	velocity.x = move_input * speed * turn_speed_reduction

	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = -jump_force
			has_double_jumped = false
			anim.play("jump")
			_play_jump_sound()
		elif not has_double_jumped:
			velocity.y = -double_jump_force
			has_double_jumped = true
			anim.play("jump")
			_play_jump_sound()

	if not is_on_floor():
		if anim.animation != "jump":
			anim.play("jump")
	elif move_input != 0:
		if anim.animation != "walk":
			anim.play("walk")
	else:
		if anim.animation != "idle":
			anim.play("idle")

	move_and_slide()

	# Solid collision check
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		if collision:
			var collider = collision.get_collider()
			if collider and collider.has_method("is_solid_platform"):
				if collider.is_solid_platform() and not has_color_shield:
					solid_platform_hit_count += 1
					print("⚠️ Hit solid platform:", solid_platform_hit_count, "time(s)")
					if solid_platform_hit_count >= MAX_SOLID_HITS:
						_trigger_game_over()

	# TEMP color swap
	if Input.is_action_just_pressed("Red"):
		change_color(Color.RED)
	elif Input.is_action_just_pressed("Green"):
		change_color(Color.GREEN)
	elif Input.is_action_just_pressed("Blue"):
		change_color(Color.BLUE)

func change_color(new_color: Color):
	current_color = new_color
	anim.modulate = new_color
	print("Player color changed to:", new_color)

func _play_jump_sound():
	if jump_sound:
		jump_sound.stop()
		jump_sound.play()

func activate_color_shield(duration: float):
	has_color_shield = true
	shield_timer.wait_time = duration
	shield_timer.start()
	print("🛡️ Color shield activated!")

func _on_shield_timeout():
	has_color_shield = false
	print("🛡️ Color shield expired.")

func _trigger_game_over():
	print("💥 Game Over: Hit solid platform 3 times.")
	set_physics_process(false)
	set_process(false)

	var hud = get_node_or_null("/root/Game/HUD")
	if hud and hud.has_node("GameOverMenu"):
		hud.get_node("GameOverMenu").visible = true
	else:
		print("⚠️ HUD or GameOverMenu not found.")

# RESET after Game Over
func reset_solid_hit_count():
	solid_platform_hit_count = 0
	print("🔁 Solid hit count reset.")
