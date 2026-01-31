extends GutTest

# Unit tests for InfrastructureSystem
# Tests transport calculations, GDP modifiers, and infrastructure dynamics

var infrastructure_system
var mock_economy

# Setup function runs before each test
func before_each():
	# Load and instantiate EconomySystem properly
	var EconomySystemScript = load("res://scripts/systems/EconomySystem.gd")
	mock_economy = EconomySystemScript.new()
	add_child(mock_economy)
	mock_economy.set_name("EconomySystem")
	mock_economy.population = 2.0
	mock_economy.percapita_GDP = 9.25
	mock_economy.total_GDP = 18.5
	
	# Load and instantiate InfrastructureSystem properly
	var InfrastructureSystemScript = load("res://scripts/systems/InfrastructureSystem.gd")
	infrastructure_system = InfrastructureSystemScript.new()
	add_child(infrastructure_system)
	
	# Reset to known initial state
	reset_infrastructure_to_defaults()

# Helper function to reset infrastructure to defaults
func reset_infrastructure_to_defaults():
	infrastructure_system.road_network = 5.0
	infrastructure_system.rail_network = 10.0
	infrastructure_system.road_funding = 1
	infrastructure_system.rail_funding = 1
	infrastructure_system.pt_funding = 2
	infrastructure_system.urban_dict = {"urban": 90, "suburban": 10}
	infrastructure_system.prefer_balanced = true
	infrastructure_system.prefer_roads = false
	infrastructure_system.prefer_rail = false
	infrastructure_system.infra_gdp_modifier = 1.0

# ============================================================================
# TRANSPORT DEMAND TESTS
# ============================================================================

func test_citizen_transport_demand_calculation():
	mock_economy.population = 2.0
	mock_economy.percapita_GDP = 10.0
	
	infrastructure_system.calculate_transport_demand()
	
	# citizen_demand = 4 * population * (percapita_GDP / 10)
	# = 4 * 2.0 * (10.0 / 10) = 8.0
	assert_almost_eq(infrastructure_system.citizen_transport_demand, 8.0, 0.01,
		"Citizen transport demand should scale with population and GDP")

func test_goods_transport_demand_calculation():
	mock_economy.population = 2.0
	mock_economy.percapita_GDP = 10.0
	
	infrastructure_system.calculate_transport_demand()
	
	# goods_demand = 2 * population * (percapita_GDP / 10)
	# = 2 * 2.0 * (10.0 / 10) = 4.0
	assert_almost_eq(infrastructure_system.goods_transport_demand, 4.0, 0.01,
		"Goods transport demand should be half of citizen demand")

func test_demand_scales_with_wealth():
	mock_economy.population = 2.0
	mock_economy.percapita_GDP = 20.0  # Double wealth
	
	infrastructure_system.calculate_transport_demand()
	
	# citizen_demand = 4 * 2.0 * (20.0 / 10) = 16.0
	assert_almost_eq(infrastructure_system.citizen_transport_demand, 16.0, 0.01,
		"Transport demand should double when GDP per capita doubles")

func test_demand_scales_with_population():
	mock_economy.population = 4.0  # Double population
	mock_economy.percapita_GDP = 10.0
	
	infrastructure_system.calculate_transport_demand()
	
	# citizen_demand = 4 * 4.0 * (10.0 / 10) = 16.0
	assert_almost_eq(infrastructure_system.citizen_transport_demand, 16.0, 0.01,
		"Transport demand should double when population doubles")

# ============================================================================
# ROAD NETWORK CAPACITY TESTS
# ============================================================================

func test_road_network_decays_with_minimal_funding():
	infrastructure_system.road_network = 10.0
	infrastructure_system.road_funding = 0  # Minimal
	
	infrastructure_system.calculate_road_network()
	
	# Should decay by 0.15 * (road_network / 5) = 0.15 * 2 = 0.3
	assert_almost_eq(infrastructure_system.road_network, 9.7, 0.01,
		"Road network should decay with minimal funding")

func test_road_network_decays_slowly_with_low_funding():
	infrastructure_system.road_network = 10.0
	infrastructure_system.road_funding = 1  # Low
	
	infrastructure_system.calculate_road_network()
	
	# Should decay by 0.05 * (road_network / 5) = 0.05 * 2 = 0.1
	assert_almost_eq(infrastructure_system.road_network, 9.9, 0.01,
		"Road network should decay slowly with low funding")

func test_road_network_grows_with_moderate_funding():
	infrastructure_system.road_network = 5.0
	infrastructure_system.road_funding = 2  # Moderate
	mock_economy.percapita_GDP = 10.0
	
	infrastructure_system.calculate_road_network()
	
	# Should grow by 0.05 * (percapita_GDP / 10) = 0.05 * 1.0 = 0.05
	assert_almost_eq(infrastructure_system.road_network, 5.05, 0.01,
		"Road network should grow with moderate funding")

func test_road_network_grows_faster_with_high_funding():
	infrastructure_system.road_network = 5.0
	infrastructure_system.road_funding = 3  # High
	mock_economy.percapita_GDP = 10.0
	
	infrastructure_system.calculate_road_network()
	
	# Should grow by 0.1 * (percapita_GDP / 10) = 0.1 * 1.0 = 0.1
	assert_almost_eq(infrastructure_system.road_network, 5.1, 0.01,
		"Road network should grow faster with high funding")

func test_road_network_never_goes_negative():
	infrastructure_system.road_network = 0.1
	infrastructure_system.road_funding = 0  # Will cause decay
	
	infrastructure_system.calculate_road_network()
	
	assert_gte(infrastructure_system.road_network, 0.0,
		"Road network should never go negative")

# ============================================================================
# RAIL NETWORK CAPACITY TESTS
# ============================================================================

func test_rail_decays_slower_than_road():
	var initial_road = 10.0
	var initial_rail = 10.0
	
	infrastructure_system.road_network = initial_road
	infrastructure_system.rail_network = initial_rail
	infrastructure_system.road_funding = 0
	infrastructure_system.rail_funding = 0
	
	infrastructure_system.calculate_road_network()
	infrastructure_system.calculate_rail_network()
	
	var road_decay = initial_road - infrastructure_system.road_network
	var rail_decay = initial_rail - infrastructure_system.rail_network
	
	assert_lt(rail_decay, road_decay,
		"Rail should decay slower than roads with same funding")

func test_rail_grows_faster_than_road():
	var initial_road = 5.0
	var initial_rail = 5.0
	
	infrastructure_system.road_network = initial_road
	infrastructure_system.rail_network = initial_rail
	infrastructure_system.road_funding = 2  # Moderate
	infrastructure_system.rail_funding = 2  # Moderate
	mock_economy.percapita_GDP = 10.0
	
	infrastructure_system.calculate_road_network()
	infrastructure_system.calculate_rail_network()
	
	var road_growth = infrastructure_system.road_network - initial_road
	var rail_growth = infrastructure_system.rail_network - initial_rail
	
	assert_gt(rail_growth, road_growth,
		"Rail should grow faster than roads with same funding")

# ============================================================================
# PUBLIC TRANSIT EFFECTIVENESS TESTS
# ============================================================================

func test_pt_effectiveness_minimal():
	infrastructure_system.pt_funding = 0
	var effectiveness = infrastructure_system.get_pt_effectiveness()
	assert_eq(effectiveness, 0.0, "Minimal PT funding should give 0% effectiveness")

func test_pt_effectiveness_low():
	infrastructure_system.pt_funding = 1
	var effectiveness = infrastructure_system.get_pt_effectiveness()
	assert_eq(effectiveness, 0.3, "Low PT funding should give 30% effectiveness")

func test_pt_effectiveness_moderate():
	infrastructure_system.pt_funding = 2
	var effectiveness = infrastructure_system.get_pt_effectiveness()
	assert_eq(effectiveness, 0.7, "Moderate PT funding should give 70% effectiveness")

func test_pt_effectiveness_high():
	infrastructure_system.pt_funding = 3
	var effectiveness = infrastructure_system.get_pt_effectiveness()
	assert_eq(effectiveness, 0.9, "High PT funding should give 90% effectiveness")

func test_pt_effectiveness_maximum():
	infrastructure_system.pt_funding = 4
	var effectiveness = infrastructure_system.get_pt_effectiveness()
	assert_eq(effectiveness, 1.0, "Maximum PT funding should give 100% effectiveness")

# ============================================================================
# URBANIZATION TESTS
# ============================================================================

func test_urbanization_increases_with_rail_advantage():
	infrastructure_system.road_network = 5.0
	infrastructure_system.rail_network = 20.0  # Much more rail
	infrastructure_system.pt_funding = 3  # Good PT
	infrastructure_system.urban_dict["urban"] = 90.0
	
	infrastructure_system.modify_urbanization()
	
	assert_gt(infrastructure_system.urbanization_target, 90.0,
		"Urbanization target should increase with rail advantage")

func test_urbanization_decreases_with_road_advantage():
	infrastructure_system.road_network = 20.0  # Much more roads
	infrastructure_system.rail_network = 5.0
	infrastructure_system.pt_funding = 0  # No PT
	infrastructure_system.urban_dict["urban"] = 90.0
	
	infrastructure_system.modify_urbanization()
	
	assert_lt(infrastructure_system.urbanization_target, 90.0,
		"Urbanization target should decrease with road advantage")

func test_urbanization_changes_gradually():
	infrastructure_system.urban_dict["urban"] = 80.0
	infrastructure_system.urbanization_target = 90.0
	
	var initial_urban = infrastructure_system.urban_dict["urban"]
	infrastructure_system.modify_urbanization()
	
	var change = infrastructure_system.urban_dict["urban"] - initial_urban
	assert_almost_eq(change, 0.25, 0.01,
		"Urbanization should change by 0.25% per quarter")

func test_urbanization_capped_at_95_percent():
	infrastructure_system.rail_network = 100.0
	infrastructure_system.road_network = 1.0
	infrastructure_system.pt_funding = 4
	
	infrastructure_system.modify_urbanization()
	
	assert_lte(infrastructure_system.urbanization_target, 95.0,
		"Urbanization should be capped at 95%")

func test_urbanization_capped_at_40_percent():
	infrastructure_system.road_network = 100.0
	infrastructure_system.rail_network = 1.0
	infrastructure_system.pt_funding = 0
	
	infrastructure_system.modify_urbanization()
	
	assert_gte(infrastructure_system.urbanization_target, 40.0,
		"Urbanization should not fall below 40% (60% suburban max)")

# ============================================================================
# ROAD CONGESTION PENALTY TESTS
# ============================================================================

func test_no_congestion_penalty_below_70_percent():
	infrastructure_system.road_usage = 50.0
	var penalty = infrastructure_system.calculate_road_congestion_penalty()
	assert_eq(penalty, 0.0, "No congestion penalty below 70% usage")

func test_slight_congestion_penalty_70_to_80():
	infrastructure_system.road_usage = 75.0  # Midpoint
	var penalty = infrastructure_system.calculate_road_congestion_penalty()
	assert_almost_eq(penalty, 0.01, 0.005,
		"Slight penalty (around 1%) at 75% usage")

func test_moderate_congestion_penalty_80_to_90():
	infrastructure_system.road_usage = 85.0  # Midpoint
	var penalty = infrastructure_system.calculate_road_congestion_penalty()
	assert_almost_eq(penalty, 0.035, 0.005,
		"Moderate penalty (around 3.5%) at 85% usage")

func test_heavy_congestion_penalty_90_to_95():
	infrastructure_system.road_usage = 92.5  # Midpoint
	var penalty = infrastructure_system.calculate_road_congestion_penalty()
	assert_almost_eq(penalty, 0.065, 0.005,
		"Heavy penalty (around 6.5%) at 92.5% usage")

func test_max_congestion_penalty_at_100_percent():
	infrastructure_system.road_usage = 100.0
	var penalty = infrastructure_system.calculate_road_congestion_penalty()
	assert_almost_eq(penalty, 0.10, 0.01,
		"Maximum penalty (10%) at 100% usage")

# ============================================================================
# TRANSPORT ACCESS TESTS
# ============================================================================

func test_transport_access_100_when_all_demand_met():
	infrastructure_system.citizen_transport_demand = 10.0
	infrastructure_system.citizen_walking_trips = 2.0
	infrastructure_system.citizen_pt_trips = 4.0
	infrastructure_system.citizen_road_trips = 4.0
	infrastructure_system.forced_walking_trips = 0.0
	
	infrastructure_system.calculate_transport_access()
	
	assert_eq(infrastructure_system.transport_access, 100.0,
		"Transport access should be 100% when all demand is met")

func test_transport_access_lower_with_forced_walking():
	infrastructure_system.citizen_transport_demand = 10.0
	infrastructure_system.citizen_walking_trips = 2.0
	infrastructure_system.citizen_pt_trips = 3.0
	infrastructure_system.citizen_road_trips = 3.0
	infrastructure_system.forced_walking_trips = 2.0  # 2M trips unmet
	
	infrastructure_system.calculate_transport_access()
	
	# Successful trips: 2 + 3 + 3 = 8 out of 10 = 80%
	assert_almost_eq(infrastructure_system.transport_access, 80.0, 1.0,
		"Transport access should be 80% when 20% forced to walk")

# ============================================================================
# GDP MODIFIER INTEGRATION TESTS
# ============================================================================

func test_gdp_modifier_neutral_with_adequate_infrastructure():
	# Setup scenario where demand is met and no congestion
	mock_economy.population = 2.0
	mock_economy.percapita_GDP = 10.0
	infrastructure_system.road_network = 10.0
	infrastructure_system.rail_network = 10.0
	infrastructure_system.road_usage = 50.0  # No congestion
	infrastructure_system.citizen_transport_demand = 8.0
	infrastructure_system.goods_transport_demand = 4.0
	infrastructure_system.citizen_walking_trips = 1.6
	infrastructure_system.citizen_pt_trips = 3.2
	infrastructure_system.citizen_road_trips = 3.2
	infrastructure_system.goods_road_trips = 1.0
	infrastructure_system.goods_rail_trips = 3.0
	infrastructure_system.forced_walking_trips = 0.0
	
	infrastructure_system.calculate_gdp_modifier()
	
	# With adequate capacity and no issues, should trend toward ~1.0
	assert_almost_eq(infrastructure_system.infra_gdp_modifier, 1.0, 0.2,
		"GDP modifier should be near neutral with adequate infrastructure")

func test_gdp_modifier_bonus_with_spare_capacity():
	# Setup scenario with lots of spare capacity
	infrastructure_system.road_network = 20.0
	infrastructure_system.rail_network = 20.0  # Total 40M capacity
	infrastructure_system.citizen_road_trips = 2.0
	infrastructure_system.citizen_pt_trips = 4.0
	infrastructure_system.goods_road_trips = 1.0
	infrastructure_system.goods_rail_trips = 3.0
	# Total trips: 10M out of 40M = 25% utilization = 75% spare
	infrastructure_system.road_usage = 15.0
	infrastructure_system.citizen_transport_demand = 8.0
	infrastructure_system.goods_transport_demand = 4.0
	infrastructure_system.forced_walking_trips = 0.0
	
	# Need to distribute first to get accurate calculations
	infrastructure_system.citizen_walking_trips = 1.6
	infrastructure_system.citizen_pt_trips = 4.0
	infrastructure_system.citizen_road_trips = 2.0
	infrastructure_system.goods_rail_trips = 3.0
	infrastructure_system.goods_road_trips = 1.0
	
	infrastructure_system.calculate_gdp_modifier()
	
	# Should get capacity bonus
	assert_gt(infrastructure_system.infra_gdp_modifier, 1.0,
		"GDP modifier should be above 1.0 with significant spare capacity")

func test_gdp_modifier_penalty_with_unmet_demand():
	# Setup scenario where demand is not met
	infrastructure_system.citizen_transport_demand = 10.0
	infrastructure_system.goods_transport_demand = 5.0
	infrastructure_system.citizen_walking_trips = 2.0
	infrastructure_system.citizen_pt_trips = 3.0
	infrastructure_system.citizen_road_trips = 3.0
	infrastructure_system.forced_walking_trips = 2.0  # 2M unmet
	infrastructure_system.goods_road_trips = 2.0
	infrastructure_system.goods_rail_trips = 2.0  # 1M goods unmet
	infrastructure_system.road_usage = 60.0
	infrastructure_system.road_network = 10.0
	infrastructure_system.rail_network = 10.0
	
	infrastructure_system.calculate_gdp_modifier()
	
	# Should penalize for unmet demand (especially goods which are weighted 3x)
	assert_lt(infrastructure_system.infra_gdp_modifier, 1.0,
		"GDP modifier should be below 1.0 with significant unmet demand")

# ============================================================================
# REGRESSION TESTS (Prevent known issues)
# ============================================================================

func test_y14_q1_scenario_rail_heavy_economy():
	# Regression test for the Y14 Q1 issue that was fixed
	# Rail-heavy economy with spare capacity should enable growth, not constrain it
	
	infrastructure_system.road_network = 2.3
	infrastructure_system.rail_network = 18.5
	infrastructure_system.road_usage = 93.1
	infrastructure_system.rail_usage = 69.0
	
	# Approximate trip distribution
	var total_capacity = 2.3 + 18.5  # 20.8M
	var total_trips = (2.3 * 0.931) + (18.5 * 0.69)  # ~14.9M
	var overall_utilization = total_trips / total_capacity  # ~72%
	
	infrastructure_system.citizen_road_trips = 0.5
	infrastructure_system.citizen_pt_trips = 10.0
	infrastructure_system.goods_road_trips = 1.6
	infrastructure_system.goods_rail_trips = 2.8
	infrastructure_system.forced_walking_trips = 0.0
	infrastructure_system.citizen_transport_demand = 12.0
	infrastructure_system.goods_transport_demand = 5.0
	
	infrastructure_system.calculate_gdp_modifier()
	
	# Should enable growth, not constrain
	assert_gt(infrastructure_system.infra_gdp_modifier, 1.0,
		"Y14 Q1 scenario: Rail-heavy economy with 72% utilization should enable growth")

# ============================================================================
# EDGE CASE TESTS
# ============================================================================

func test_zero_capacity_networks():
	infrastructure_system.road_network = 0.0
	infrastructure_system.rail_network = 0.0
	
	infrastructure_system.calculate_road_usage()
	infrastructure_system.calculate_rail_usage()
	
	assert_eq(infrastructure_system.road_usage, 0.0,
		"Road usage should be 0 with zero capacity")
	assert_eq(infrastructure_system.rail_usage, 0.0,
		"Rail usage should be 0 with zero capacity")

func test_zero_demand():
	mock_economy.population = 0.0
	
	infrastructure_system.calculate_transport_demand()
	
	assert_eq(infrastructure_system.citizen_transport_demand, 0.0,
		"Zero population should create zero demand")
	assert_eq(infrastructure_system.goods_transport_demand, 0.0,
		"Zero population should create zero goods demand")
