extends Control

#Hospital funding node variables
@onready var hospital_slider: HSlider = $VBoxContainer/HospitalPanel/VBoxContainer/HospitalHSlider
@onready var hospital_description_label: Label = $VBoxContainer/HospitalPanel/VBoxContainer/HospitalDescriptionLabel
@onready var hospital_name_label: Label = $VBoxContainer/HospitalPanel/VBoxContainer/HBoxContainer2/HospitalNameLabel

#Insurance privitization node variables
@onready var insurance_slider: HSlider = $VBoxContainer/InsurancePanel/VBoxContainer2/InsuranceHSlider
@onready var insurance_description_label: Label = $VBoxContainer/InsurancePanel/VBoxContainer2/InsuranceDescriptionLabel
@onready var insurance_name_label: Label = $VBoxContainer/InsurancePanel/VBoxContainer2/HBoxContainer2/InsuranceNameLabel

#Research privitization node variables
@onready var research_slider: HSlider = $VBoxContainer/ResearchPanel/VBoxContainer3/ResearchHSlider
@onready var research_description_label: Label = $VBoxContainer/ResearchPanel/VBoxContainer3/ResearchDescriptionLabel
@onready var research_name_label: Label = $VBoxContainer/ResearchPanel/VBoxContainer3/HBoxContainer2/ResearchNameLabel

#Other node variables
@onready var birthrate_label = $VBoxContainer/BirthrateLabel
@onready var deathrate_label = $VBoxContainer/DeathrateLabel

#Dictionary for hospital funding policies
const HospitalPolicies = [
	{
		"name": "Public",
		"description": "All medical centers are publicly owned.",
	},
	{
		"name": "Partial Privitization",
		"description": "Some medical centers are privately owned and some are publicly owned.",
	},
	{
		"name": "Private",
		"description": "All medical centers are privately owned.",
	}
]

#Dictionary for insurance privitization policies
const InsurancePolicies = [
	{
		"name": "Public",
		"description": "Only publicly funded health insurance is available.",
	},
	{
		"name": "Partial Privitization",
		"description": "Citizens can choose between public and private health insurance.",
	},
	{
		"name": "Private",
		"description": "Health insurance is only available on the private market.",
	}
]

#Dictionary for research privitization policies
const ResearchPolicies = [
	{
		"name": "Public",
		"description": "All medical research is funded and owned by the public sector.",
	},
	{
		"name": "Public/Private Partnership",
		"description": "Medical research is funded by both public and private sources.",
	},
	{
		"name": "Private",
		"description": "All medical research is funded and owned by the private sector.",
	}
]

#Function for updating hospital funding policy
func update_hospital(value: int):
	var hospitalpolicy = HospitalPolicies[value]
	hospital_description_label.text = hospitalpolicy["description"]
	hospital_name_label.text = hospitalpolicy["name"]
	GameState.hospital_policy_index = value
	GameState.hospital_policy = hospitalpolicy
	hospital_slider.value = value

#Function for updating insurance funding policy
func update_insurance(value: int):
	var insurancepolicy = InsurancePolicies[value]
	insurance_description_label.text = insurancepolicy["description"]
	insurance_name_label.text = insurancepolicy["name"]
	GameState.insurance_policy_index = value
	GameState.insurance_policy = insurancepolicy
	insurance_slider.value = value

#Function for updating research privitization policy
func update_research(value: int):
	var researchpolicy = ResearchPolicies[value]
	research_description_label.text = researchpolicy["description"]
	research_name_label.text = researchpolicy["name"]
	GameState.research_policy_index = value
	GameState.research_policy = researchpolicy
	research_slider.value = value

func _on_hospital_h_slider_value_changed(value: float) -> void:
	update_hospital(value)


func _on_insurance_h_slider_value_changed(value: float) -> void:
	update_insurance(value)


func _on_research_h_slider_value_changed(value: float) -> void:
	update_research(value)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_hospital(GameState.hospital_policy_index)
	update_insurance(GameState.insurance_policy_index)
	update_research(GameState.research_policy_index)

func _on_set_healthcare_policy_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
