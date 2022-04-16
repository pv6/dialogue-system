tool
extends Control


const DialogueNodeLogicWidget := preload("res://addons/dialogue_system/dialogue_editor/action_condition_widget/dialogue_node_logic_widget/dialogue_node_logic_widget.gd")

export(String, "condition", "action") var property: String setget set_property

var node: DialogueNode setget set_node

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

onready var _logic_widget: DialogueNodeLogicWidget = $DialogueNodeLogicWidget
onready var _label: Label = $PropertyLabel


func _ready():
    self.property = property


func set_property(new_property: String) -> void:
    property = new_property
    if _label:
        _label.text = property.to_upper()


func set_node(new_node: DialogueNode) -> void:
    node = new_node
    if new_node:
        _logic_widget.logic = new_node.get(property + "_logic")
        _logic_widget.node_id = node.id
        _logic_widget.property = property
        _logic_widget.show()
    else:
        _logic_widget.logic = null
        _logic_widget.hide()
