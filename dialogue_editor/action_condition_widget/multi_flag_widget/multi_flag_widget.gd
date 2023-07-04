tool
extends "../base_logic_widget/base_dialogue_node_logic_widget.gd"


const FlagRendererItem = preload("flag_renderer_item.gd")

const FLAG_RENDERER_ITEM_SCENE := preload("flag_renderer_item.tscn")

export(Array) var flags := [] setget set_flags

onready var _flag_container: VBoxContainer = $HBoxContainer/FlagContainer
onready var _add_condition_flag_button: MenuButton = $HBoxContainer/AddConditionFlagButton
onready var _add_action_flag_button: IconButton = $HBoxContainer/AddActionFlagButton


func _ready() -> void:
    _add_condition_flag_button.get_popup().connect("id_pressed", self, "_on_add_flag_button_pressed")


func _on_node_id_changed() -> void:
    for item in _flag_container.get_children():
        item.flag_renderer.node_id = node_id


func _on_property_changed() -> void:
    match property:
        "action":
            _add_action_flag_button.show()
            _add_condition_flag_button.hide()
        "condition":
            _add_action_flag_button.hide()
            _add_condition_flag_button.show()


func add_blackboard_flag() -> void:
    _session.dialogue_undo_redo.commit_action("Add " + property.capitalize() + " Blackboard Flag", self, "_add_flag", {"flag": BlackboardDialogueFlag.new()})


func add_visited_node_flag() -> void:
    _session.dialogue_undo_redo.commit_action("Add " + property.capitalize() + " Visited Node Flag", self, "_add_flag", {"flag": VisitedNodeDialogueFlag.new()})


func remove_flag(position: int) -> void:
    _session.dialogue_undo_redo.commit_action("Remove " + property.capitalize() + " Flag", self, "_remove_flag", {"position": position})


func set_flags(new_flags) -> void:
    flags = new_flags
    _update_values()


func _update_values() -> void:
    if not _flag_container:
        return

    # remove old flag pickers
    for item in _flag_container.get_children():
        item.remove_button.disconnect("pressed", self, "_on_remove_flag_button_pressed")
        item.flag_renderer.flag = null
        _flag_container.remove_child(item)
        item.queue_free()

    # add new flag pickers
    for i in range(flags.size()):
        var item: FlagRendererItem = FLAG_RENDERER_ITEM_SCENE.instance()
        _flag_container.add_child(item)
        item.remove_button.connect("pressed", self, "_on_remove_flag_button_pressed", [i])
        item.flag_renderer.flag = flags[i]
        item.flag_renderer.node_id = node_id
        item.flag_renderer.property = property
        item.flag_renderer.flag_index = i


func _on_add_flag_button_pressed(id: int = 0) -> void:
    match id:
        0:
            add_blackboard_flag()
        1:
            add_visited_node_flag()


func _on_remove_flag_button_pressed(position: int) -> void:
    remove_flag(position)


# args = {"flag": DialogueFlag}
func _add_flag(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    _get_flags(dialogue).push_back(args["flag"])
    return dialogue


func _remove_flag(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    var pos_to_remove = args["position"]
    if pos_to_remove < 0 or pos_to_remove >= flags.size():
        return null
    _get_flags(dialogue).remove(pos_to_remove)
    return dialogue
