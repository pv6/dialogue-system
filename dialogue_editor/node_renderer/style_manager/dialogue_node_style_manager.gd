tool
class_name DialogueNodeStyleManager
extends Resource


export(Resource) var default_style
export(Array) var node_styles := []

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")


func add_node_style(node_class_name: String, color: Color) -> void:
    var style := DialogueNodeStyle.new()
    style.node_class_name = node_class_name
    style.color = color

    node_styles.push_back(style)
    emit_changed()


func remove_node_style() -> void:
    pass


func get_style(node: DialogueNode) -> DialogueNodeStyle:
    if not node:
        return default_style

    if node as ReferenceDialogueNode:
        return get_style(_session.dialogue.nodes[node.referenced_node_id])

    for style in node_styles:
        if node.get_script().get_path() == style.node_scipt_path:
            return style

    return default_style
