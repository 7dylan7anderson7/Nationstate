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

#Goods transportation variables
var prefer_balanced: bool = true #Transportation is decided based on availablility
var prefer_roads: bool = false #Roads are preferred for goods transportation
var prefer_rail: bool = false #Rail is preferred for goods transportation

#Calculates citizen and goods transportation demand based on wealth and population
#Demand is stored in millions of trips per day
func calculate_transport_demand():
	#Citizen transport demand is equalivalent to 4 trips per day per citizen scaled based on GDP per capita
	citizen_transport_demand = 4* (EconomySystem.population) * ((EconomySystem.percapita_GDP)/10)
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
	elif rail_funding == 2:
		road_network = road_network + (0.05 * (EconomySystem.percapita_GDP / 10)) #Develops infrastructure over time scaled to wealth
	elif road_funding == 3:
		road_network = road_network + (0.1 * (EconomySystem.percapita_GDP / 10))
	else:
		road_network = road_network + (0.15 * (EconomySystem.percapita_GDP / 10))

#Function calculates road trips and road network usage
func calculate_road_usage():
	pass

#Function calculates rail network capacity
#Rail infrastructure is lesss expensive to build and maintain than road infrastrucutre leading to slower decay and faster development
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

#Function calculates rail trips and rail network usage
func calculate_rail_usage():
	pass

#Function adjusts urbanization levels within cities
#Urbanization is dependent on road network, rail network, and public transportation
func modify_urbanization():
	pass

#Function calculates transportation access
#Takes into account goods and citizen transportation
func calculate_tranport_access():
	pass

#Function calculates infrastructure affect on GDP
func calculate_gdp_modifier():
	pass

#Function called every quarter to run the infrastructure system simulation
func update_infrastructure():
	calculate_transport_demand()
	calculate_road_network()
	calculate_road_usage()
	calculate_rail_network()
	calculate_rail_usage()
	modify_urbanization()
	calculate_tranport_access()
	calculate_gdp_modifier()
