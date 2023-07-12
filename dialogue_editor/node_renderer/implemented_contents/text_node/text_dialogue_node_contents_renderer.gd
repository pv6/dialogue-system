tool
extends DialogueNodeContentsRenderer


const SpeakerListenerWidget = preload("res://addons/dialogue_system/dialogue_editor/speaker_listener_widget/speaker_listener_widget.gd")
const TagWidget = preload("res://addons/dialogue_system/dialogue_editor/tag_widgets/tag_widget.gd")

var _text_node: TextDialogueNode
var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

onready var speaker_listener_widget: SpeakerListenerWidget = $SpeakerListenerWidget
onready var tag_widget: TagWidget = $TagWidget
onready var text_edit: TextEdit = $TextEdit


func update_size() -> void:
    var text_lines = max(text_edit.get_total_visible_rows(), _session.settings.text_node_min_lines)
    text_edit.rect_min_size.y = (text_lines + 0.5) * text_edit.get_line_height()


func _update_contents() -> void:
    if _text_node and text_edit:
        text_edit.text = _text_node.text
    if tag_widget:
        tag_widget.text_node = _text_node
    if speaker_listener_widget:
        speaker_listener_widget.text_node = _text_node


func _on_set_node() -> void:
    _text_node = node as TextDialogueNode


func _on_text_edit_focus_exited():
    call_deferred("_call_edit_text", text_edit.text)


func _call_edit_text(text: String) -> void:
    _session.dialogue_undo_redo.commit_action("Edit Node Text", self, "_edit_text", {"text": text})


# args = {"text"}
func _edit_text(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    var text: String = args["text"]
    if not node or dialogue.nodes[node.id].text == text:
        return null
    dialogue.nodes[node.id].text = text
    return dialogue
