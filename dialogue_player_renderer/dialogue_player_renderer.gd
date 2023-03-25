tool
extends Node


# Dialogue
export(Resource) var dialogue: Resource setget set_dialogue
# StorageImplementation
export(Resource) var blackboards_implementation: Resource
# StorageImplementation
export(Resource) var actors_implementation: Resource

var _show_say_options_immidiately: bool = false

var _dialogue_player: DialoguePlayer


func _init() -> void:
    _dialogue_player = DialoguePlayer.new()


func set_dialogue(new_dialogue: Dialogue) -> void:
    dialogue = new_dialogue
#    if dialogue:
#        blackboards_implementation = _generate_blackboards_implementation(dialogue.blackboards)
#        actors_implementation = _generate_actors_implementation(dialogue.actors)
#    else:
#        blackboards_implementation = null
#        actors_implementation = null
    property_list_changed_notify()


func start_dialogue() -> void:
    _clear()

    if not dialogue:
        return

    if not actors_implementation:
        actors_implementation = _generate_actors_implementation(dialogue.actors)
        property_list_changed_notify()
    if not blackboards_implementation:
        blackboards_implementation = _generate_blackboards_implementation(dialogue.blackboards)
        property_list_changed_notify()

    _dialogue_player.play(dialogue, actors_implementation, blackboards_implementation)

    _set_next_node()


func end_dialogue() -> void:
    _dialogue_player.stop()
    _clear()


func _get_actor_name(actor: StorageItem) -> String:
    var actor_impl = _dialogue_player.get_actor_implementation(actor)
    if actor_impl:
        return str(actor_impl)
    return "NONE"


func _generate_blackboards_implementation(blackboard_templates: Storage) -> StorageImplementation:
    # generate dummy implementations for blackboards
    var blackboards := StorageImplementation.new(blackboard_templates)
    for template_reference in blackboard_templates.items():
        var template: Storage = template_reference.resource
        var implementation := StorageImplementation.new(template, false)
        blackboards.s(template, implementation)
    return blackboards


func _generate_actors_implementation(dialogue_actors: Storage) -> StorageImplementation:
    # generate dummy implementations for actors
    var actors := StorageImplementation.new(dialogue_actors)
    for actor_item in dialogue_actors.items():
        assert(actor_item is StorageItem)
        var actor = DialogueActor.new()
        actor.name = str(actor_item)
        actors.s(actor_item, actor)
    return actors


func _on_say_option_selected(say_node: SayDialogueNode) -> void:
    _clear_say_options()
    _dialogue_player.say(say_node)
    _set_next_node()


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
    if not hear_node or _show_say_options_immidiately:
        _try_say()
    else:
        _try_continue()


func _try_say() -> void:
    var say_options := _dialogue_player.get_say_options()
    if not say_options.empty():
        _set_say_options(say_options)
    else:
        _try_continue()


func _try_continue() -> void:
    if _dialogue_player.can_continue():
        _set_continue()
    else:
        end_dialogue()


# virtual
func _clear_say_options() -> void:
    pass


# virtual
func _spawn_say_button(index: int, say_node: SayDialogueNode) -> void:
    pass


# virtual
func _set_hear_node(hear_node: HearDialogueNode) -> void:
    pass


# virtual
func _clear() -> void:
    pass


# virtual
func _clear_current_node() -> void:
    pass


# virtual
func _set_continue() -> void:
    pass
