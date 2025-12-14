extends Node

#Random number generator variable declaration
var RNG = RandomNumberGenerator.new()

#GDP variable declarations
var domestic_GDP: float = 1.5 #Domestic GDP in billions of dollars
var trade_GDP: float #GDP from trade determined using the trade modifier
var total_GDP: float #In billions of dollars

#Variable declarations with values for game start
var population: float = 2 #In millions of people
var unemployment: float = 5 #In percentage points
var flux_unemployment = unemployment #Used to simulate slight fluxuations in unemployment from baseline every quarter
var literacy: float = 40 #In percentage points
var SOL: int = 30 #Standard of living rating on a scale of 0-99
var class_dict = {"working": 90, "middle": 0, "elite": 10} #Dictionary of percentage of population in each class
var urban_dict = {"urban": 40, "suburban": 10, "rural": 50} #Dictionary of percentage of urban population

#Modifier variables set as defaults that are affected by political decisions
var inflation: float = .02 #Inflation percentage as a multiplier
var trade: float = .25 #Trade percentage of GDP as a multiplier
var literacy_roc: float = .1 #Increase in literacy rates per quarter
var birthrate: float = 15 #Births per 1000 population
var deathrate: float = 12 #Deaths per 1000 population

func modify_population():
	population = population + (population * (birthrate/1000))
	population = population - (population * (deathrate/1000))

func modify_literacy():
	literacy = literacy + literacy_roc

func calculate_employment():
	flux_unemployment = unemployment + ((RNG.randf_range(-20.0, 20.0))/100) #Randomizes a .2 percent standard deviation

func calculate_GDP():
	trade_GDP = (domestic_GDP * trade)
	total_GDP = domestic_GDP + trade_GDP

func inflict_inflation():
	domestic_GDP = domestic_GDP + (domestic_GDP * (inflation/4))

#Function called every quarter to run the economic simulation
func update_economy():
	modify_population()
	modify_literacy()
	calculate_employment()
	calculate_GDP()
	inflict_inflation()
