tool
extends Control


export(int) var node_id: int setget set_node_id
export(String, "condition", "action") var property: String setget set_property
export(bool) var disabled := false setget set_disabled

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")


func _ready():
    # wait 1 frame because inherited scenes are not ready yet...
    call_deferred("_update_values")


func set_node_id(new_node_id: int) -> void:
    node_id = new_node_id
    _on_node_id_changed()


func set_disabled(value: bool) -> void:
    disabled = value
    _on_disabled_changed()


func set_property(new_property: String) -> void:
    property = new_property
    _on_property_changed()


# returns Array[DialogueFlag]
func _get_flags(dialogue: Dialogue) -> Array:
    return dialogue.nodes[node_id].get(property + "_logic").flags


# virtual
func _on_property_changed() -> void:
    pass


# virtual
func _on_node_id_changed() -> void:
    pass


# virtual
func _on_disabled_changed() -> void:
    pass


# virtual
func _update_values() -> void:
    pass
