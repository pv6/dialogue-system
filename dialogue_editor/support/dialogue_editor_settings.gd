tool
extends Resource
class_name DialogueEditorSettings


export(Resource) var global_actors setget set_global_actors
export(Resource) var global_tags setget set_global_tags

export(bool) var autosave := false setget set_autosave

export(float, 0, 1) var reference_node_brightness := 0.8 setget set_reference_node_brightness


func set_global_actors(new_global_actors: Storage) -> void:
    if global_actors != new_global_actors:
        global_actors = new_global_actors
        emit_changed()


func set_global_tags(new_global_tags: Storage) -> void:
    if global_tags != new_global_tags:
        global_tags = new_global_tags
        emit_changed()


func set_autosave(new_autosave: bool) -> void:
    if autosave != new_autosave:
        autosave = new_autosave
        emit_changed()


func set_reference_node_brightness(new_reference_node_brightness: float) -> void:
    if reference_node_brightness != new_reference_node_brightness:
        reference_node_brightness = new_reference_node_brightness
        emit_changed()