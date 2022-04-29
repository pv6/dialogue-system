tool
extends DialogueNodeContentsRenderer


var _hear_node: HearDialogueNode
var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

var _id: int

onready var _speaker_picker: StoragePicker = $SpeakerPicker
onready var _listener_picker: StoragePicker = $ListenerPicker


func _on_speaker_selected(id: int) -> void:
    _id = id
    _session.dialogue_undo_redo.commit_action("Select Speaker", self, "_select_speaker")


func _on_listener_selected(id: int) -> void:
    _id = id
    _session.dialogue_undo_redo.commit_action("Select Listener", self, "_select_listener")


func _on_speaker_forced_selected(id: int) -> void:
    if _hear_node:
        _hear_node.speaker_id = id


func _on_listener_forced_selected(id: int) -> void:
    if _hear_node:
        _hear_node.listener_id = id


func _select_speaker(dialogue: Dialogue) -> Dialogue:
    if not _hear_node:
        return null
    dialogue.nodes[_hear_node.id].speaker_id = _id
    return dialogue


func _select_listener(dialogue: Dialogue) -> Dialogue:
    if not _hear_node:
        return null
    dialogue.nodes[_hear_node.id].listener_id = _id
    return dialogue


func _update_contents() -> void:
    if not _speaker_picker or not _listener_picker:
        return

    var storage = _session.dialogue.actors
    _speaker_picker.storage = storage
    _listener_picker.storage = storage

    var speaker_id = -1
    var listener_id = -1

    if _hear_node:
        speaker_id = _hear_node.speaker_id
        listener_id = _hear_node.listener_id

    _speaker_picker.select(speaker_id)
    _listener_picker.select(listener_id)


func _on_set_node() -> void:
    _hear_node = node


func _on_edit_actors_pressed() -> void:
    _session.dialogue_editor.open_actors_editor()
