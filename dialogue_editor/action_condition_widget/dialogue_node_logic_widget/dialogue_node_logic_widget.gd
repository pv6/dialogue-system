tool
extends Control


const MultiFlagPicker := preload("res://addons/dialogue_system/dialogue_editor/action_condition_widget/multi_flag_picker/multi_flag_picker.gd")

export(int) var node_id: int setget set_node_id
export(String, "condition", "action") var property: String setget set_property
export(Resource) var logic setget set_logic
export(bool) var disabled: bool setget set_disabled

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

onready var _flags_check_box: CheckBox = $FlagsContainer/FlagsCheckBox
onready var _script_check_box: CheckBox = $ScriptContainer/ScriptCheckBox
onready var _script_text_edit: TextEdit = $ScriptContainer/ScriptTextEdit
onready var _multi_flag_picker: MultiFlagPicker = $FlagsContainer/MultiFlagPicker


func _ready():
    self.node_id = node_id
    self.property = property
    self.logic = logic


func set_node_id(new_node_id: int) -> void:
    node_id = new_node_id
    if _multi_flag_picker:
        _multi_flag_picker.node_id = new_node_id


func set_property(new_property: String) -> void:
    property = new_property
    if _multi_flag_picker:
        _multi_flag_picker.property = new_property


func set_logic(new_logic: DialogueNodeLogic) -> void:
    logic = new_logic
    _update_values()


func set_disabled(new_disabled: bool) -> void:
    disabled = new_disabled
    if _flags_check_box:
        _flags_check_box.disabled = disabled
    if _script_check_box:
        _script_check_box.disabled = disabled
    if _multi_flag_picker:
        _multi_flag_picker.disabled = disabled or not _flags_check_box.pressed
    if _script_text_edit:
        _script_text_edit.readonly = disabled or not _script_check_box.pressed


func _set_flag_checkbox(value: bool) -> void:
    _flags_check_box.pressed = value
    _multi_flag_picker.disabled = disabled or not value


func _set_script_checkbox(value: bool) -> void:
    _script_check_box.pressed = value
    _script_text_edit.readonly = disabled or not value


func _update_values() -> void:
    if not _multi_flag_picker or not _script_text_edit or not _flags_check_box or not _script_check_box:
        return

    if logic:
        _multi_flag_picker.flags = logic.flags
        _multi_flag_picker.node_id = node_id
        _multi_flag_picker.property = property

        _script_text_edit.text = logic.node_script
        _set_flag_checkbox(logic.use_flags)
        _set_script_checkbox(logic.use_script)
    else:
        _multi_flag_picker.flags = []
        _script_text_edit.text = ""
        _set_flag_checkbox(true)
        _set_script_checkbox(false)


func _on_logic_changed() -> void:
    _update_values()


func _on_flags_check_box_toggled(button_pressed: bool) -> void:
    # this was a bit of a hack, sorry :v(
    # if you don't have logic, you don't have a node attached to widget
    # however you might still have a node id, because ~~REASONS~~
    # (i'm too lazy to set it to -1 and then check for -1 are the reasons)
    # so simply don't commit actions if don't have a node attached
    if logic:
        var name = "Set Node Logic Use Flags To " + str(button_pressed)
        _session.dialogue_undo_redo.commit_action(name, self, "_set_use_flags", {"value": button_pressed})


func _on_script_check_box_toggled(button_pressed: bool) -> void:
    # same as '_on_flags_check_box_toggled'
    if logic:
        var name = "Set Node Logic Use Script To " + str(button_pressed)
        _session.dialogue_undo_redo.commit_action(name, self, "_set_use_script", {"value": button_pressed})


func _on_script_text_edit_focus_exited() -> void:
    call_deferred("_call_set_script_text")


func _call_set_script_text() -> void:
    _session.dialogue_undo_redo.commit_action("Set Node " + property.capitalize() + " Script", self, "_set_script_text")


func _set_use_flags(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    return _set_use("flags", dialogue, args)


func _set_use_script(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    return _set_use("script", dialogue, args)


func _set_use(field: String, dialogue: Dialogue, args: Dictionary) -> Dialogue:
    if dialogue.nodes[node_id].get(property + "_logic").get("use_" + field) == args["value"]:
        return null
    dialogue.nodes[node_id].get(property + "_logic").set("use_" + field, args["value"])
    return dialogue


func _set_script_text(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    var edited_logic = dialogue.nodes[node_id].get(property + "_logic")
    if edited_logic.node_script == _script_text_edit.text:
        return null
    edited_logic.node_script = _script_text_edit.text
    return dialogue
