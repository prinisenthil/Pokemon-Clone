extends AnimatedSprite2D

@onready var dialogue_label = $UI/Textbox
var can_interact = false
signal textbox_closed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue_label.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Check if the player presses the "interact" key (you can customize the key in the Input Map)
	if can_interact and Input.is_action_just_pressed("interact"):
		start_conversation()

func start_conversation():
	dialogue_label.visible = true
	display_text("Hello! Welcome to the Pokécenter. One moment while I heal your Pokémon.")
	await self.textbox_closed



func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		$UI/Textbox.hide()
		emit_signal("textbox_closed")

func display_text(text):
	$UI/Textbox.show()
	$UI/Textbox/Dialogue.text = text


# When the player enters the interaction zone
func _on_interaction_zone_body_entered(body: Node2D) -> void:
	if body.name == "player":
		can_interact = true


func _on_interaction_zone_body_exited(body: Node2D) -> void:
	if body.name == "player":  # Check if it's the player who exited the zone
		can_interact = false
		dialogue_label.visible = false  # Hide the dialogue when the player leaves the zone
