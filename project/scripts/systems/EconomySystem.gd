extends Node

#Variable declarations with values for game start
var approval: int = 50 #In percentage points
var GDP: float = 2#In billions of dollars
var population: float = 2 #In millions of people
var unemployment: int = 25 #In percentage points
var literacy: int = 40 #In percentage points
var SOL: int = 30 #Standard of living rating on a scale of 0-99
var class_dict = {"working": 90, "middle": 0, "elite": 10} #Dictionary of percentage of population in each class

#Function called every quarter to run the economic simulation
func update_economy():
	pass
