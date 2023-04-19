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

    var referenced_node: DialogueNode = _session.dialogue.nodes[_reference_node.referenced_node_id]
    if not _referenced_contents or _referenced_contents.node.get_script() != referenced_node.get_script():
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
        _referenced_contents = parent.create_contents(referenced_node)
        if _referenced_contents:
            add_child(_referenced_contents)

    if _referenced_contents:
        _referenced_contents.node = referenced_node
        _referenced_contents.self_modulate.v = _session.settings.reference_node_brightness
        _referenced_contents.disabled = true


func _on_jump_to_option_button_item_selected(index: int):
    _session.dialogue_undo_redo.commit_action("Set Jump To", self, "_set_jump_to", {"jump_to": index})


func _set_jump_to(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    if not node:
        return null
    dialogue.nodes[node.id].jump_to = args["jump_to"]
    return dialogue
