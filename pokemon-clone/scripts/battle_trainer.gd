extends Node2D

var trainer
var open
var anim_player
var keep_playing = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trainer = $Trainer
	open = $PokeballOpening
	anim_player = $PokeballMove


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#battle()
	pass

func battle():
	if Global.battling:
		Global.battling = false
		trainer.play("TrainerThrow")
		anim_player.play("ThrowPokeball")
		$BattleAnimation.start()


func _on_battle_animation_timeout() -> void:
	trainer.stop()
	$BallOpen.start()

func _on_ball_open_timeout() -> void:
	if keep_playing:
		keep_playing = false
		open.visible = true
		open.play()
		$CloseBall.start()

func _on_close_ball_timeout() -> void:
	open.stop()
	open.visible = false
