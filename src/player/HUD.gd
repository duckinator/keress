extends Control

func _ready():
	Game.connect("resume", self, "reload_hud_settings")

# Load settings that need to be set before playing, or may change while the
# game is paused.
func reload_hud_settings():
	Console.log("reload hud settings")
	_toggle_crosshair(Settings.fetch("show_target_crosshair"))
	_toggle_dot(Settings.fetch("show_target_dot"))

func _toggle_crosshair(value):
	$Crosshair/Top.visible = value
	$Crosshair/Bottom.visible = value
	$Crosshair/Left.visible = value
	$Crosshair/Right.visible = value

func _toggle_dot(value):
	$Crosshair/Dot.visible = value
