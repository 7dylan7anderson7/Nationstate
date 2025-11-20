extends Node

var year: int = 1
var quarter: int = 1

func next_quarter():
	quarter += 1
	if quarter > 4:
		quarter = 1
		year += 1
