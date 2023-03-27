tool
class_name ActionConditionWidget
extends Control


var _nodes: Dictionary

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

onready var _condition_widget = $Contents/ConditionWidget
onready var _action_widget = $Contents/ActionWidget
onready var _node_name = $Contents/NodeName


func select_node(node: DialogueNode) -> void:
    if not node:
        return
    _nodes[node.id] = node
    _update_widget_node()


func unselect_node(node: DialogueNode) -> void:
    if not node:
        return
    _nodes.erase(node.id)
    _update_widget_node()


func clear_selected_node() -> void:
    _nodes.clear()
    _update_widget_node()


func _update_widget_node() -> void:
    var keys = _nodes.values()
    if keys.size() == 1:
        var node = keys[0]
        if node is ReferenceDialogueNode:
            node = _session.dialogue.nodes[node.referenced_node_id]
            assert(not node is ReferenceDialogueNode)
            _condition_widget.disabled = true
            _action_widget.disabled = true
        else:
            _condition_widget.disabled = node is RootDialogueNode
            _action_widget.disabled = false
        _set_node(node)
        _node_name.text = node.get_name()
    else:
        if keys.size() > 1:
            _node_name.text = "More than one node selected"
        else:
            _node_name.text = "No node selected"
        _set_node(null)


func _set_node(node: DialogueNode) -> void:
    _action_widget.node = node
    _condition_widget.node = node
