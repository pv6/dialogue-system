tool
class_name DialogueNodeStyleManager
extends Resource


export(Resource) var default_style
export(Array) var node_styles := [] setget set_node_styles

var _node_styles: Dictionary

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

    if node is ReferenceDialogueNode:
        return get_style(_session.dialogue.nodes[node.referenced_node_id])


    var type = node.get_script()
    if _node_styles.has(type):
        return _node_styles[type]

    return default_style


func set_node_styles(new_node_styles: Array) -> void:
    node_styles = new_node_styles

    _node_styles.clear()
    for style in node_styles:
        _node_styles[style.node_scipt] = style
