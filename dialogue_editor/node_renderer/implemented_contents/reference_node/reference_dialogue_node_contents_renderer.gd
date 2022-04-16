tool
extends DialogueNodeContentsRenderer


var _reference_node: ReferenceDialogueNode

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

onready var _jump_to_option_button: OptionButton = $JumpToContents/OptionButton

onready var _referenced_contents: DialogueNodeContentsRenderer


func _on_set_node() -> void:
    _reference_node = node as ReferenceDialogueNode


func _update_contents() -> void:
    if not _reference_node or not _jump_to_option_button:
        return

    # set jump to option button value
    if not _reference_node:
        _jump_to_option_button.select(0)
    else:
        _jump_to_option_button.select(_reference_node.jump_to)

    # remove old referenced contents
    if _referenced_contents:
        _referenced_contents.node = null
        remove_child(_referenced_contents)
        _referenced_contents = null

    # create new referenced contents
    var parent := get_parent()
    while not parent.has_method("create_contents"):
        parent = parent.get_parent()
        assert(parent)
    _referenced_contents = parent.create_contents(_session.dialogue.nodes[_reference_node.referenced_node_id])
    if _referenced_contents:
        add_child(_referenced_contents)


func _on_jump_to_option_button_item_selected(index: int):
    if _reference_node:
        _reference_node.jump_to = index
