extends "res://addons/dialogue_system/dialogue_player_renderer/dialogue_player_renderer.gd"


onready var _text_label: RichTextLabel = $Contents/TextLabel
onready var _say_button_container: VBoxContainer = $Contents/ButtonsContainer
onready var _next_button: IconButton = $Contents/NextButton

onready var _speaker_label: Label = $Contents/ActorsContainer/SpeakerAndListener/SpeakerLabel
onready var _listener_label: Label = $Contents/ActorsContainer/SpeakerAndListener/ListenerLabel


func _ready() -> void:
    start_dialogue()


func _on_next_button_pressed():
    _set_next_node()


func _clear() -> void:
    _text_label.text = "END OF DIALOGUE"
    _next_button.disabled = true


func _spawn_say_button(index: int, say_node: SayDialogueNode) -> void:
    var say_button = IconButton.new()
    say_button.align = Button.ALIGN_LEFT
    say_button.text = str(index) + ". " + say_node.text
    say_button.connect("pressed", self, "_on_say_option_selected", [say_node])
    _say_button_container.add_child(say_button)


func _set_hear_node(hear_node: HearDialogueNode) -> void:
    _text_label.text = hear_node.text
    _next_button.disabled = false

    _speaker_label.text = _get_actor_name(hear_node.speaker_id)
    _listener_label.text = _get_actor_name(hear_node.listener_id)


func _clear_say_options() -> void:
    for option in _say_button_container.get_children():
        option.queue_free()


func _set_say_options(say_options: Array) -> void:
    _next_button.disabled = true
    ._set_say_options(say_options)


func _on_replay_button_pressed():
    start_dialogue()
