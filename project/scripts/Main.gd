extends Control

#Set labels as variables to be updated every quarter
@onready var quarter_label = $VBoxContainer/Panel/HBoxContainer/VBoxContainer/QuarterLabel
@onready var gdp_label = $VBoxContainer/Panel/HBoxContainer/VBoxContainer2/GDPLabel
@onready var population_label = $VBoxContainer/Panel/HBoxContainer/VBoxContainer/PopulationLabel
@onready var unemployment_label = $VBoxContainer/Panel/HBoxContainer/VBoxContainer2/UnemploymentLabel

#Function executes on game startup
func _ready():
	update_labels()

#Updates all main menu labels with current data
func update_labels():
	quarter_label.text = " Year %s, Q%s" % [GameState.year, GameState.quarter]
	gdp_label.text = "GDP: $%sB" % [snapped(EconomySystem.total_GDP, 0.001)] #Snapped limits GDP output to 3 decimals
	population_label.text = "Population: %sM" % [snapped(EconomySystem.population, 0.01)]
	unemployment_label.text = "Unemployment: %s%%" % [snapped(EconomySystem.flux_unemployment, 0.1)]

func _on_next_quarter_button_pressed() -> void:
	GameState.next_quarter()
	EconomySystem.update_economy()
	InfrastructureSystem.update_infrastructure()
	update_labels()
	print_infrastructure_debug()

#Functionality for Trade button
func _on_trade_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/TradeControls.tscn")

#Functionality for Education button
func _on_education_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/EducationControls.tscn")


func _on_healthcare_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/HealthcareControls.tscn")

func _on_infrastructure_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/InfrastructureControls.tscn")

# Infrastructure Debug Tool
# Add this to your scene temporarily to print detailed infrastructure stats
# Useful for testing and balancing the system
func print_infrastructure_debug():
	print("\n========== INFRASTRUCTURE DEBUG ==========")
	print("Quarter: Year %s, Q%s" % [GameState.year, GameState.quarter])
	
	print("\n--- POPULATION & ECONOMY ---")
	print("Population: %sM" % snapped(EconomySystem.population, 0.01))
	print("GDP per capita: $%sK" % snapped(EconomySystem.percapita_GDP, 0.01))
	print("Urbanization: %s%% urban / %s%% suburban" % [
		snapped(InfrastructureSystem.urban_dict["urban"], 0.1),
		snapped(InfrastructureSystem.urban_dict["suburban"], 0.1)
	])
	
	print("\n--- TRANSPORTATION DEMAND ---")
	print("Citizen demand: %sM trips/day" % snapped(InfrastructureSystem.citizen_transport_demand, 0.1))
	print("Goods demand: %sM trips/day" % snapped(InfrastructureSystem.goods_transport_demand, 0.1))
	print("Total demand: %sM trips/day" % snapped(
		InfrastructureSystem.citizen_transport_demand + InfrastructureSystem.goods_transport_demand, 0.1
	))
	
	print("\n--- NETWORK CAPACITY ---")
	print("Road network: %sM trips/day (%s%% usage)" % [
		snapped(InfrastructureSystem.road_network, 0.1),
		snapped(InfrastructureSystem.road_usage, 0.1)
	])
	print("Rail network: %sM trips/day (%s%% usage)" % [
		snapped(InfrastructureSystem.rail_network, 0.1),
		snapped(InfrastructureSystem.rail_usage, 0.1)
	])
	print("Total capacity: %sM trips/day" % snapped(
		InfrastructureSystem.road_network + InfrastructureSystem.rail_network, 0.1
	))
	
	print("\n--- CITIZEN TRIPS BREAKDOWN ---")
	print("Walking (choice): %sM trips/day" % snapped(InfrastructureSystem.citizen_walking_trips, 0.1))
	print("Public transit: %sM trips/day" % snapped(InfrastructureSystem.citizen_pt_trips, 0.1))
	print("Personal vehicles: %sM trips/day" % snapped(InfrastructureSystem.citizen_road_trips, 0.1))
	print("Forced walking: %sM trips/day" % snapped(InfrastructureSystem.forced_walking_trips, 0.1))
	
	var total_citizen_trips = (InfrastructureSystem.citizen_walking_trips + 
		InfrastructureSystem.citizen_pt_trips + 
		InfrastructureSystem.citizen_road_trips +
		InfrastructureSystem.forced_walking_trips)
	print("Total citizen trips: %sM (should match demand)" % snapped(total_citizen_trips, 0.1))
	
	print("\n--- GOODS TRIPS BREAKDOWN ---")
	print("Road transport: %sM trips/day" % snapped(InfrastructureSystem.goods_road_trips, 0.1))
	print("Rail transport: %sM trips/day" % snapped(InfrastructureSystem.goods_rail_trips, 0.1))
	
	var total_goods = InfrastructureSystem.goods_road_trips + InfrastructureSystem.goods_rail_trips
	var goods_unmet = InfrastructureSystem.goods_transport_demand - total_goods
	print("Total goods trips: %sM" % snapped(total_goods, 0.1))
	if goods_unmet > 0.1:
		print("WARNING: Unmet goods demand: %sM trips/day" % snapped(goods_unmet, 0.1))
	
	print("\n--- POLICY SETTINGS ---")
	print("Road funding: Level %s" % InfrastructureSystem.road_funding)
	print("Rail funding: Level %s" % InfrastructureSystem.rail_funding)
	print("PT funding: Level %s (effectiveness: %s%%)" % [
		InfrastructureSystem.pt_funding,
		InfrastructureSystem.get_pt_effectiveness() * 100
	])
	
	if InfrastructureSystem.prefer_rail:
		print("Goods preference: PREFER RAIL")
	elif InfrastructureSystem.prefer_roads:
		print("Goods preference: PREFER ROADS")
	else:
		print("Goods preference: BALANCED")
	
	print("\n--- PERFORMANCE METRICS ---")
	print("Transport access rating: %s/100" % snapped(InfrastructureSystem.transport_access, 0.1))
	print("Urbanization target: %s%%" % snapped(InfrastructureSystem.urbanization_target, 0.1))
	
	var capacity_utilization = ((InfrastructureSystem.road_usage * InfrastructureSystem.road_network + 
		InfrastructureSystem.rail_usage * InfrastructureSystem.rail_network) / 
		(InfrastructureSystem.road_network + InfrastructureSystem.rail_network))
	print("Overall capacity utilization: %s%%" % snapped(capacity_utilization, 0.1))
	
	print("\n--- GDP MODIFIER SYSTEM ---")
	print("Current GDP modifier: %s" % snapped(InfrastructureSystem.infra_gdp_modifier, 0.001))
	#print("Target GDP modifier: %s" % snapped(InfrastructureSystem.infra_gdp_modifier_target, 0.001))
	
	# Calculate overall capacity utilization
	var total_capacity = InfrastructureSystem.road_network + InfrastructureSystem.rail_network
	var total_trips = InfrastructureSystem.citizen_road_trips + InfrastructureSystem.citizen_pt_trips + InfrastructureSystem.goods_road_trips + InfrastructureSystem.goods_rail_trips
	var overall_utilization = 0.5
	if total_capacity > 0:
		overall_utilization = total_trips / total_capacity
	print("Overall system utilization: %s%%" % snapped(overall_utilization * 100, 0.1))
	print("Spare capacity: %s%%" % snapped((1.0 - overall_utilization) * 100, 0.1))
	
	# Calculate capacity bonus
	var capacity_bonus = 0.0
	if overall_utilization < 0.9:
		var spare_capacity_pct = 1.0 - overall_utilization
		capacity_bonus = spare_capacity_pct * 0.3
	print("Capacity growth bonus: +%s%%" % snapped(capacity_bonus * 100, 0.1))
	
	var road_dependency = 0.5
	if total_trips > 0:
		road_dependency = (InfrastructureSystem.citizen_road_trips + InfrastructureSystem.goods_road_trips) / total_trips
	print("Road dependency: %s%%" % snapped(road_dependency * 100, 0.1))
	
	var congestion_penalty = InfrastructureSystem.calculate_road_congestion_penalty()
	print("Road congestion penalty: %s%%" % snapped(congestion_penalty * 100, 0.1))
	print("Weighted congestion impact: -%s%%" % snapped(congestion_penalty * road_dependency * 100, 0.1))
	
	if InfrastructureSystem.infra_gdp_modifier < 1.0:
		print("→ Infrastructure CONSTRAINING economy by %s%%" % snapped((1.0 - InfrastructureSystem.infra_gdp_modifier) * 100, 0.1))
	elif InfrastructureSystem.infra_gdp_modifier > 1.0:
		print("→ Infrastructure ENABLING %s%% faster growth" % snapped((InfrastructureSystem.infra_gdp_modifier - 1.0) * 100, 0.1))
	else:
		print("→ Infrastructure has neutral effect on economy")
	
	print("\n--- WARNINGS ---")
	if InfrastructureSystem.road_usage > 90:
		print("⚠ Road network near capacity!")
	if InfrastructureSystem.rail_usage > 90:
		print("⚠ Rail network near capacity!")
	if InfrastructureSystem.transport_access < 80:
		print("⚠ Poor transport access - citizens being forced to walk!")
	if InfrastructureSystem.forced_walking_trips > 0.5:
		print("⚠ Significant forced walking: %sM trips/day (reduces GDP)" % 
			snapped(InfrastructureSystem.forced_walking_trips, 0.1))
	if InfrastructureSystem.road_usage > 80:
		print("⚠ Road congestion detected - system dynamically shifting traffic to rail/PT")
	if InfrastructureSystem.road_usage > 85:
		print("⚠ Heavy road congestion - traffic reducing economic efficiency!")
	if InfrastructureSystem.infra_gdp_modifier < 0.9:
		print("⚠ Infrastructure seriously constraining economic growth!")
	
	# Calculate overall utilization warning
	total_capacity = InfrastructureSystem.road_network + InfrastructureSystem.rail_network
	total_trips = InfrastructureSystem.citizen_road_trips + InfrastructureSystem.citizen_pt_trips + InfrastructureSystem.goods_road_trips + InfrastructureSystem.goods_rail_trips
	var overall_util = 0.5
	if total_capacity > 0:
		overall_util = total_trips / total_capacity
	if overall_util > 0.95:
		print("⚠ CRITICAL: Overall infrastructure at 95%+ capacity - build more!")
	
	# Calculate unmet goods demand
	goods_unmet = InfrastructureSystem.goods_transport_demand - (InfrastructureSystem.goods_road_trips + InfrastructureSystem.goods_rail_trips)
	if goods_unmet > 0.1:
		print("⚠ CRITICAL: Unmet goods demand: %sM trips/day (major GDP impact!)" % snapped(goods_unmet, 0.1))
	
	print("\n==========================================\n")
