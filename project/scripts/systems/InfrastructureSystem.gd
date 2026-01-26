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
var road_usage: float = 67 #Road network usage as a percentage
var rail_funding: float = 1 #Rail funding level on a scale of 0-4
var rail_network: float = 10 #Rail network rating in millions of trips it can handle per day
var rail_usage: float = 80 #Rail network usage as a percentage

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
	
	# Check for road congestion and dynamically shift to PT if possible
	var initial_road_usage = 0.0
	if road_network > 0:
		initial_road_usage = ((urban_road_trips + suburban_road_trips + goods_road_trips) / road_network) * 100
	
	# If roads are congested (>80%) and rail has capacity, shift more citizens to PT
	if initial_road_usage > 80:
		var available_rail_for_pt = max(0, rail_network - citizen_pt_trips - goods_rail_trips)
		
		if available_rail_for_pt > 0 and pt_effectiveness > 0:
			# Calculate how many additional citizens could shift to PT
			var additional_pt_capacity = 0.0
			
			if initial_road_usage > 90:
				# Emergency - push PT usage higher
				# Urban can go up to 95%, suburban up to 60%
				var max_urban_pt = urban_remaining * 0.95
				var max_suburban_pt = suburban_remaining * 0.6
				additional_pt_capacity = (max_urban_pt - urban_pt_trips) + (max_suburban_pt - suburban_pt_trips)
			elif initial_road_usage > 80:
				# Moderate congestion - push PT usage moderately higher
				# Urban can go up to 90%, suburban up to 50%
				var max_urban_pt = urban_remaining * 0.9
				var max_suburban_pt = suburban_remaining * 0.5
				additional_pt_capacity = (max_urban_pt - urban_pt_trips) + (max_suburban_pt - suburban_pt_trips)
			
			# Shift what we can based on available rail capacity
			var pt_shift = min(additional_pt_capacity, available_rail_for_pt)
			pt_shift = min(pt_shift, urban_road_trips + suburban_road_trips)  # Can't shift more than currently on roads
			
			# Apply the shift proportionally between urban and suburban
			if urban_road_trips + suburban_road_trips > 0:
				var urban_shift_ratio = urban_road_trips / (urban_road_trips + suburban_road_trips)
				var urban_shift = pt_shift * urban_shift_ratio
				var suburban_shift = pt_shift * (1 - urban_shift_ratio)
				
				urban_pt_trips += urban_shift
				urban_road_trips -= urban_shift
				suburban_pt_trips += suburban_shift
				suburban_road_trips -= suburban_shift
	
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
	
	# Natural/baseline preferences when not congested
	# Urban areas heavily favor rail, suburban areas favor roads
	var natural_urban_rail = urban_goods * 0.9  # 90% of urban goods prefer rail
	var natural_urban_road = urban_goods * 0.1  # 10% of urban goods need roads
	var natural_suburban_rail = suburban_goods * 0.2  # 20% of suburban goods can use rail
	var natural_suburban_road = suburban_goods * 0.8  # 80% of suburban goods need roads
	
	var natural_rail_demand = natural_urban_rail + natural_suburban_rail
	var natural_road_demand = natural_urban_road + natural_suburban_road
	
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
	
	# Check if we need to do dynamic congestion avoidance
	# This happens AFTER initial allocation to see if roads are getting congested
	var initial_road_usage = 0.0
	if road_network > 0:
		initial_road_usage = ((citizen_road_trips + goods_road_trips) / road_network) * 100
	
	# If roads are congested (>80%) and we have rail capacity available, shift goods to rail
	if initial_road_usage > 80 and available_rail > goods_rail_trips:
		# Calculate how much we can shift
		var remaining_rail_capacity = available_rail - goods_rail_trips
		var road_trips_to_shift = 0.0
		
		# Determine shift aggressiveness based on congestion level and preferences
		if initial_road_usage > 90:
			# Emergency congestion - shift up to 98% of urban goods, 40% of suburban goods to rail
			var max_urban_shift = urban_goods * 0.98 - (goods_rail_trips * (urban_population_pct / (urban_population_pct + suburban_population_pct)))
			var max_suburban_shift = suburban_goods * 0.4 - (goods_rail_trips * (suburban_population_pct / (urban_population_pct + suburban_population_pct)))
			road_trips_to_shift = min(max_urban_shift + max_suburban_shift, remaining_rail_capacity)
			road_trips_to_shift = min(road_trips_to_shift, goods_road_trips * 0.9)  # Shift up to 90% of road goods
		elif initial_road_usage > 80:
			# Moderate congestion - shift up to 85% of shiftable goods
			if prefer_rail:
				road_trips_to_shift = min(goods_road_trips * 0.85, remaining_rail_capacity)
			else:
				road_trips_to_shift = min(goods_road_trips * 0.5, remaining_rail_capacity)  # Shift 50% in balanced mode
		
		# Apply the shift
		if road_trips_to_shift > 0:
			goods_road_trips -= road_trips_to_shift
			goods_rail_trips += road_trips_to_shift

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
	if pt_funding == 0:
		return 0.0
	elif pt_funding == 1:
		return 0.3
	elif pt_funding == 2:
		return 0.7
	elif pt_funding == 3:
		return 0.9
	else:
		return 1.0

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
func calculate_gdp_modifier():
	# New approach: Focus on TOTAL system capacity utilization, not just road congestion
	# A rail-heavy system with spare capacity should enable growth, not constrain it
	
	# Step 1: Calculate overall infrastructure capacity and utilization
	var total_capacity = road_network + rail_network
	var total_trips = citizen_road_trips + citizen_pt_trips + goods_road_trips + goods_rail_trips
	
	var overall_utilization = 0.5  # Default to 50% if no capacity
	if total_capacity > 0:
		overall_utilization = total_trips / total_capacity
	
	# Step 2: Calculate what % of demand is being met
	var total_transport_demand = citizen_transport_demand + goods_transport_demand
	
	# Calculate met demand
	var citizen_demand_met = citizen_walking_trips + citizen_pt_trips + citizen_road_trips
	var goods_demand_met = goods_road_trips + goods_rail_trips
	
	# Weight goods demand more heavily (3x impact vs citizens)
	# This is because goods MUST move - they can't walk
	var weighted_citizen_demand = citizen_transport_demand * 1.0
	var weighted_goods_demand = goods_transport_demand * 3.0
	var total_weighted_demand = weighted_citizen_demand + weighted_goods_demand
	
	var weighted_citizen_met = citizen_demand_met * 1.0
	var weighted_goods_met = goods_demand_met * 3.0
	var total_weighted_met = weighted_citizen_met + weighted_goods_met
	
	# Calculate base infrastructure availability (0.0 to 2.0 range)
	# 100% met = 1.0 (no effect), >100% = growth, <100% = decline
	var availability_pct = 1.0
	if total_weighted_demand > 0:
		availability_pct = total_weighted_met / total_weighted_demand
	
	# Step 3: Bonus for spare capacity (enables economic growth)
	var capacity_bonus = 0.0
	if overall_utilization < 0.9:  # If we have spare capacity
		# More spare capacity = more growth potential
		var spare_capacity_pct = 1.0 - overall_utilization
		capacity_bonus = spare_capacity_pct * 0.3  # Up to 30% bonus if totally empty
	
	# Step 4: Apply forced walking penalty
	# Forced walking reduces economic activity slightly
	var forced_walking_penalty = 0.0
	if citizen_transport_demand > 0:
		var forced_walking_pct = forced_walking_trips / citizen_transport_demand
		forced_walking_penalty = forced_walking_pct * 0.15  # Max 15% penalty if all citizens forced to walk
	
	# Step 5: Calculate road congestion penalty (much gentler now)
	var congestion_penalty = calculate_road_congestion_penalty()
	
	# Step 6: Calculate how much of the economy relies on roads vs rail
	var road_dependency = 0.5  # Default 50% if no trips
	if total_trips > 0:
		road_dependency = (citizen_road_trips + goods_road_trips) / total_trips
	
	# Apply congestion penalty proportional to road dependency
	var weighted_congestion_penalty = congestion_penalty * road_dependency
	
	# Step 7: Combine all factors into target modifier
	# Start with availability, add capacity bonus, subtract penalties
	var infra_gdp_modifier_target = availability_pct + capacity_bonus - forced_walking_penalty - weighted_congestion_penalty
	
	# Clamp to reasonable bounds (0.4 to 1.5)
	# 0.4 = infrastructure so bad economy shrinks to 40% over time
	# 1.5 = infrastructure so good economy can grow 50% faster
	infra_gdp_modifier_target = clamp(infra_gdp_modifier_target, 0.4, 1.5)
	
	# Step 8: Gradually move current modifier toward target (2 quarter lag)
	# To achieve 2-quarter lag, we move 50% of the distance each quarter
	# Quarter 1: 50% there, Quarter 2: 75% there (effectively at target)
	var change_rate = 0.5
	if infra_gdp_modifier_target > infra_gdp_modifier:
		infra_gdp_modifier += (infra_gdp_modifier_target - infra_gdp_modifier) * change_rate
	elif infra_gdp_modifier_target < infra_gdp_modifier:
		infra_gdp_modifier -= (infra_gdp_modifier - infra_gdp_modifier_target) * change_rate

#Helper function to calculate road congestion penalty
func calculate_road_congestion_penalty() -> float:
	# Roads suffer from congestion, rail does not
	# Returns a penalty value (0.0 to ~0.1) based on road usage
	# Much gentler penalties than before since system now avoids congestion dynamically
	
	var penalty = 0.0
	
	if road_usage <= 70:
		# No congestion penalty - roads flow freely
		penalty = 0.0
	elif road_usage <= 80:
		# Very slight congestion (70-80% usage)
		# Linear scaling: 0% at 70%, up to 2% at 80%
		var congestion_factor = (road_usage - 70) / 10.0  # 0.0 to 1.0
		penalty = congestion_factor * 0.02
	elif road_usage <= 90:
		# Light congestion (80-90% usage)
		# Linear scaling: 2% at 80%, up to 5% at 90%
		var congestion_factor = (road_usage - 80) / 10.0  # 0.0 to 1.0
		penalty = 0.02 + (congestion_factor * 0.03)
	elif road_usage <= 95:
		# Moderate congestion (90-95% usage)
		# Linear scaling: 5% at 90%, up to 8% at 95%
		var congestion_factor = (road_usage - 90) / 5.0  # 0.0 to 1.0
		penalty = 0.05 + (congestion_factor * 0.03)
	else:
		# Heavy congestion (95-100% usage)
		# Linear scaling: 8% at 95%, up to 10% at 100%
		var congestion_factor = (road_usage - 95) / 5.0  # 0.0 to 1.0
		penalty = 0.08 + (congestion_factor * 0.02)
	
	return penalty

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
