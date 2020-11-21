extends Area2D

onready var x = preload("res://new_assets/x.png")
onready var game = get_node("/root/Game")

var spr_selected = false


func _ready():
	$Hover.hide()


func _on_POS_mouse_entered():
	if not spr_selected:
		$Hover.show()


func _on_POS_mouse_exited():
	$Hover.hide()


func _on_POS_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			spr_selected = true
			$Hover.hide()
			$x_o.set_texture(x)
			game.update()
