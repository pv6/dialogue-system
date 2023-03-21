tool
extends "../base_logic_widget/base_dialogue_node_logic_widget.gd"


const FlagWidgetItem = preload("flag_widget_item.gd")

const FLAG_WIDGET_ITEM_SCENE := preload("flag_widget_item.tscn")

const FLAG_WIDGET_SCENES := []

export(Array) var flags := [] setget set_flags

onready var _flag_container: VBoxContainer = $HBoxContainer/FlagContainer
onready var _add_condition_flag_button: MenuButton = $HBoxContainer/AddConditionFlagButton
onready var _add_action_flag_button: IconButton = $HBoxContainer/AddActionFlagButton


func _ready() -> void:
    _add_condition_flag_button.get_popup().connect("id_pressed", self, "_on_add_flag_button_pressed")


func set_disabled(value: bool) -> void:
    disabled = value
    _add_action_flag_button.disabled = value
    _add_condition_flag_button.disabled = value
    for child in _flag_container.get_children():
        child.disabled = value


func _on_node_id_changed() -> void:
    for item in _flag_container.get_children():
        item.flag_widget.node_id = node_id


func _on_property_changed() -> void:
    match property:
        "action":
            _add_action_flag_button.show()
            _add_condition_flag_button.hide()
        "condition":
            _add_action_flag_button.hide()
            _add_condition_flag_button.show()


func add_blackboard_flag() -> void:
    _session.dialogue_undo_redo.commit_action("Add " + property.capitalize() + " Blackboard Flag", self, "_add_blackboard_flag")


func add_visited_node_flag() -> void:
    _session.dialogue_undo_redo.commit_action("Add " + property.capitalize() + " Visited Node Flag", self, "_add_visited_node_flag")


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
        item.flag_widget.flag = null
        _flag_container.remove_child(item)
        item.queue_free()

    # add new flag pickers
    for i in range(flags.size()):
        var item: FlagWidgetItem = FLAG_WIDGET_ITEM_SCENE.instance()
        _flag_container.add_child(item)
        item.remove_button.connect("pressed", self, "_on_remove_flag_button_pressed", [i])
        item.set_flag(flags[i])
        item.flag_widget.node_id = node_id
        item.flag_widget.property = property
        item.flag_widget.flag_index = i


func _on_add_flag_button_pressed(id: int = 0) -> void:
    match id:
        0:
            add_blackboard_flag()
        1:
            add_visited_node_flag()


func _on_remove_flag_button_pressed(position: int) -> void:
    remove_flag(position)


func _add_blackboard_flag(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    var new_flag := DialogueFlag.new()
    _get_flags(dialogue).push_back(new_flag)
    return dialogue


func _add_visited_node_flag(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    var new_flag := DialogueFlag.new()
    new_flag.blackboard = dialogue.get_local_blackboard_ref()
    new_flag.name = "auto_visited_node_0"

    _get_flags(dialogue).push_back(new_flag)

    return dialogue


func _remove_flag(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    var pos_to_remove = args["position"]
    if pos_to_remove < 0 or pos_to_remove >= flags.size():
        return null
    _get_flags(dialogue).remove(pos_to_remove)
    return dialogue
