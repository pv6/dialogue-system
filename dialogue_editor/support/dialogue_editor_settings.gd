tool
extends Resource
class_name DialogueEditorSettings


# DialogueEditorProject
export(Resource) var project: Resource setget set_project

export(bool) var autosave := false setget set_autosave

export(float, 0, 1) var reference_node_brightness := 0.8 setget set_reference_node_brightness

export(int) var text_node_min_lines := 4 setget set_text_node_min_lines
export(int) var comment_min_lines := 4 setget set_comment_min_lines

export(Vector2) var node_min_size := Vector2(300, 200) setget set_node_min_size

export(int) var node_focus_padding := 30 setget set_node_focus_padding

export(bool) var cache_unused_node_renderers := false setget set_cache_unused_node_renderers


func set_project(new_project: DialogueEditorProject) -> void:
    if project != new_project:
        if project and project.is_connected("changed", self, "emit_changed"):
            project.disconnect("changed", self, "emit_changed")
        project = new_project
        if project:
            project.connect("changed", self, "emit_changed")
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


func set_node_focus_padding(new_node_focus_padding: int) -> void:
    if node_focus_padding != new_node_focus_padding:
        node_focus_padding = new_node_focus_padding
        emit_changed()


func set_cache_unused_node_renderers(new_cache_unused_node_renderers: bool) -> void:
    if cache_unused_node_renderers != new_cache_unused_node_renderers:
        cache_unused_node_renderers = new_cache_unused_node_renderers
        emit_changed()
