extends Node


export(Resource) var dialogue: Resource

var _dialogue_player: DialoguePlayer


func _init() -> void:
    _dialogue_player = DialoguePlayer.new()


func start_dialogue() -> void:
    if not dialogue:
        return

    var blackboards := _get_blackboard_implementations(dialogue.blackboards)
    var actors := _get_actor_implementations(dialogue.actors)

    _dialogue_player.play(dialogue, actors, blackboards)

    _set_next_node()


func end_dialogue() -> void:
    _dialogue_player.stop()
    _clear()


func _get_blackboard_implementations(blackboard_templates: Storage) -> Dictionary:
    # generate dummy implementations for blackboards
    var blackboards := {}
    for template in blackboard_templates.items():
        var implementation := BlackboardImplementation.new()
        implementation.template = template
        blackboards[template.name] = implementation
    return blackboards


func _get_actor_implementations(actor_names: Storage) -> Dictionary:
    # generate dummy implementations for actors
    var actors := {}
    for actor_name in actor_names.items():
        actors[actor_name] = actor_name
    return actors


func _on_say_option_selected(say_node: SayDialogueNode) -> void:
    _clear_say_options()
    _dialogue_player.say(say_node)
    _set_next_node()


func _clear_say_options() -> void:
    pass
    

func _spawn_say_button(index: int, text: String, say_node: SayDialogueNode) -> void:
    pass


func _set_hear_node(hear_node: HearDialogueNode) -> void:
    pass
    

func _clear() -> void:
    pass


func _set_say_options(say_options: Array) -> void:
    var i := 0
    for say_node in say_options:
        i += 1
        _spawn_say_button(i, say_node.text, say_node)


func _set_next_node() -> void:
    # try hear
    var hear_node := _dialogue_player.hear()
    if hear_node:
        _set_hear_node(hear_node)
    else:
        # try say
        var say_options := _dialogue_player.get_say_options()
        if not say_options.empty():
            _set_say_options(say_options)
        else:
            end_dialogue()
