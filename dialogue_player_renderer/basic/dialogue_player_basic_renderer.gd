extends Control


export(Resource) var dialogue: Resource

var _dialogue_player: DialoguePlayer

onready var _text_label: RichTextLabel = $Contents/TextLabel
onready var _say_button_container: VBoxContainer = $Contents/ButtonsContainer
onready var _next_button: IconButton = $Contents/NextButton

onready var _speaker_label: Label = $Contents/ActorsContainer/SpeakerAndListener/SpeakerLabel
onready var _listener_label: Label = $Contents/ActorsContainer/SpeakerAndListener/ListenerLabel


func _init() -> void:
    _dialogue_player = DialoguePlayer.new()


func _ready() -> void:
    _start_dialogue()


func _generate_blackboard_implementations(blackboard_templates: Storage) -> Dictionary:
    # generate implementations for blackboards
    var blackboards := {}
    for template in blackboard_templates.items():
        var implementation := BlackboardImplementation.new()
        implementation.template = template
        blackboards[template.name] = implementation
    return blackboards


func _generate_actor_implementations(actor_names: Storage) -> Dictionary:
    # generate implementations for actors
    var actors := {}
    for actor_name in actor_names.items():
        actors[actor_name] = actor_name
    return actors


func _start_dialogue() -> void:
    if not dialogue:
        return

    var blackboards := _generate_blackboard_implementations(dialogue.blackboards)
    var actors := _generate_actor_implementations(dialogue.actors)

    _dialogue_player.play(dialogue, actors, blackboards)
    _get_next_node()


func _on_say_button_pressed(say_node: SayDialogueNode) -> void:
    for option in _say_button_container.get_children():
        option.queue_free()
    _dialogue_player.say(say_node)
    _get_next_node()


func _on_next_button_pressed():
    _get_next_node()


func _spawn_say_button(id: int, text: String, say_node: SayDialogueNode) -> void:
    var say_button = IconButton.new()
    say_button.align = Button.ALIGN_LEFT
    say_button.text = str(id) + ". " + say_node.text
    say_button.connect("pressed", self, "_on_say_button_pressed", [say_node])
    _say_button_container.add_child(say_button)


func _get_actor(id: int) -> String:
    if id == -1:
        return "NONE"
    return str(dialogue.actors.get_item(id))


func _set_hear_node(hear_node: HearDialogueNode) -> void:
    _text_label.text = hear_node.text
    _next_button.disabled = false

    _speaker_label.text = _get_actor(hear_node.speaker_id)
    _listener_label.text = _get_actor(hear_node.listener_id)


func _get_next_node() -> void:
    # try hear
    var hear_node := _dialogue_player.hear()
    if hear_node:
        _set_hear_node(hear_node)
    else:
        # try say
        var say_options := _dialogue_player.get_say_options()
        if say_options.empty():
            _text_label.text = "END OF DIALOGUE"
            _next_button.disabled = true
            return

        _next_button.disabled = true
        var i := 0
        for say_node in say_options:
            i += 1
            _spawn_say_button(i, say_node.text, say_node)


func _on_replay_button_pressed():
    _start_dialogue()
