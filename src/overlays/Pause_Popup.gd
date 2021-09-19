extends ColorRect

func _ready():
	var vbox = $CenterContainer/VBoxContainer
	vbox.get_node("Resume_Button").connect("pressed", self, "resume")
	vbox.get_node("Settings_Button").connect("pressed", self, "show_settings")
	vbox.get_node("Menu_Button").connect("pressed", self, "main_menu")
	vbox.get_node("Quit_Button").connect("pressed", Game, "quit")
	
	vbox.get_node("Resume_Button").grab_focus()
	Game.show_cursor()
	get_tree().paused = true
	self.pause_mode = PAUSE_MODE_PROCESS

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

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		resume()
