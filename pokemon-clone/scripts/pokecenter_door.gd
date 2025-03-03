extends Area2D

@onready var door_area = self  # Reference to the door's Area2D
@onready var timer = $Timer       # Timer node to control the delay

func _ready() -> void:
	# Disable the door collision when the scene first loads
	door_area.set_deferred("monitoring", false)
	# Start the timer to re-enable the door collision after a short delay
	timer.start()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		Global.changing_pokecenter = true


func _on_timer_timeout() -> void:
	# Re-enable the door collision after the player has moved away
	door_area.monitoring = true
