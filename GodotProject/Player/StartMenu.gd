extends Control


@onready var resume_button: Button = %ResumeGameButton
@onready var weapons_button: Button = %WeaponsAndGadgetsButton
@onready var options_button: Button = %OptionsButton
@onready var extras_button: Button = %ExtrasButton
@onready var exit_button: Button = %ExitToMainMenuButton

var is_paused = false

func _ready():
	hide()  # Hide the pause menu when the game starts
	#process_mode = Node.PROCESS_MODE_ALWAYS  # Ensure this node always processes

func _process(delta):
	if Input.is_action_just_pressed("start"):
		if is_paused:
			unpause()
		else:
			pause()

func pause():
	is_paused = true
	show()
	get_tree().paused = true
	resume_button.grab_focus()

func unpause():
	is_paused = false
	hide()
	get_tree().paused = false
	clear_focus()

func clear_focus():
	resume_button.release_focus()
	weapons_button.release_focus()
	options_button.release_focus()
	extras_button.release_focus()
	exit_button.release_focus()

func _on_resume_button_pressed():
	unpause()

func _on_weapons_and_gadgets_button_pressed():
	# Implement weapons and gadgets functionality
	pass

func _on_options_button_pressed():
	# Implement options functionality
	pass

func _on_extras_button_pressed():
	# Implement extras functionality
	pass

func _on_exit_to_main_menu_button_pressed():
	# Implement exit to main menu functionality
	unpause()
	# Add code to switch to the main menu scene
	get_tree().quit() #close the game for now
	pass
