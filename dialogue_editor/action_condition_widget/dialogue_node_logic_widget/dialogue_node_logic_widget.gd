tool
extends GridContainer


const MultiFlagPicker := preload("res://addons/dialogue_system/dialogue_editor/action_condition_widget/multi_flag_picker/multi_flag_picker.gd")

export(int) var node_id: int setget set_node_id
export(String, "condition", "action") var property: String setget set_property
export(Resource) var logic setget set_logic

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

onready var _flags_check_box: CheckBox = $FlagsCheckBox
onready var _script_check_box: CheckBox = $ScriptCheckBox
onready var _script_text_edit: TextEdit = $ScriptTextEdit
onready var _multi_flag_picker: MultiFlagPicker = $MultiFlagPicker


func _ready():
    self.logic = logic


func set_node_id(new_node_id: int) -> void:
    node_id = new_node_id
    _multi_flag_picker.node_id = new_node_id


func set_property(new_property: String) -> void:
    property = new_property
    _multi_flag_picker.property = new_property


func set_logic(new_logic: DialogueNodeLogic) -> void:
    logic = new_logic
    _update_values()


func _set_flag_checkbox(value: bool) -> void:
    _flags_check_box.pressed = value
    _multi_flag_picker.disabled = not value


func _set_script_checkbox(value: bool) -> void:
    _script_check_box.pressed = value
    _script_text_edit.readonly = not value


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


func _on_flags_check_box_pressed() -> void:
    _session.dialogue_undo_redo.commit_action("Set Node Logic Use Flags", self, "_set_use_flags")


func _on_script_check_box_pressed() -> void:
    _session.dialogue_undo_redo.commit_action("Set Node Logic Use Script", self, "_set_use_script")


func _on_script_text_edit_focus_exited():
    _session.dialogue_undo_redo.commit_action("Set Node Logic Script Text", self, "_set_script_text")


func _set_use_flags(dialogue: Dialogue) -> Dialogue:
    dialogue.nodes[node_id].get(property + "_logic").use_flags = _flags_check_box.pressed
    return dialogue


func _set_use_script(dialogue: Dialogue) -> Dialogue:
    dialogue.nodes[node_id].get(property + "_logic").use_script = _script_check_box.pressed
    return dialogue


func _set_script_text(dialogue: Dialogue) -> Dialogue:
    var edited_logic = dialogue.nodes[node_id].get(property + "_logic")
    if edited_logic.node_script == _script_text_edit.text:
        return null
    edited_logic.node_script = _script_text_edit.text
    return dialogue
