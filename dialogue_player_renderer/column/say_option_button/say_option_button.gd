extends HBoxContainer


signal pressed


export(int) var index: int
export(String) var text: String = "dummy"

export(String) var index_pattern := "%d. -"
export(bool) var use_quotes: bool

export(Color) var index_color := Color.white
export(Color) var text_color := Color.orangered
export(Color) var text_hover_color := Color.white

var _is_hover: bool

onready var _index_label: Label = $IndexLabel
onready var _text_label: RichTextLabel = $TextLabel


func _ready():
    _update_visuals()


func _gui_input(event):
    # TODO: handle for controllers
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT and event.pressed:
            emit_signal("pressed")


func _update_visuals() -> void:
    if _index_label:
        _index_label.add_color_override("font_color", index_color)
        _index_label.text = index_pattern % [index]
    if _text_label:
        if _is_hover:
            _text_label.add_color_override("default_color", text_hover_color)
        else:
            _text_label.add_color_override("default_color", text_color)
        if use_quotes:
            text = "\"%s\"" % [text]
        _text_label.bbcode_text = " " + text
            

func _on_text_label_mouse_entered() -> void:
    _is_hover = true
    _update_visuals()


func _on_text_label_mouse_exited() -> void:
    _is_hover = false
    _update_visuals()
