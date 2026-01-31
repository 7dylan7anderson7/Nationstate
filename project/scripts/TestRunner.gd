extends Control

@onready var output_label = $VBoxContainer/ScrollContainer/OutputLabel
@onready var run_button = $VBoxContainer/RunTestsButton
@onready var back_button = $BackButton

var gut_instance

func _ready():
	output_label.text = "Click 'Run Tests' to start testing...\n"

func _on_run_tests_pressed():
	output_label.text = "Running tests...\n\n"
	run_button.disabled = true
	
	# Create GUT instance
	gut_instance = load("res://addons/gut/gut.gd").new()
	add_child(gut_instance)
	
	# Add test directory
	gut_instance.add_directory("res://test/unit")
	
	# Set log level
	if "log_level" in gut_instance:
		gut_instance.log_level = 0
	
	# Connect to end signal
	if gut_instance.has_signal("end_run"):
		gut_instance.end_run.connect(_on_tests_complete)
	
	# Run tests
	gut_instance.test_scripts()

func _on_tests_complete():
	# Small delay to ensure GUT finishes
	await get_tree().create_timer(0.1).timeout
	
	output_label.text = "========= TEST RESULTS =========\n\n"
	
	if not is_instance_valid(gut_instance):
		output_label.text += "ERROR: GUT invalid\n"
		run_button.disabled = false
		return
	
	var failed_tests = []
	var passed_tests = []
	
	# Use _test_collector.scripts
	if "_test_collector" in gut_instance:
		var collector = gut_instance._test_collector
		if is_instance_valid(collector) and "scripts" in collector:
			var scripts = collector.scripts
			
			for script_obj in scripts:
				if not is_instance_valid(script_obj):
					continue
				
				# Get script name
				var script_name = "Unknown"
				if "name" in script_obj:
					script_name = script_obj.name
				elif "path" in script_obj:
					script_name = script_obj.path.get_file().replace(".gd", "")
				
				# Get tests
				if "tests" in script_obj:
					var tests = script_obj.tests
					if tests != null and typeof(tests) == TYPE_ARRAY:
						for test in tests:
							if not is_instance_valid(test):
								continue
							
							# Get test name
							var test_name = "unknown"
							if "name" in test:
								test_name = test.name
							
							var full_name = "%s::%s" % [script_name, test_name]
							
							# Check pass/fail using pass_texts and fail_texts arrays
							var has_failures = false
							var has_passes = false
							
							if "fail_texts" in test:
								var fail_texts = test.fail_texts
								if fail_texts != null and typeof(fail_texts) == TYPE_ARRAY:
									if fail_texts.size() > 0:
										has_failures = true
							
							if "pass_texts" in test:
								var pass_texts = test.pass_texts
								if pass_texts != null and typeof(pass_texts) == TYPE_ARRAY:
									if pass_texts.size() > 0:
										has_passes = true
							
							# A test passed if it has passes and no failures
							if has_failures:
								failed_tests.append(full_name)
							elif has_passes:
								passed_tests.append(full_name)
	
	# Display failed tests
	if failed_tests.size() > 0:
		output_label.text += "❌ FAILED TESTS (%d):\n" % failed_tests.size()
		for test in failed_tests:
			output_label.text += "  • %s\n" % test
		output_label.text += "\n"
	
	# Show summary - only our accurate count
	var total_tests = passed_tests.size() + failed_tests.size()
	output_label.text += "=== SUMMARY ===\n"
	output_label.text += "Tests Run: %d\n" % total_tests
	output_label.text += "Passed: %d ✓\n" % passed_tests.size()
	output_label.text += "Failed: %d ✗\n" % failed_tests.size()
	
	# Final message
	output_label.text += "\n"
	if failed_tests.size() > 0:
		output_label.text += "⚠ FIX THE %d FAILED TEST(S) ABOVE\n" % failed_tests.size()
		output_label.text += "\nAs you add features, run tests to ensure\n"
		output_label.text += "existing systems still work correctly!\n"
	else:
		output_label.text += "🎉 ALL TESTS PASSED!\n"
		output_label.text += "\nYour game systems are working as expected.\n"
	
	run_button.disabled = false

func _on_back_pressed():
	if gut_instance and is_instance_valid(gut_instance):
		gut_instance.queue_free()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
