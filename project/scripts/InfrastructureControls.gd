extends Control

#Road funding node variables
@onready var road_slider: HSlider = $VBoxContainer/RoadPanel/VBoxContainer/RoadHSlider
@onready var road_description_label: Label = $VBoxContainer/RoadPanel/VBoxContainer/RoadDescriptionLabel
@onready var road_name_label: Label = $VBoxContainer/RoadPanel/VBoxContainer/HBoxContainer2/RoadNameLabel
@onready var road_network_label: Label = $VBoxContainer/RoadNetworkLabel

#Rail funding node variables
@onready var rail_slider: HSlider = $VBoxContainer/RailPanel/VBoxContainer2/RailHSlider
@onready var rail_description_label: Label = $VBoxContainer/RailPanel/VBoxContainer2/RailDescriptionLabel
@onready var rail_name_label: Label = $VBoxContainer/RailPanel/VBoxContainer2/HBoxContainer2/RailNameLabel
@onready var rail_network_label: Label = $VBoxContainer/RailNetworkLabel

#Goods transportation preferrence node variables
@onready var goods_slider: HSlider = $VBoxContainer/GoodsPanel/VBoxContainer2/GoodsHSlider
@onready var goods_description_label: Label = $VBoxContainer/GoodsPanel/VBoxContainer2/GoodsDescriptionLabel
@onready var goods_name_label: Label = $VBoxContainer/GoodsPanel/VBoxContainer2/HBoxContainer2/GoodsNameLabel

#Public transportation funding node variables
@onready var pt_slider: HSlider = $VBoxContainer/PublicTransportPanel/VBoxContainer2/PTHSlider
@onready var pt_description_label: Label = $VBoxContainer/PublicTransportPanel/VBoxContainer2/PTDescriptionLabel
@onready var pt_name_label: Label = $VBoxContainer/PublicTransportPanel/VBoxContainer2/HBoxContainer2/PTNameLabel

#Transport access and urbanization labels
@onready var transport_access_label: Label = $VBoxContainer/TransportAccessLabel
@onready var urbanization_label: Label = $VBoxContainer/UrbanizationLabel

#Dictionary for road funding policies
const RoadPolicies = [
	{
		"name": "Minimal",
		"description": "Minimal funding for expanding and maintaining road network.",
	},
	{
		"name": "Low",
		"description": "Low focus on building and maintaining road network.",
	},
	{
		"name": "Moderate",
		"description": "Moderate focus on building and maintaining road network.",
	},
	{
		"name": "High",
		"description": "High focus on building and maintaing road network",
	},
	{
		"name": "Maximum",
		"description": "Maximum funding for expanding and maintaining road network.",
	}
]

#Dictionary for rail funding policies
const RailPolicies = [
	{
		"name": "Minimal",
		"description": "Minimal funding for expanding and maintaining rail network.",
	},
	{
		"name": "Low",
		"description": "Low focus on building and maintaining rail network.",
	},
	{
		"name": "Moderate",
		"description": "Moderate focus on building and maintaining rail network.",
	},
	{
		"name": "High",
		"description": "High focus on building and maintaing rail network",
	},
	{
		"name": "Maximum",
		"description": "Maximum funding for expanding and maintaining rail network.",
	}
]

const GoodsPolicies = [
	{
		"name": "Prefer Roads",
		"description": "Prefer using road network for goods transportation.",
	},
	{
		"name": "Balanced",
		"description": "Balance between using roads and rail for transporting goods.",
	},
	{
		"name": "Prefer Rail",
		"description": "Prefer using rail network for goods transportation.",
	}
]

#Dictionary for public transportation funding policies
const PTPolicies = [
	{
		"name": "Minimal",
		"description": "Public transportation is not available.",
	},
	{
		"name": "Low",
		"description": "Funding is low and only provides essential services.",
	},
	{
		"name": "Moderate",
		"description": "Public transportation is funded to fill current demand.",
	},
	{
		"name": "High",
		"description": "Funding is slightly above demand improving system usability.",
	},
	{
		"name": "Maximum",
		"description": "Public transportation is funded to extent that infrastructure allows.",
	}
]

#Function for updating all dynamic labels
func update_all_labels():
	road_network_label.text = "Road Capacity: %sM Trips/Day (Usage: %s%%)" % [
		snapped(InfrastructureSystem.road_network, 0.1),
		snapped(InfrastructureSystem.road_usage, 0.1)
	]
	rail_network_label.text = "Rail Capacity: %sM Trips/Day (Usage: %s%%)" % [
		snapped(InfrastructureSystem.rail_network, 0.1),
		snapped(InfrastructureSystem.rail_usage, 0.1)
	]
	transport_access_label.text = "Transportation Access Rating: %s/100" % [
		snapped(InfrastructureSystem.transport_access, 0.1)
	]
	
	# Add urbanization label if it exists
	if urbanization_label:
		urbanization_label.text = "Urbanization: %s%% Urban / %s%% Suburban" % [
			snapped(InfrastructureSystem.urban_dict["urban"], 0.1),
			snapped(InfrastructureSystem.urban_dict["suburban"], 0.1)
		]

#Function for updating road funding policy
func update_road(value: int):
	var roadpolicy = RoadPolicies[value]
	road_description_label.text = roadpolicy["description"]
	road_name_label.text = roadpolicy["name"]
	GameState.road_policy_index = value
	GameState.road_policy = roadpolicy
	InfrastructureSystem.road_funding = value
	road_slider.value = value
	update_all_labels()

#Function for updating rail funding policy
func update_rail(value: int):
	var railpolicy = RailPolicies[value]
	rail_description_label.text = railpolicy["description"]
	rail_name_label.text = railpolicy["name"]
	GameState.rail_policy_index = value
	GameState.rail_policy = railpolicy
	InfrastructureSystem.rail_funding = value
	rail_slider.value = value
	update_all_labels()

#Function for updating goods transportation preferrence policy
func update_goods(value: int):
	var goodspolicy = GoodsPolicies[value]
	goods_description_label.text = goodspolicy["description"]
	goods_name_label.text = goodspolicy["name"]
	GameState.goods_policy_index = value
	GameState.goods_policy = goodspolicy
	#Set goods transportation variables in Infrastrucutre System
	if value == 0:
		InfrastructureSystem.prefer_roads = true
		InfrastructureSystem.prefer_balanced = false
		InfrastructureSystem.prefer_rail = false
	elif value == 1:
		InfrastructureSystem.prefer_roads = false
		InfrastructureSystem.prefer_balanced = true
		InfrastructureSystem.prefer_rail = false
	else:
		InfrastructureSystem.prefer_roads = false
		InfrastructureSystem.prefer_balanced = false
		InfrastructureSystem.prefer_rail = true
	goods_slider.value = value

func update_pt(value: int):
	var ptpolicy = PTPolicies[value]
	pt_description_label.text = ptpolicy["description"]
	pt_name_label.text = ptpolicy["name"]
	GameState.pt_policy_index = value
	GameState.pt_policy = ptpolicy
	InfrastructureSystem.pt_funding = value
	pt_slider.value = value
	update_all_labels()

func _on_road_h_slider_value_changed(value: float) -> void:
	update_road(value)

func _on_rail_h_slider_value_changed(value: float) -> void:
	update_rail(value)

func _on_goods_h_slider_value_changed(value: float) -> void:
	update_goods(value)

func _on_pth_slider_value_changed(value: float) -> void:
	update_pt(value)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_road(GameState.road_policy_index)
	update_rail(GameState.rail_policy_index)
	update_goods(GameState.goods_policy_index)
	update_pt(GameState.pt_policy_index)
	update_all_labels()

func _on_set_infrastructure_policy_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
