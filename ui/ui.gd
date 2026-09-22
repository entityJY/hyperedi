extends CanvasLayer

@export var credits: RichTextLabel
var credits_toggled: bool = false
signal restart_button_pressed()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var _hyperplane = HyperPlane.new(2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		var tween = get_tree().create_tween()
		tween.tween_property(credits, "position", Vector2(251, 174), .5)
		credits_toggled = false


func _on_button_button_down() -> void:
	restart_button_pressed.emit()


func _on_credits_button_down() -> void:
	var tween = get_tree().create_tween()
	if credits_toggled:
		tween.tween_property(credits, "position", Vector2(251, -360), .5)
	else:
		tween.tween_property(credits, "position", Vector2(251, 225), .5)
	credits_toggled = !credits_toggled
