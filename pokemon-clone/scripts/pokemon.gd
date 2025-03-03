extends CharacterBody2D

const max_level = 100
const base_health = 10

var poke_name = ""

@export var speed = 100
@export var max_health = 11
@export var health = 11
@export var accuracy = 100
@export var attack = 10
@export var defense = 10
@export var sp_attack = 10
@export var sp_defense = 10

var level = 1
var max_exp = 100
var exp = 0
var level_up = false

var health_bar
var exp_bar

var player_pokemon = false
var fainted = false


# Reference to the Pokémon's sprite
@onready var pokemon_sprite = $Sprite


func _physics_process(delta: float) -> void:
	if not fainted:
		set_max_health()
		battle_end()

func set_max_health():
	max_health = calc_hp()

func calc_hp():
	var IV = 15
	var EV = 0
	var HP = ((2 * base_health + IV + (EV / 4)) * level / 100) + level + 10
	return HP

func update_health():
	health_bar = $HealthBar
	health_bar.max_value = max_health
	health_bar.value = health
	if health <= 0:
		health = 0
	var tween = create_tween()
	tween.tween_property(health_bar, "value", health, 0.5).set_trans(Tween.TRANS_LINEAR)
	health_bar.get_node("Progress").text = "%d/%d" % [health, max_health]


func battle_end():
	if health == 0:
		fainted = true
