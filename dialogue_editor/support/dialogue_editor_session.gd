tool
class_name DialogueEditorSession
extends Resource


var dialogue: Dialogue setget ,get_dialogue
var dialogue_undo_redo: WorkingResourceManager setget set_dialogue_undo_redo
var settings: DialogueEditorSettings setget ,get_settings

# DialogueEditor
var dialogue_editor


func get_dialogue() -> Dialogue:
    if dialogue_undo_redo and is_instance_valid(dialogue_undo_redo):
        return dialogue_undo_redo.resource as Dialogue
    return null


func set_dialogue_undo_redo(new_undo_redo: WorkingResourceManager) -> void:
    if dialogue_undo_redo and is_instance_valid(dialogue_undo_redo):
        dialogue_undo_redo.disconnect("resource_changed", self, "emit_changed")
    dialogue_undo_redo = new_undo_redo
    if dialogue_undo_redo:
        dialogue_undo_redo.connect("resource_changed", self, "emit_changed")
    emit_changed()


func get_settings() -> DialogueEditorSettings:
    if dialogue_editor and is_instance_valid(dialogue_editor):
        return dialogue_editor.settings
    return null


func clear_connections() -> void:
    for connection in get_signal_connection_list("changed"):
        disconnect(connection["signal"], connection["target"], connection["method"])
