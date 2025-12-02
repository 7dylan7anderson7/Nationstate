extends Node

#Variable declarations with values for game start
var GDP: float #In billions of dollars
var population: float = 2 #In millions of people
var workers: float = 1.34 #In millions of working age people
var unemployment: float #In percentage points

#Array of (Starting with 10) population objects
var citizens: Array[Citizen] = []
var CitizenCount: float = 10

#Function generates the original set of citizens
#TEMPORARY: Function creates 10 citizen objects for testing
func generate_citizens():
	citizens.append(Citizen.new("Unemployed", 0, 0, 5))
	citizens.append(Citizen.new("Unemployed", 0, 0, 5))
	citizens.append(Citizen.new("Unemployed", 0, 0, 5))
	citizens.append(Citizen.new("Farmer", 10, 15, 10))
	citizens.append(Citizen.new("Farmer", 10, 15, 10))
	citizens.append(Citizen.new("Farmer", 12, 18, 12))
	citizens.append(Citizen.new("Farmer", 12, 18, 12))
	citizens.append(Citizen.new("Worker", 15, 25, 15))
	citizens.append(Citizen.new("Worker", 20, 30, 20))
	citizens.append(Citizen.new("Professional", 25, 45, 25))

#Function calculates GDP based on the sample set of population
func calculate_gdp():
	var prodTotal: float = 0
	for c in citizens:
		prodTotal += c.production
	#Take the average production per citizen in the set and multiply by the total population for total GDP
	GDP = (prodTotal/CitizenCount)*population

#Function calculates unemployment
func update_unemployment():
	var UnemployedCount: int = 0
	for c in citizens:
		if c.occupation == "Unemployed":
			UnemployedCount += 1
	unemployment = ((UnemployedCount / CitizenCount) * 100)

#Function called every quarter to run the economic simulation
func update_economy():
	calculate_gdp()
	update_unemployment()
