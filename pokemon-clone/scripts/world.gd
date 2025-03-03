extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = $player
	Global.player = player
	player.position.x = Global.pos_x
	player.position.y = Global.pos_y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	change_scene()

func change_scene():
	Global.pos_x = $player.position.x
	Global.pos_y = $player.position.y
	if Global.changing_pokecenter:
		Global.changing_pokecenter = false
		Global.change_scene("pokecenter")
		Global.world = "pokecenter"

	if Global.changing_battle:
		Global.changing_battle = false
		Global.change_scene("battle")
		Global.world = "battle"
