extends Area2D

@onready var sprite = $Sprite2D

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.name != "Player":
		return

	# Find overlapping bodies under the power-up
	var overlapping = get_overlapping_bodies()
	for obj in overlapping:
		if obj.name == "Player":
			continue  # Ignore the player itself

		# Check if it's a color-changing platform
		if obj.has_method("get_current_color"):
			var platform_color = obj.get_current_color()
			body.current_color = platform_color
			body.modulate = platform_color
			print("✅ Power-up activated: Player synced to color:", platform_color)
			queue_free()
			return

	print("⚠️ Power-up failed: No platform with color under power-up.")
