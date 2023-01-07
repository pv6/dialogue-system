tool
extends Resource
class_name DialogueEditorSettings


export(Resource) var global_actors setget set_global_actors
export(Resource) var global_tags setget set_global_tags

export(bool) var autosave := false setget set_autosave

export(float, 0, 1) var reference_node_brightness := 0.8 setget set_reference_node_brightness

export(int) var text_node_min_lines := 4 setget set_text_node_min_lines
export(int) var comment_min_lines := 4 setget set_comment_min_lines

export(Vector2) var node_min_size := Vector2(300, 200) setget set_node_min_size


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


func set_text_node_min_lines(new_text_node_min_lines: int) -> void:
    if text_node_min_lines != new_text_node_min_lines:
        text_node_min_lines = new_text_node_min_lines
        emit_changed()


func set_comment_min_lines(new_comment_min_lines: int) -> void:
    if comment_min_lines != new_comment_min_lines:
        comment_min_lines = new_comment_min_lines
        emit_changed()


func set_node_min_size(new_node_min_size: Vector2) -> void:
    if node_min_size != new_node_min_size:
        node_min_size = new_node_min_size
        emit_changed()
