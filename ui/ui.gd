extends CanvasLayer
class_name UI

@export var credits: RichTextLabel
@export var depth_label: Label
@export var depth_slider: HSlider
@export var debug_button: Button
@export var num_rooms_label: Label
@export var connectedness_label: Label
@export var connectedness_slider: HSlider
@export var lighting_button: Button
@export var debug_label: RichTextLabel

var credits_toggled: bool = false
signal restart_button_pressed()

signal lighting_changed(lighting_enabled: bool)

var room_num_sequence: Array[int] = [1, 5, 17, 45, 109, 253, 577, 1305, 2941, 6616, 14877, 33437]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var _hyperplane = HyperPlane.new(2)
	update_depth()
	update_connectedness()
	debug_button.set_pressed_no_signal(SceneTransition.debug)
	lighting_button.set_pressed_no_signal(SceneTransition.lighting_enabled)
	debug_label.visible = SceneTransition.debug
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		var tween = get_tree().create_tween()
		tween.tween_property(credits, "position", Vector2(251, -360), .5)
		credits_toggled = false


func update_depth() -> void:
	depth_label.text = "Current Depth: " + str(SceneTransition.dungeon_depth)
	depth_slider.value = SceneTransition.dungeon_depth
	num_rooms_label.text = "Rooms: " + str(room_num_sequence[SceneTransition.dungeon_depth])


func update_connectedness() -> void:
	connectedness_label.text = "Connectedness: " + str(SceneTransition.connectedness_factor)
	connectedness_slider.value = SceneTransition.connectedness_factor


func _on_button_button_down() -> void:
	restart_button_pressed.emit()


func _on_credits_button_down() -> void:
	var tween = get_tree().create_tween()
	if credits_toggled:
		tween.tween_property(credits, "position", Vector2(251, -360), .5)
	else:
		tween.tween_property(credits, "position", Vector2(251, 225), .5)
	credits_toggled = !credits_toggled


func _on_h_slider_value_changed(value: float) -> void:
	@warning_ignore("NARROWING_CONVERSION")
	SceneTransition.dungeon_depth = value
	update_depth()


func _on_debug_toggled(toggled_on: bool) -> void:
	SceneTransition.debug = toggled_on
	restart_button_pressed.emit()

func _on_connectedness_slider_value_changed(value: float) -> void:
	SceneTransition.connectedness_factor = value
	update_connectedness()


func _on_debug_2_toggled(toggled_on: bool) -> void:
	SceneTransition.lighting_enabled = toggled_on
	lighting_changed.emit(toggled_on)

func set_debug_text(text: String) -> void:
	debug_label.text = text

func append_debug_text(text: String) -> void:
	debug_label.text += text
