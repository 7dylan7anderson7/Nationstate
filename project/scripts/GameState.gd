extends Node

var year: int = 1
var quarter: int = 1

var trade_policy_index = 2
var trade_policy

func next_quarter():
	quarter += 1
	if quarter > 4:
		quarter = 1
		year += 1
