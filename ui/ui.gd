extends CanvasLayer


signal restart_button_pressed()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var _hyperplane = HyperPlane.new(2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_button_down() -> void:
	restart_button_pressed.emit()
