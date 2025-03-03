extends Node

var pokemon_max_health = 11
var pokemon_health = 11

var pokemon_max_exp = 100
var pokemon_exp = 0
var pokemon_level = 1

func set_health(num):
	pokemon_health = num

func set_max_health(num):
	pokemon_max_health = num

func get_health():
	return pokemon_health

func get_max_health():
	return pokemon_max_health

func set_exp(num):
	pokemon_exp = num

func set_max_exp(num):
	pokemon_max_exp = num

func get_exp():
	return pokemon_exp

func get_max_exp():
	return pokemon_max_exp

func set_level(num):
	pokemon_level = num

func get_level():
	return pokemon_level
