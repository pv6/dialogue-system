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


func _get_actor(id: int):
    var actor_item =  dialogue.actors.get_item(id)
    if not actor_item or not _dialogue_player.actors.has(actor_item.get_value()):
        return null
    return _dialogue_player.actors[actor_item.get_value()]
    

func _get_actor_name(id: int) -> String:
    var actor = _get_actor(id)
    if actor:
        return str(actor)
    return "NONE"


func _get_blackboard_implementations(blackboard_templates: Storage) -> Dictionary:
    # generate dummy implementations for blackboards
    var blackboards := {}
    for template_reference in blackboard_templates.items():
        var template: Storage = template_reference.resource
        var implementation := StorageImplementation.new()
        implementation.template = template
        blackboards[template.name] = implementation
    return blackboards


func _get_actor_implementations(dialogue_actors: Storage) -> Dictionary:
    # generate dummy implementations for actors
    var actors := {}
    for actor_item in dialogue_actors.items():
        var actor = DialogueActor.new()
        actor.name = actor_item.get_value()
        actors[actor_item.get_value()] = actor
    return actors


func _on_say_option_selected(say_node: SayDialogueNode) -> void:
    _clear_say_options()
    _dialogue_player.say(say_node)
    _set_next_node()


func _clear_say_options() -> void:
    pass
    

func _spawn_say_button(index: int, say_node: SayDialogueNode) -> void:
    pass


func _set_hear_node(hear_node: HearDialogueNode) -> void:
    pass
    

func _clear() -> void:
    pass


func _clear_current_node() -> void:
    pass


func _set_continue() -> void:
    pass


func _set_say_options(say_options: Array) -> void:
    var i := 0
    for say_node in say_options:
        i += 1
        _spawn_say_button(i, say_node)


func _set_next_node() -> void:
    _clear_current_node()
    
    # try hear
    var hear_node := _dialogue_player.hear()
    if hear_node:
        _set_hear_node(hear_node)
    # try say
    var say_options := _dialogue_player.get_say_options()
    if not say_options.empty():
        _set_say_options(say_options)
    else:
        if _dialogue_player.can_continue():
            _set_continue()
        else:
            end_dialogue()
