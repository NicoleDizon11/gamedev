extends Area2D

@onready var game_over_sound = $GameOverSound

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		print("💀 Player entered the kill zone!")

		# Stop player movement
		body.set_process(false)
		body.set_physics_process(false)

		# Play game over sound
		game_over_sound.play()
		await game_over_sound.finished

		# Show Game Over UI
		var hud = get_node("/root/Game/HUD")
		if hud and hud.has_node("GameOverMenu"):
			hud.get_node("GameOverMenu").visible = true
			print("📺 Game Over screen displayed.")
		else:
			print("⚠️ HUD or GameOverMenu not found.")

		# Optional: Reset solid hit count so it's clean for replay
		if body.has_method("reset_solid_hit_count"):
			body.reset_solid_hit_count()
