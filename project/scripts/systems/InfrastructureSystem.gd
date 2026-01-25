extends Node

#Infrastructure variable declarations
var infra_gdp_modifier: float = 1 #GDP modifier based on infrastructure
var urban_dict = {"urban": 90, "suburban": 10} #Dictionary of percentage of urban population in cities
var transport_access: float = 10 #Transportation access rating on a scale of 1-100
var citizen_transport_demand: float = 10 #Transportation demand for citizens in millions of trips per day
var goods_transport_demand: float = 10 #Transportation demand for goods in millions of trips per day

#Network variables
var road_funding: float = 1 #Road funding level on a scale of 0-4
var road_network: float = 5 #Road network rating in millions of trips it can handle per day
var road_usage: float = 50 #Road network usage as a percentage
var rail_funding: float = 1 #Rail funding level on a scale of 0-4
var rail_network: float = 10 #Rail network rating in millions of trips it can handle per day
var rail_usage: float = 95 #Rail network usage as a percentage

#Citizen transportation variables
var pt_funding: float = 2
var citizen_walking_trips: float = 0 #Trips citizens make by walking (millions per day)
var citizen_pt_trips: float = 0 #Trips citizens make via public transit (millions per day)
var citizen_road_trips: float = 0 #Trips citizens make via personal vehicles on roads (millions per day)
var citizen_rail_trips: float = 0 #Trips citizens make via rail (millions per day)
var forced_walking_trips: float = 0 #Trips where citizens are forced to walk due to lack of infrastructure

#Goods transportation variables
var prefer_balanced: bool = true #Transportation is decided based on availablility
var prefer_roads: bool = false #Roads are preferred for goods transportation
var prefer_rail: bool = false #Rail is preferred for goods transportation
var goods_road_trips: float = 0 #Goods trips via road (millions per day)
var goods_rail_trips: float = 0 #Goods trips via rail (millions per day)

#Urbanization target for gradual changes
var urbanization_target: float = 90

#Calculates citizen and goods transportation demand based on wealth and population
#Demand is stored in millions of trips per day
func calculate_transport_demand():
	#Citizen transport demand is equalivalent to 4 trips per day per citizen scaled based on GDP per capita
	citizen_transport_demand = 4 * (EconomySystem.population) * ((EconomySystem.percapita_GDP)/10)
	#Goods transport demand is equalivalent to 2 goods deliveries per day per citizen scaled based on GDP per capita
	goods_transport_demand = 2 * (EconomySystem.population) * ((EconomySystem.percapita_GDP)/10)

#Function calculates road network capacity
func calculate_road_network():
	if road_funding == 0:
		if road_network > 0:
			road_network = road_network - (0.15 * (road_network/5)) #Infrastructure loss over time scaled to infrastructure size
		else:
			road_network = 0
	elif road_funding == 1:
		if road_network > 0:
			road_network = road_network - (0.05 * (road_network/5)) #Slow infrastructure loss over time scaled to infrastructure size
		else:
			road_network = 0
	elif road_funding == 2:
		road_network = road_network + (0.05 * (EconomySystem.percapita_GDP / 10)) #Develops infrastructure over time scaled to wealth
	elif road_funding == 3:
		road_network = road_network + (0.1 * (EconomySystem.percapita_GDP / 10))
	else:
		road_network = road_network + (0.15 * (EconomySystem.percapita_GDP / 10))

#Function calculates rail network capacity
#Rail infrastructure is less expensive to build and maintain than road infrastructure leading to slower decay and faster development
func calculate_rail_network():
	if rail_funding == 0:
		if rail_network > 0:
			rail_network = rail_network - (0.1 * (rail_network/10)) #Infrastructure loss over time scaled to infrastructure size
		else:
			rail_network = 0
	elif rail_funding == 1:
		if rail_network > 0:
			rail_network = rail_network - (0.01 * (rail_network/10)) #Slow infrastructure loss over time scaled to infrastructure size
		else:
			rail_network = 0
	elif rail_funding == 2:
		rail_network = rail_network + (0.1 * (EconomySystem.percapita_GDP / 10)) #Develops infrastructure over time scaled to wealth
	elif rail_funding == 3:
		rail_network = rail_network + (0.2 * (EconomySystem.percapita_GDP / 10))
	else:
		rail_network = rail_network + (0.3 * (EconomySystem.percapita_GDP / 10))

#Function distributes citizen trips across different transport modes
func distribute_citizen_trips():
	var urban_population = EconomySystem.population * (urban_dict["urban"] / 100.0)
	var suburban_population = EconomySystem.population * (urban_dict["suburban"] / 100.0)
	
	var urban_trips = 4 * urban_population * ((EconomySystem.percapita_GDP)/10)
	var suburban_trips = 4 * suburban_population * ((EconomySystem.percapita_GDP)/10)
	
	# Urban trips distribution
	var urban_walking = urban_trips * 0.2  # 20% of urban trips are walking by choice
	var urban_remaining = urban_trips * 0.8
	
	# Calculate public transit capacity for urban areas
	var pt_effectiveness = get_pt_effectiveness()
	var urban_pt_capacity = urban_remaining * pt_effectiveness * 0.8  # Up to 80% can use PT if well funded
	var urban_pt_trips = min(urban_pt_capacity, urban_remaining)
	urban_remaining -= urban_pt_trips
	
	# Remaining urban trips need road infrastructure (cars) - if not available, forced to walk
	var urban_road_capacity_available = max(0, road_network - goods_road_trips)
	var urban_road_trips = min(urban_remaining, urban_road_capacity_available)
	var urban_forced_walking = urban_remaining - urban_road_trips
	
	# Suburban trips distribution
	var suburban_walking = suburban_trips * 0.1  # 10% want to walk but can't (unmet demand)
	var suburban_remaining = suburban_trips * 0.9
	
	# Public transit for suburban areas (up to 40% if well funded)
	var suburban_pt_capacity = suburban_remaining * pt_effectiveness * 0.4
	var suburban_pt_trips = min(suburban_pt_capacity, suburban_remaining)
	suburban_remaining -= suburban_pt_trips
	
	# Remaining suburban trips use roads
	var suburban_road_capacity_available = max(0, road_network - goods_road_trips - urban_road_trips)
	var suburban_road_trips = min(suburban_remaining, suburban_road_capacity_available)
	var suburban_forced_walking = suburban_remaining - suburban_road_trips
	
	# Aggregate totals
	citizen_walking_trips = urban_walking
	citizen_pt_trips = urban_pt_trips + suburban_pt_trips
	citizen_road_trips = urban_road_trips + suburban_road_trips
	forced_walking_trips = urban_forced_walking + suburban_forced_walking + suburban_walking
	citizen_rail_trips = 0  # Citizens use rail through PT, not directly

#Function distributes goods trips across road and rail networks
func distribute_goods_trips():
	var urban_population_pct = urban_dict["urban"] / 100.0
	var suburban_population_pct = urban_dict["suburban"] / 100.0
	
	var urban_goods = goods_transport_demand * urban_population_pct
	var suburban_goods = goods_transport_demand * suburban_population_pct
	
	# Natural preferences: urban areas prefer rail, suburban prefers road
	var natural_rail_demand = urban_goods
	var natural_road_demand = suburban_goods
	
	# Apply player preferences (75% shift if preferred)
	if prefer_rail:
		# Shift 75% of road demand to rail
		var shift_amount = natural_road_demand * 0.75
		natural_rail_demand += shift_amount
		natural_road_demand -= shift_amount
	elif prefer_roads:
		# Shift 75% of rail demand to road
		var shift_amount = natural_rail_demand * 0.75
		natural_road_demand += shift_amount
		natural_rail_demand -= shift_amount
	# If prefer_balanced, use natural distribution
	
	# Allocate based on available capacity
	var available_rail = max(0, rail_network - citizen_pt_trips)  # PT uses rail capacity
	var available_road = max(0, road_network - citizen_road_trips)
	
	# Try to meet rail demand first
	goods_rail_trips = min(natural_rail_demand, available_rail)
	var rail_overflow = natural_rail_demand - goods_rail_trips
	
	# Then meet road demand + any rail overflow
	goods_road_trips = min(natural_road_demand + rail_overflow, available_road)
	
	# Any unmet goods demand reduces economic efficiency (handled in GDP modifier later)

#Function calculates road and rail network usage percentages
func calculate_road_usage():
	var total_road_trips = citizen_road_trips + goods_road_trips
	if road_network > 0:
		road_usage = (total_road_trips / road_network) * 100
	else:
		road_usage = 0

func calculate_rail_usage():
	var total_rail_trips = citizen_pt_trips + goods_rail_trips
	if rail_network > 0:
		rail_usage = (total_rail_trips / rail_network) * 100
	else:
		rail_usage = 0

#Helper function to determine public transit effectiveness based on funding
func get_pt_effectiveness() -> float:
	match pt_funding:
		0:  # Minimal - no PT available
			return 0.0
		1:  # Low - only essential services
			return 0.3
		2:  # Moderate - meets current demand
			return 0.7
		3:  # High - above demand
			return 0.9
		4:  # Maximum - extensive coverage
			return 1.0
	return 0.7  # Default to moderate

#Function adjusts urbanization levels within cities
#Urbanization is dependent on road network, rail network, and public transportation
func modify_urbanization():
	# Calculate infrastructure ratio (rail+PT vs roads)
	var pt_effectiveness = get_pt_effectiveness()
	var rail_score = rail_network * (1 + pt_effectiveness)  # PT makes rail more attractive
	var road_score = road_network
	
	# Determine target urbanization based on infrastructure
	if rail_score > road_score:
		# Rail infrastructure encourages urbanization
		var rail_advantage = rail_score / (road_score + 0.1)  # Avoid division by zero
		urbanization_target = 90 + min(5, rail_advantage * 2)  # Max 95%
		urbanization_target = min(95, urbanization_target)
	else:
		# Road infrastructure encourages suburbanization
		var road_advantage = road_score / (rail_score + 0.1)
		urbanization_target = 90 - min(50, road_advantage * 10)  # Max suburbanization at 40% urban
		urbanization_target = max(40, urbanization_target)
	
	# Gradually shift urbanization toward target (0.25% per quarter = 4 quarters per 1%)
	var current_urban = urban_dict["urban"]
	if abs(urbanization_target - current_urban) > 0.1:
		if urbanization_target > current_urban:
			urban_dict["urban"] = current_urban + 0.25
		else:
			urban_dict["urban"] = current_urban - 0.25
		
		# Update suburban percentage
		urban_dict["suburban"] = 100 - urban_dict["urban"]

#Function calculates transportation access rating
#Transport access is the percentage of citizens who have access to their preferred method of transportation
func calculate_transport_access():
	var total_demand = citizen_transport_demand
	
	# Citizens prefer not to be forced to walk
	# Calculate successful trips (everything except forced walking)
	var successful_trips = citizen_walking_trips + citizen_pt_trips + citizen_road_trips
	
	# Calculate access rating as percentage of demand met properly
	if total_demand > 0:
		transport_access = (successful_trips / total_demand) * 100
	else:
		transport_access = 100
	
	# Cap at 100
	transport_access = min(100, transport_access)

#Function calculates infrastructure affect on GDP
#Will be implemented later - for now just set to 1 (no effect)
func calculate_gdp_modifier():
	# TODO: Implement GDP modifier based on transport access
	# If 60% of demand met, GDP should trend toward 60% of base value
	infra_gdp_modifier = 1

#Function called every quarter to run the infrastructure system simulation
func update_infrastructure():
	calculate_transport_demand()
	calculate_road_network()
	calculate_rail_network()
	distribute_goods_trips()  # Goods first, so we know remaining capacity for citizens
	distribute_citizen_trips()
	calculate_road_usage()
	calculate_rail_usage()
	modify_urbanization()
	calculate_transport_access()
	calculate_gdp_modifier()
