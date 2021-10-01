extends ColorRect

func _ready():
	var vbox = $CenterContainer/VBoxContainer
	vbox.get_node("Resume_Button").connect("pressed", self, "resume")
	vbox.get_node("Settings_Button").connect("pressed", self, "show_settings")
	vbox.get_node("Menu_Button").connect("pressed", self, "main_menu")
	vbox.get_node("Quit_Button").connect("pressed", Game, "quit")
	
	get_tree().paused = true
	self.pause_mode = PAUSE_MODE_PROCESS
	activate()

func activate():
	$CenterContainer/VBoxContainer/Resume_Button.grab_focus()

func show_settings():
	$Settings.activate()

func resume():
	queue_free()
	get_tree().paused = false
	Game.resume()

func main_menu():
	queue_free()
	get_tree().paused = false
	MapManager.main_menu()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		resume()
