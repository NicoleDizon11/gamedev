extends Area2D

@onready var sprite = $Sprite2D
@onready var particles = $PickupParticles2D  # Make sure the particle node is named 'PickupParticles2D'
@onready var pickup_sound = $PickupSound  # Add this AudioStreamPlayer node!

var duration := 10.0  # How long slow-mo lasts
var slow_factor := 2.0  # How much slower

func _ready():
	connect("body_entered", _on_body_entered)

	# Check if the particles node exists (just in case)
	if not particles:
		print("⚠️ Error: PickupParticles2D node not found!")
		return
	particles.emitting = false  # Ensure particles don't emit on start

func _on_body_entered(body):
	if body.name == "Player":
		var root = get_tree().root
		var platforms = root.get_node("Game").get_children()  # Adjust this path if needed

		for platform in platforms:
			if platform.has_method("start_timer_to_reset") and not platform.color_locked:
				platform.switch_interval *= slow_factor
				platform.start_timer_to_reset(duration)

		print("🐢 Slow-mo activated for all platforms!")

		# Emit particle effect
		if particles:
			particles.emitting = true
			print("💨 Power-up particles emitted!")

		# Play sound effect
		if pickup_sound:
			pickup_sound.play()
			
		await pickup_sound.finished
		queue_free()


		# Delay to let particles and sound finish
		await get_tree().create_timer(0.4).timeout
		queue_free()
