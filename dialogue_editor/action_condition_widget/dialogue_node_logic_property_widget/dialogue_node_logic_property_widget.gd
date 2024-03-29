tool
extends "../base_logic_widget/base_dialogue_node_logic_widget.gd"


const DialogueNodeLogicWidget := preload("res://addons/dialogue_system/dialogue_editor/action_condition_widget/dialogue_node_logic_widget/dialogue_node_logic_widget.gd")

export(Resource) var logic_widget_scene: Resource = preload("res://addons/dialogue_system/dialogue_editor/action_condition_widget/dialogue_node_logic_widget/dialogue_node_logic_widget.tscn")

var node: DialogueNode setget set_node
var logic_widget: DialogueNodeLogicWidget

onready var _label: Label = $PropertyLabel


func _ready():
    logic_widget = logic_widget_scene.instance()
    add_child(logic_widget)


func _on_property_changed() -> void:
    if _label:
        _label.text = property.to_upper()


func set_node(new_node: DialogueNode) -> void:
    node = new_node
    if new_node:
        # set id before logic for auto flags to work correctly
        logic_widget.node_id = new_node.id
        logic_widget.logic = new_node.get(property + "_logic")
        logic_widget.property = property
        logic_widget.show()
    else:
        logic_widget.logic = null
        logic_widget.hide()
