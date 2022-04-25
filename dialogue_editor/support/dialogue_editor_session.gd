tool
class_name DialogueEditorSession
extends Resource


export(Resource) var dialogue setget ,get_dialogue
export(Resource) var dialogue_undo_redo setget set_dialogue_undo_redo

# these should be in the editor settings
export(Resource) var global_actors setget set_global_actors
export(Resource) var global_tags setget set_global_tags

export(float, 0, 1) var reference_node_brightness := 0.8

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


func set_global_actors(new_global_actors: Storage) -> void:
    if global_actors != new_global_actors:
        global_actors = new_global_actors
        emit_changed()


func set_global_tags(new_global_tags: Storage) -> void:
    if global_tags != new_global_tags:
        global_tags = new_global_tags
        emit_changed()


func clear_connections() -> void:
    for connection in get_signal_connection_list("changed"):
        disconnect(connection["signal"], connection["target"], connection["method"])
