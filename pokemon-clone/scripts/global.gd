extends Node

var battling = false
var in_battle = false

var world = "world"

var pos_x = 518
var pos_y = 286

var player

var changing_pokecenter = false
var changing_battle = false

func change_scene(scene):
	if scene == "battle":
		get_tree().change_scene_to_file("res://scenes/battle.tscn")
	if scene == "pokecenter":
		get_tree().change_scene_to_file("res://scenes/pokecenter.tscn")
	if scene == "world":
		get_tree().change_scene_to_file("res://scenes/world.tscn")
