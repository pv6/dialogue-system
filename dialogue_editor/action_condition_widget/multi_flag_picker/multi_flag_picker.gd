tool
extends Control


const FLAG_PICKER_SCENE := preload("res://addons/dialogue_system/dialogue_editor/action_condition_widget/multi_flag_picker/flag_picker_item.tscn")
const FlagPickerItem = preload("res://addons/dialogue_system/dialogue_editor/action_condition_widget/multi_flag_picker/flag_picker_item.gd")

export(Array) var flags := [] setget set_flags
export(bool) var disabled := false setget set_disabled
export(int) var node_id: int setget set_node_id
export(String, "condition", "action") var property: String

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

onready var _flag_container: VBoxContainer = $HBoxContainer/FlagContainer
onready var _add_flag_button: IconButton = $HBoxContainer/AddFlagButton


func _ready() -> void:
    self.flags = flags


func set_disabled(value: bool) -> void:
    disabled = value
    _add_flag_button.disabled = value
    for child in _flag_container.get_children():
        child.disabled = value


func set_node_id(new_node_id: int) -> void:
    node_id = new_node_id
    for item in _flag_container.get_children():
        item.flag_picker.node_id = node_id
    

func add_flag() -> void:
    _session.dialogue_undo_redo.commit_action("Add " + property.capitalize() + " Flag", self, "_add_flag")


func remove_flag(position: int) -> void:
    _session.dialogue_undo_redo.commit_action("Remove " + property.capitalize() + " Flag", self, "_remove_flag", {"position": position})


func set_flags(new_flags) -> void:
    flags = new_flags
    _update_flag_pickers()


func _update_flag_pickers() -> void:
    if not _flag_container:
        return

    # remove old flag pickers
    for item in _flag_container.get_children():
        item.remove_button.disconnect("pressed", self, "_on_remove_flag_button_pressed")
        item.flag_picker.flag = null
        _flag_container.remove_child(item)
        item.queue_free()

    # add new flag pickers
    for i in range(flags.size()):
        var item: FlagPickerItem = FLAG_PICKER_SCENE.instance()
        _flag_container.add_child(item)
        item.remove_button.connect("pressed", self, "_on_remove_flag_button_pressed", [i])
        item.flag_picker.node_id = node_id
        item.flag_picker.property = property
        item.flag_picker.flag_index = i
        item.flag_picker.flag = flags[i]


func _on_add_flag_button_pressed() -> void:
    add_flag()


func _on_remove_flag_button_pressed(position: int) -> void:
    remove_flag(position)


func _add_flag(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    var new_flag := DialogueFlag.new()
    dialogue.nodes[node_id].get(property + "_logic").flags.push_back(new_flag)
    return dialogue


func _remove_flag(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    var pos_to_remove = args["position"]
    if pos_to_remove < 0 or pos_to_remove >= flags.size():
        return null
    dialogue.nodes[node_id].get(property + "_logic").flags.remove(pos_to_remove)
    return dialogue
