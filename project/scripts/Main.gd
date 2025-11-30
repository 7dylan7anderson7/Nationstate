extends Control


@onready var quarter_label = $VBoxContainer/Panel/HBoxContainer/VBoxContainer/QuarterLabel

func _ready():
	update_label()

func update_label():
	quarter_label.text = " Year %s, Q%s" % [GameState.year, GameState.quarter]


func _on_next_quarter_button_pressed() -> void:
	GameState.next_quarter()
	update_label()
