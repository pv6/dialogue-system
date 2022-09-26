tool
extends DialogueNodeContentsRenderer


const SpeakerListenerWidget = preload("res://addons/dialogue_system/dialogue_editor/speaker_listener_widget/speaker_listener_widget.gd")
const TagWidget = preload("res://addons/dialogue_system/dialogue_editor/tag_widgets/tag_widget.gd")

var _text_node: TextDialogueNode
var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

onready var _speaker_listener_widget: SpeakerListenerWidget = $SpeakerListenerWidget
onready var _text_edit: TextEdit = $TextEdit
onready var _tag_widget: TagWidget = $TagWidget


func _update_contents() -> void:
    if _text_node and _text_edit:
        _text_edit.text = _text_node.text
    if _tag_widget:
        _tag_widget.text_node = _text_node
    if _speaker_listener_widget:
        _speaker_listener_widget.text_node = _text_node


func _on_set_node() -> void:
    _text_node = node as TextDialogueNode


func _on_text_edit_focus_exited():
    call_deferred("_call_edit_text")


func _call_edit_text() -> void:
    _session.dialogue_undo_redo.commit_action("Edit Node Text", self, "_edit_text")


func _edit_text(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    if not node or dialogue.nodes[node.id].text == _text_edit.text:
        return null
    dialogue.nodes[node.id].text = _text_edit.text
    return dialogue
