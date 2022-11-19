tool
class_name DialogueEditorSession
extends Resource


export(Resource) var dialogue setget ,get_dialogue
export(Resource) var dialogue_undo_redo setget set_dialogue_undo_redo

export(Resource) var settings setget set_settings

var dialogue_editor


func get_dialogue() -> Dialogue:
    if dialogue_undo_redo and is_instance_valid(dialogue_undo_redo):
        return dialogue_undo_redo.resource
    return null


func set_dialogue_undo_redo(new_undo_redo: WorkingResourceManager) -> void:
    if dialogue_undo_redo and is_instance_valid(dialogue_undo_redo):
        dialogue_undo_redo.disconnect("resource_changed", self, "emit_changed")
    dialogue_undo_redo = new_undo_redo
    if dialogue_undo_redo:
        dialogue_undo_redo.connect("resource_changed", self, "emit_changed")
    emit_changed()


func set_settings(new_settings: DialogueEditorSettings) -> void:
    if settings != new_settings:
        settings = new_settings
        emit_changed()


func clear_connections() -> void:
    for connection in get_signal_connection_list("changed"):
        disconnect(connection["signal"], connection["target"], connection["method"])
