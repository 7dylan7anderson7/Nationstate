extends GutTest

# Unit tests for EconomySystem
# Tests core economic calculations: GDP, population, literacy, inflation

var economy_system

# Setup function runs before each test
func before_each():
	# Load and instantiate EconomySystem properly
	var EconomySystemScript = load("res://scripts/systems/EconomySystem.gd")
	economy_system = EconomySystemScript.new()
	add_child(economy_system)
	
	# Reset to known initial state
	reset_economy_to_defaults()

# Helper function to reset economy to default starting values
func reset_economy_to_defaults():
	economy_system.domestic_GDP = 18.5
	economy_system.population = 2.0
	economy_system.unemployment = 5.0
	economy_system.literacy = 40.0
	economy_system.inflation = 0.02
	economy_system.trade = 0.2
	economy_system.tradeTo = 0.2
	economy_system.birthrate = 15.0
	economy_system.deathrate = 12.0
	economy_system.literacy_roc = 0.45

# ============================================================================
# POPULATION TESTS
# ============================================================================

func test_population_increases_with_positive_birth_rate():
	economy_system.population = 2.0
	economy_system.birthrate = 15.0  # 15 per 1000
	economy_system.deathrate = 10.0  # 10 per 1000
	
	economy_system.modify_population()
	
	# Net growth: (15-10)/1000 = 0.005 per person
	# Expected: 2.0 * (1 + 0.005) = 2.01
	assert_almost_eq(economy_system.population, 2.01, 0.001, 
		"Population should increase with positive net birth rate")

func test_population_decreases_with_negative_birth_rate():
	economy_system.population = 2.0
	economy_system.birthrate = 10.0
	economy_system.deathrate = 15.0  # More deaths than births
	
	economy_system.modify_population()
	
	# Net growth: (10-15)/1000 = -0.005 per person
	# Expected: 2.0 * (1 - 0.005) = 1.99
	assert_almost_eq(economy_system.population, 1.99, 0.001,
		"Population should decrease when death rate exceeds birth rate")

func test_population_stable_with_equal_rates():
	economy_system.population = 2.0
	economy_system.birthrate = 12.0
	economy_system.deathrate = 12.0
	
	economy_system.modify_population()
	
	assert_almost_eq(economy_system.population, 2.0, 0.001,
		"Population should remain stable when birth rate equals death rate")

# ============================================================================
# LITERACY TESTS
# ============================================================================

func test_literacy_increases_below_80_percent():
	economy_system.literacy = 40.0
	economy_system.literacy_roc = 0.45
	
	economy_system.modify_literacy()
	
	assert_almost_eq(economy_system.literacy, 40.45, 0.01,
		"Literacy should increase by literacy_roc when below 80%")

func test_literacy_has_diminishing_returns_above_80_percent():
	economy_system.literacy = 85.0
	economy_system.literacy_roc = 0.45
	
	economy_system.modify_literacy()
	
	# Above 80%, growth is literacy_roc / (literacy - 79)
	# Expected: 0.45 / (85 - 79) = 0.45 / 6 = 0.075
	var expected_increase = 0.45 / (85.0 - 79.0)
	assert_almost_eq(economy_system.literacy, 85.0 + expected_increase, 0.001,
		"Literacy should have diminishing returns above 80%")

func test_literacy_stops_at_99_percent():
	economy_system.literacy = 99.0
	economy_system.literacy_roc = 0.45
	
	economy_system.modify_literacy()
	
	assert_eq(economy_system.literacy, 99.0,
		"Literacy should not increase beyond 99%")

func test_literacy_approaching_80_transition():
	economy_system.literacy = 79.5
	economy_system.literacy_roc = 0.45
	
	economy_system.modify_literacy()
	
	# Should still use normal rate since literacy < 80
	assert_almost_eq(economy_system.literacy, 79.95, 0.01,
		"Literacy below 80 should use normal rate")

# ============================================================================
# GDP CALCULATION TESTS
# ============================================================================

func test_trade_gdp_calculation():
	economy_system.domestic_GDP = 18.5
	economy_system.trade = 0.2
	
	economy_system.calculate_GDP()
	
	# trade_GDP = domestic_GDP * trade = 18.5 * 0.2 = 3.7
	assert_almost_eq(economy_system.trade_GDP, 3.7, 0.01,
		"Trade GDP should be domestic GDP times trade multiplier")

func test_total_gdp_calculation():
	economy_system.domestic_GDP = 18.5
	economy_system.trade = 0.2
	
	economy_system.calculate_GDP()
	
	# total_GDP = domestic_GDP + trade_GDP = 18.5 + 3.7 = 22.2
	assert_almost_eq(economy_system.total_GDP, 22.2, 0.01,
		"Total GDP should be sum of domestic and trade GDP")

func test_per_capita_gdp_calculation():
	economy_system.total_GDP = 22.2
	economy_system.population = 2.0
	
	economy_system.calcualte_percapita_GDP()
	
	# per_capita = 22.2 / 2.0 = 11.1
	assert_almost_eq(economy_system.percapita_GDP, 11.1, 0.01,
		"Per capita GDP should be total GDP divided by population")

func test_gdp_with_zero_trade():
	economy_system.domestic_GDP = 20.0
	economy_system.trade = 0.0
	
	economy_system.calculate_GDP()
	
	assert_almost_eq(economy_system.trade_GDP, 0.0, 0.01,
		"Trade GDP should be zero when trade multiplier is zero")
	assert_almost_eq(economy_system.total_GDP, 20.0, 0.01,
		"Total GDP should equal domestic GDP when trade is zero")

# ============================================================================
# TRADE MODIFIER TESTS
# ============================================================================

func test_trade_increases_toward_target():
	economy_system.trade = 0.2
	economy_system.tradeTo = 0.4  # Target is higher
	
	economy_system.trade_to_trade()
	
	assert_almost_eq(economy_system.trade, 0.205, 0.001,
		"Trade should increase by 0.005 toward target")

func test_trade_decreases_toward_target():
	economy_system.trade = 0.4
	economy_system.tradeTo = 0.2  # Target is lower
	
	economy_system.trade_to_trade()
	
	assert_almost_eq(economy_system.trade, 0.395, 0.001,
		"Trade should decrease by 0.005 toward target")

func test_trade_stays_same_when_at_target():
	economy_system.trade = 0.3
	economy_system.tradeTo = 0.3
	
	economy_system.trade_to_trade()
	
	assert_almost_eq(economy_system.trade, 0.3, 0.001,
		"Trade should not change when already at target")

func test_trade_converges_over_multiple_quarters():
	economy_system.trade = 0.0
	economy_system.tradeTo = 0.1
	
	# Should take 20 quarters to go from 0.0 to 0.1 (0.005 per quarter)
	for i in range(20):
		economy_system.trade_to_trade()
	
	assert_almost_eq(economy_system.trade, 0.1, 0.001,
		"Trade should reach target after 20 quarters")

# ============================================================================
# INFLATION TESTS
# ============================================================================

func test_inflation_increases_domestic_gdp():
	economy_system.domestic_GDP = 20.0
	economy_system.inflation = 0.02  # 2% annual = 0.5% quarterly
	
	# Mock infrastructure modifier at neutral
	var InfrastructureSystemScript = load("res://scripts/systems/InfrastructureSystem.gd")
	var mock_infra = InfrastructureSystemScript.new()
	add_child(mock_infra)
	mock_infra.set_name("InfrastructureSystem")
	mock_infra.infra_gdp_modifier = 1.0
	
	economy_system.inflict_inflation()
	
	# Expected: 20.0 + (20.0 * 0.02/4 * 1.0) = 20.0 + 0.1 = 20.1
	assert_almost_eq(economy_system.domestic_GDP, 20.1, 0.01,
		"Domestic GDP should increase by quarterly inflation rate")
	
	mock_infra.queue_free()

func test_inflation_with_infrastructure_modifier():
	economy_system.domestic_GDP = 20.0
	economy_system.inflation = 0.02
	
	# Mock infrastructure modifier at 1.2 (20% boost)
	var InfrastructureSystemScript = load("res://scripts/systems/InfrastructureSystem.gd")
	var mock_infra = InfrastructureSystemScript.new()
	add_child(mock_infra)
	mock_infra.set_name("InfrastructureSystem")
	mock_infra.infra_gdp_modifier = 1.2
	
	economy_system.inflict_inflation()
	
	# Expected: 20.0 + (20.0 * 0.02/4 * 1.2) = 20.0 + 0.12 = 20.12
	assert_almost_eq(economy_system.domestic_GDP, 20.12, 0.01,
		"Infrastructure modifier should amplify GDP growth")
	
	mock_infra.queue_free()

func test_inflation_with_constrained_infrastructure():
	economy_system.domestic_GDP = 20.0
	economy_system.inflation = 0.02
	
	# Mock infrastructure modifier at 0.6 (40% constraint)
	var InfrastructureSystemScript = load("res://scripts/systems/InfrastructureSystem.gd")
	var mock_infra = InfrastructureSystemScript.new()
	add_child(mock_infra)
	mock_infra.set_name("InfrastructureSystem")
	mock_infra.infra_gdp_modifier = 0.6
	
	economy_system.inflict_inflation()
	
	# Expected: 20.0 + (20.0 * 0.02/4 * 0.6) = 20.0 + 0.06 = 20.06
	assert_almost_eq(economy_system.domestic_GDP, 20.06, 0.01,
		"Infrastructure constraint should reduce GDP growth")
	
	mock_infra.queue_free()

# ============================================================================
# INTEGRATION TESTS (Multiple functions together)
# ============================================================================

func test_full_quarter_update():
	# Test that update_economy calls all functions in correct order
	economy_system.domestic_GDP = 18.5
	economy_system.population = 2.0
	economy_system.literacy = 40.0
	economy_system.trade = 0.2
	economy_system.tradeTo = 0.2
	economy_system.birthrate = 15.0
	economy_system.deathrate = 12.0
	
	# Mock infrastructure
	var InfrastructureSystemScript = load("res://scripts/systems/InfrastructureSystem.gd")
	var mock_infra = InfrastructureSystemScript.new()
	add_child(mock_infra)
	mock_infra.set_name("InfrastructureSystem")
	mock_infra.infra_gdp_modifier = 1.0
	
	economy_system.update_economy()
	
	# Population should have changed
	assert_gt(economy_system.population, 2.0,
		"Population should increase after quarter update")
	
	# Literacy should have changed
	assert_gt(economy_system.literacy, 40.0,
		"Literacy should increase after quarter update")
	
	# GDP should have changed
	assert_gt(economy_system.domestic_GDP, 18.5,
		"Domestic GDP should increase after quarter update")
	
	mock_infra.queue_free()

func test_economic_growth_over_year():
	# Test 4 quarters of growth
	var initial_gdp = 18.5
	economy_system.domestic_GDP = initial_gdp
	economy_system.inflation = 0.02  # 2% annual
	
	# Mock infrastructure
	var InfrastructureSystemScript = load("res://scripts/systems/InfrastructureSystem.gd")
	var mock_infra = InfrastructureSystemScript.new()
	add_child(mock_infra)
	mock_infra.set_name("InfrastructureSystem")
	mock_infra.infra_gdp_modifier = 1.0
	
	# Run 4 quarters
	for i in range(4):
		economy_system.inflict_inflation()
	
	# Should be approximately 2% higher (compound growth)
	var expected_gdp = initial_gdp * 1.02
	assert_almost_eq(economy_system.domestic_GDP, expected_gdp, 0.1,
		"GDP should grow by approximately 2% over one year")
	
	mock_infra.queue_free()

# ============================================================================
# EDGE CASE TESTS
# ============================================================================

func test_zero_population_per_capita_gdp():
	economy_system.total_GDP = 20.0
	economy_system.population = 0.0
	
	# This will cause division by zero - should be handled gracefully
	# Currently it will create inf or crash - this is a bug to fix
	# For now, we document the expected behavior
	economy_system.calcualte_percapita_GDP()
	
	# Either should be inf or we should add protection
	# This test documents the current behavior
	assert_true(is_inf(economy_system.percapita_GDP) or is_nan(economy_system.percapita_GDP),
		"Zero population should result in inf or nan per capita GDP")

func test_negative_population_growth():
	economy_system.population = 1.0
	economy_system.birthrate = 5.0
	economy_system.deathrate = 20.0  # Very high death rate
	
	var initial_pop = economy_system.population
	economy_system.modify_population()
	
	assert_lt(economy_system.population, initial_pop,
		"Population should decrease with high death rate")

func test_very_high_literacy_rate_of_change():
	economy_system.literacy = 95.0
	economy_system.literacy_roc = 10.0  # Unrealistically high
	
	economy_system.modify_literacy()
	
	# Should still be capped at 99
	assert_lte(economy_system.literacy, 99.0,
		"Literacy should never exceed 99% regardless of rate")
