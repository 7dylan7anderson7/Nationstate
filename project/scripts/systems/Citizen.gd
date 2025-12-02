class_name Citizen

var occupation : String
var wage : float #In thousands of dollars
var production : float #In thousands of dollars
var consumption : float #In thousands of dollars

func _init(_occupation, _wage, _production, _consumption):
	occupation = _occupation
	wage = _wage
	production = _production
	consumption = _consumption
