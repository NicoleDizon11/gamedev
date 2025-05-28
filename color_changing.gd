extends Area2D

@onready var sprite = $Sprite2D
@onready var detector_collision = $CollisionShape2D
@onready var ground = $Ground
@onready var ground_collision = $Ground/CollisionShape2D

var colors = [Color.RED, Color.GREEN, Color.BLUE]
var current_index = 0
var switch_interval = 1.0
var original_switch_interval = 1.0
var timer = 0.0
var color_locked = false
var reset_timer: Timer = null

func _ready():
	connect("body_entered", _on_body_entered)
	sprite.modulate = colors[current_index]
	ground_collision.disabled = true
	original_switch_interval = switch_interval  # Always store on ready

func _process(delta):
	if color_locked:
		return

	timer += delta
	if timer > switch_interval:
		timer = 0.0
		current_index = (current_index + 1) % colors.size()
		sprite.modulate = colors[current_index]

func _on_body_entered(body):
	if body.name == "Player":
		print("Player stepped on platform!")
		print("Player color:", body.current_color)
		print("Platform color:", colors[current_index])

		if body.current_color == colors[current_index] or body.has_color_shield:
			color_locked = true
			call_deferred("_enable_ground_collision")
			if body.has_color_shield and body.current_color != colors[current_index]:
				print("🛡️ Shield match override — Platform locked!")
			else:
				print("MATCH — Platform locked and solid!")
		else:
			call_deferred("_disable_ground_collision")
			print("NO MATCH — Platform is not solid!")
		
		# 🆕 Award 1 point for each successful match
	var hud = get_node_or_null("/root/Game/HUD")
	if hud and hud.has_method("add_score"):
		hud.add_score(1)
func _enable_ground_collision():
	if ground_collision:
		ground_collision.disabled = false
		print("Platform collision ENABLED.")

func _disable_ground_collision():
	if ground_collision and not color_locked:
		ground_collision.disabled = true
		print("Platform collision DISABLED.")

# 🕒 Slomo timer trigger from power-up
func start_timer_to_reset(duration):
	if reset_timer and reset_timer.is_inside_tree():
		reset_timer.queue_free()

	switch_interval *= 2.0  # Slow down
	reset_timer = Timer.new()
	reset_timer.wait_time = duration
	reset_timer.one_shot = true
	reset_timer.timeout.connect(_on_reset_timeout)
	add_child(reset_timer)
	reset_timer.start()

func _on_reset_timeout():
	switch_interval = original_switch_interval
	reset_timer.queue_free()
	reset_timer = null
	print("⏱️ Platform speed restored.")

# ✅ NEW: Add this method so Player can query platform's solid state
func is_solid_platform() -> bool:
	return color_locked and not ground_collision.disabled
