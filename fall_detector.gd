extends Area2D  # ← MUST BE A NODE TYPE

func _on_FallDetector_body_entered(body):
	if body.name == "Player":
		print("☠️ Game Over")
		get_tree().reload_current_scene()
