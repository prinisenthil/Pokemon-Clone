extends Node2D

var trainer_pokemon
var trainer_pokemon_anim
var enemy_pokemon
var keep_playing = true
var end_battle = false
var trainer_move = true

var level_up = false

var player_buttons
var attack_btn
var flee_btn

signal textbox_closed
signal attack_over

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BattleTrainer/Pokeball.visible = false
	$BattleTrainer/PokeballOpening.visible = false
	$Textbox.hide()
	$TrainerPokemon.visible = false
	$TrainerPokemon/BattleBtnContainer.hide()
	$PlayerControl.hide()
	$EnemyPokemon/BattleBtnContainer.hide()
	trainer_pokemon = $TrainerPokemon
	get_stats(trainer_pokemon)
	enemy_pokemon = $EnemyPokemon
	set_max_health(trainer_pokemon, enemy_pokemon)

	$PlayerControl/Name.text = $TrainerPokemon.poke_name
	$EnemyControl/Name.text = $EnemyPokemon.poke_name

	$PlayerControl/ExpBar.value = trainer_pokemon.exp

	$PlayerControl/Level.text = "Lvl %d" % trainer_pokemon.level
	$EnemyControl/Level.text = "Lvl %d" % enemy_pokemon.level

	player_buttons = trainer_pokemon.get_node("BattleBtnContainer")
	attack_btn = trainer_pokemon.get_node("BattleBtnContainer/AttackBtn")
	flee_btn = trainer_pokemon.get_node("BattleBtnContainer/FleeBtn")

	attack_btn.pressed.connect(self._AttackBtn_pressed)
	flee_btn.pressed.connect(self._FleeBtn_pressed)

	display_text("A wild %s appears!" % enemy_pokemon.poke_name.to_upper())
	await self.textbox_closed
	trainer_play()
	display_text("What will %s do?" % trainer_pokemon.poke_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if not end_battle:
	battle()
	update_health(trainer_pokemon)
	update_health(enemy_pokemon)

func display_text(text):
	$Textbox.show()
	$Textbox/Label.text = text

func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		#$Textbox.hide()
		emit_signal("textbox_closed")

func battle():
	if not trainer_move:
		player_buttons.hide()
	else:
		player_buttons.show()

func trainer_play():
	$BattleTrainer/Trainer.play("TrainerThrow")
	$BattleTrainer/PokeballMove.play("ThrowPokeball")
	await get_tree().create_timer(1).timeout
	$BattleTrainer/PokeballOpening.visible = true
	$BattleTrainer/PokeballOpening.play("open")
	trainer_pokemon.visible = true
	$PlayerControl.show()
	player_buttons.show()


func _AttackBtn_pressed():
	trainer_move = false
	attack(trainer_pokemon, enemy_pokemon, "Tackle", 10)
	await self.attack_over

	attack(enemy_pokemon, trainer_pokemon, "Pound", 5)
	await self.attack_over
	display_text("What will %s do?" % trainer_pokemon.poke_name)
	trainer_move = true

func attack(pokemon, target_pokemon, move, power):
	display_text("%s used %s!" % [pokemon.poke_name.to_upper(), move])
	await self.textbox_closed

	if pokemon == trainer_pokemon:
		$AttackAnim.play("PlayerAttack")
	else:
		$AttackAnim.play("EnemyAttack")
	await get_tree().create_timer(0.3).timeout

	var dmg = calc_stat(pokemon, target_pokemon, power)
	target_pokemon.health = max(target_pokemon.health - dmg, 0)
	if target_pokemon.health <= 0:
		target_pokemon.health = 0

		await get_tree().create_timer(0.5).timeout
		target_pokemon.visible = false
		display_text("%s fainted!" % target_pokemon.poke_name)
		await self.textbox_closed

		if pokemon == trainer_pokemon:
			display_text("%s gained %d exp" % [pokemon.poke_name, 110])
			await update_exp(pokemon, 110)
			await self.textbox_closed


		set_stats(trainer_pokemon.max_health, trainer_pokemon.health, trainer_pokemon.max_exp, trainer_pokemon.exp, trainer_pokemon.level)

		Global.change_scene("world")
		Global.world = "world"
		

	display_text("%s dealt %d damage!" % [pokemon.poke_name.to_upper(), dmg])
	await self.textbox_closed

	emit_signal("attack_over")

func calc_hp(pokemon):
	var IV = 15
	var EV = 0
	var health = pokemon.base_health
	var level = pokemon.level
	var HP = ((2 * health + IV + (EV / 4)) * level / 100) + level + 10
	return HP

func set_max_health(mon1, mon2):
	mon1.max_health = calc_hp(mon1)
	mon2.max_health = calc_hp(mon2)

func calc_stat(pokemon, enemy, power):
	var dmg = (2*pokemon.level/5) + 2
	dmg *= power
	dmg *= (pokemon.attack/enemy.defense)
	dmg /= 50
	dmg += 2
	return round(dmg)

func _FleeBtn_pressed():
	trainer_move = false
	display_text("Got away safely!")
	await self.textbox_closed
	Global.change_scene("world")
	Global.world = "world"

func set_stats(max_health, health, max_exp, exp, level):
	GameData.set_max_health(max_health)
	GameData.set_health(health)
	GameData.set_max_exp(max_exp)
	GameData.set_exp(exp)
	GameData.set_level(level)

func get_stats(pokemon):
	pokemon.max_health = GameData.get_max_health()
	pokemon.health = GameData.get_health()
	pokemon.max_exp = GameData.get_max_exp()
	pokemon.exp = GameData.get_exp()
	pokemon.level = GameData.get_level()

func update_health(pokemon):
	var health_bar
	if pokemon == trainer_pokemon:
		health_bar = $PlayerControl/HealthBar
	else:
		health_bar = $EnemyControl/HealthBar
	if pokemon.health <= 0:
		pokemon.health = 0
	health_bar.max_value = pokemon.max_health
	var tween = create_tween()
	tween.tween_property(health_bar, "value", pokemon.health, 0.3).set_trans(Tween.TRANS_LINEAR)
	health_bar.get_node("Progress").text = "%d/%d" % [pokemon.health, pokemon.max_health]



func update_exp(pokemon, val):
	var exp_bar = $PlayerControl/ExpBar
	var exp = pokemon.exp + val
	var new_exp = min(exp, pokemon.max_exp)
	var tween = create_tween()
	tween.tween_property(exp_bar, "value", new_exp, 0.5).set_trans(Tween.TRANS_LINEAR)
	exp_bar.get_node("Progress").text = "%d/%d" % [min(pokemon.exp, pokemon.max_exp), pokemon.max_exp]
	await get_tree().create_timer(0.3).timeout
	if exp >= pokemon.max_exp:
		exp_bar.get_node("Progress").text = "%d/%d" % [pokemon.max_exp, pokemon.max_exp]
		pokemon.exp = exp - pokemon.max_exp
		pokemon.level += 1
		await get_tree().create_timer(0.3).timeout
		display_text("%s grew to level %d!" % [pokemon.poke_name, pokemon.level])
		$PlayerControl/Level.text = "Lvl %d" % pokemon.level
		set_max_health(trainer_pokemon, enemy_pokemon)
		await self.textbox_closed

		exp_bar.value = 0
		exp_bar.get_node("Progress").text = "%d/%d" % [0, pokemon.max_exp]
		if pokemon.exp > 0:
			update_exp(pokemon, 0)
