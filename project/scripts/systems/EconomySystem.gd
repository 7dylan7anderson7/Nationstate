extends Node

#Random number generator variable declaration
var RNG = RandomNumberGenerator.new()

#GDP variable declarations
var domestic_GDP: float = 18.5 #Domestic GDP in billions of dollars
var trade_GDP: float #GDP from trade determined using the trade modifier
var total_GDP: float #In billions of dollars
var percapita_GDP: float

#Variable declarations with values for game start
var population: float = 2 #In millions of people
var unemployment: float = 5 #In percentage points
var flux_unemployment = unemployment #Used to simulate slight fluxuations in unemployment from baseline every quarter
var literacy: float = 40 #In percentage points
var SOL: int = 30 #Standard of living rating on a scale of 1-100
var class_dict = {"working": 90, "middle": 0, "elite": 10} #Dictionary of percentage of population in each class

#Modifier variables set as defaults that are affected by political decisions
var inflation: float = .02 #Inflation percentage as a multiplier
var trade: float = .2 #Trade percentage of GDP as a multiplier
var literacy_roc: float = .45 #Increase in literacy rates per quarter
var birthrate: float = 15 #Births per 1000 population
var deathrate: float = 12 #Deaths per 1000 population

#To variables are set when a policy is modified and change a Modifier variable to that value over time
var tradeTo: float = trade

#To functions
func trade_to_trade():
	if tradeTo > trade:
		trade += .005
	elif tradeTo < trade:
		trade -= .005

#Update Economy functions
func modify_population():
	population = population + (population * (birthrate/1000))
	population = population - (population * (deathrate/1000))

func modify_literacy():
	if literacy < 80:
		literacy += literacy_roc
	elif literacy < 99:
		literacy += literacy_roc/(literacy-79) #Introduces diminishing returns on literacy after 80 percent
	else:
		pass

func calculate_employment():
	flux_unemployment = unemployment + ((RNG.randf_range(-20.0, 20.0))/100) #Randomizes a .2 percent standard deviation

func calculate_GDP():
	trade_to_trade()
	trade_GDP = (domestic_GDP * trade)
	total_GDP = domestic_GDP + trade_GDP

func calcualte_percapita_GDP():
	percapita_GDP = total_GDP / population #In Thousands of dollars per citizen

func inflict_inflation():
	# Apply base inflation growth
	var base_growth = domestic_GDP * (inflation/4)
	
	# Apply infrastructure modifier to the growth
	# infra_gdp_modifier of 1.0 = normal growth
	# infra_gdp_modifier of 0.6 = growth constrained (trending toward 60% of current)
	# infra_gdp_modifier of 1.2 = enhanced growth (infrastructure enabling expansion)
	var infrastructure_adjusted_growth = base_growth * InfrastructureSystem.infra_gdp_modifier
	
	domestic_GDP = domestic_GDP + infrastructure_adjusted_growth

#Function called every quarter to run the economic simulation
func update_economy():
	modify_population()
	modify_literacy()
	calculate_employment()
	calculate_GDP()
	calcualte_percapita_GDP()
	inflict_inflation()
