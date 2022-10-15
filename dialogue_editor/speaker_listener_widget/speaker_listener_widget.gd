tool
extends Control


var text_node: TextDialogueNode setget set_text_node

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

onready var _speaker_picker: StoragePicker = $SpeakerListener/SpeakerPicker
onready var _listener_picker: StoragePicker = $SpeakerListener/ListenerPicker


func set_text_node(new_text_node: TextDialogueNode) -> void:
    text_node = new_text_node
    
    if not _speaker_picker or not _listener_picker:
        return

    var storage = _session.dialogue.actors
    _speaker_picker.storage = storage
    _listener_picker.storage = storage

    var speaker_id = -1
    var listener_id = -1

    if text_node:
        speaker_id = text_node.speaker_id
        listener_id = text_node.listener_id

    _speaker_picker.select(speaker_id)
    _listener_picker.select(listener_id)


func _on_speaker_selected(id: int) -> void:
    _session.dialogue_undo_redo.commit_action("Select Speaker", self, "_select_speaker", {"id": id})


func _on_listener_selected(id: int) -> void:
    _session.dialogue_undo_redo.commit_action("Select Listener", self, "_select_listener", {"id": id})


func _on_speaker_forced_selected(id: int) -> void:
    if text_node:
        text_node.speaker_id = id


func _on_listener_forced_selected(id: int) -> void:
    if text_node:
        text_node.listener_id = id


func _select_speaker(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    if not text_node:
        return null
    dialogue.nodes[text_node.id].speaker_id = args["id"]
    return dialogue


func _select_listener(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    if not text_node:
        return null
    dialogue.nodes[text_node.id].listener_id = args["id"]
    return dialogue


func _on_edit_actors_pressed() -> void:
    _session.dialogue_editor.open_actors_editor()


func _on_swap_button_pressed() -> void:
    _session.dialogue_undo_redo.commit_action("Swap Speaker And Listener", self, "_swap_speaker_listener")


func _swap_speaker_listener(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    var node = dialogue.nodes[text_node.id]
    node.speaker_id = text_node.listener_id
    node.listener_id = text_node.speaker_id
    return dialogue