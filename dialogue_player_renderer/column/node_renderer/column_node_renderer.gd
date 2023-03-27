extends RichTextLabel


var node_text: String setget set_node_text
var text_color := Color.antiquewhite setget set_text_color
var speaker: DialogueActor setget set_speaker
var is_history: bool setget set_is_history


func _ready():
    _update_visuals()


func set_node_text(new_node_text: String) -> void:
    node_text = new_node_text
    _update_visuals()


func set_text_color(new_text_color: Color) -> void:
    text_color = new_text_color
    _update_visuals()


func set_speaker(new_speaker: DialogueActor) -> void:
    if not new_speaker:
        new_speaker = DialogueActor.new()
    speaker = new_speaker
    _update_visuals()


func set_is_history(new_is_history: bool) -> void:
    is_history = new_is_history
    _update_visuals()


static func _color_to_hex(color: Color) -> String:
    return "#%02x%02x%02x" % [color.r8, color.g8, color.b8]


func _update_visuals() -> void:
    var args = [_color_to_hex(speaker.name_color), str(speaker).to_upper(),
                _color_to_hex(text_color), node_text]
    bbcode_text = "[color=%s][b]%s[/b][/color][color=%s] - %s[/color]" % args

    if is_history:
        modulate.v = 0.69
    else:
        modulate.v = 1
