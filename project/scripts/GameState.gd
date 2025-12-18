extends Node

var year: int = 1
var quarter: int = 1

#Variables to hold trade policy options
var trade_policy_index = 2
var trade_policy

#Variables to hold education policy options
var primary_policy_index = 2
var secondary_policy_index = 2
var higher_policy_index = 2
var primary_policy
var secondary_policy
var higher_policy

func next_quarter():
	quarter += 1
	if quarter > 4:
		quarter = 1
		year += 1
