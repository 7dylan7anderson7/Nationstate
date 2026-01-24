extends Control

@onready var slider: HSlider = $VBoxContainer/Panel/VBoxContainer/TradePolicyHSlider
@onready var policy_description_label: Label = $VBoxContainer/Panel/VBoxContainer/PolicyDescriptionLabel
@onready var policy_name_label: Label = $VBoxContainer/Panel/VBoxContainer/HBoxContainer2/PolicyNameLabel

#Dictionary contains data for each policy
#Name and description are self explanitory
#Trade modifier holds the value that the trade modifier in EconomySystem will change to over time
const POLICIES = [
	{
		"name": "Isolationism",
		"description": "Severely restricts trade. Protects domestic industry but limits growth.",
		"trade_modifier": .05
	},
	{
		"name": "Protectionism",
		"description": "High tariffs and trade barriers.",
		"trade_modifier": .10
	},
	{
		"name": "Balanced Trade",
		"description": "Moderate trade with strategic protections.",
		"trade_modifier": .20
	},
	{
		"name": "Open Trade",
		"description": "Low tariffs and increased imports/exports.",
		"trade_modifier": .25
	},
	{
		"name": "Free Trade",
		"description": "Fully open markets. Maximizes growth but risks domestic industry.",
		"trade_modifier": .35
	}
]

func update_policy(value: int):
	var policy = POLICIES[value]
	policy_description_label.text = policy["description"]
	policy_name_label.text = policy["name"]
	GameState.trade_policy_index = value
	GameState.trade_policy = policy
	EconomySystem.tradeTo = policy["trade_modifier"] #Set value that trade modifier needs to be changed to
	slider.value = value

func _ready():
	update_policy(GameState.trade_policy_index)

func _on_trade_policy_h_slider_value_changed(value: float) -> void:
	update_policy(value)

func _on_set_trade_policy_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
