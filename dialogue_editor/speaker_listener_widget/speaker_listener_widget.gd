tool
extends Control


var text_node: TextDialogueNode setget set_text_node

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

onready var _speaker_picker: StorageItemEditor = $SpeakerListener/SpeakerPicker
onready var _listener_picker: StorageItemEditor = $SpeakerListener/ListenerPicker


func set_text_node(new_text_node: TextDialogueNode) -> void:
    text_node = new_text_node

    if not _speaker_picker or not _listener_picker:
        return

    var storage = _session.dialogue.actors
    _speaker_picker.storage = storage
    _listener_picker.storage = storage

    var speaker = null
    var listener = null

    if text_node:
        speaker = text_node.speaker
        listener = text_node.listener

    _speaker_picker.select(speaker)
    _listener_picker.select(listener)


func _on_speaker_selected(item: StorageItem) -> void:
    _session.dialogue_undo_redo.commit_action("Select Speaker", self, "_select_speaker", {"item": item})


func _on_listener_selected(item: StorageItem) -> void:
    _session.dialogue_undo_redo.commit_action("Select Listener", self, "_select_listener", {"item": item})


func _on_speaker_forced_selected(item: StorageItem) -> void:
    if text_node:
        text_node.speaker = item


func _on_listener_forced_selected(item: StorageItem) -> void:
    if text_node:
        text_node.listener = item


func _select_speaker(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    if not text_node:
        return null
    dialogue.nodes[text_node.id].speaker = args["item"]
    return dialogue


func _select_listener(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    if not text_node:
        return null
    dialogue.nodes[text_node.id].listener = args["item"]
    return dialogue


func _on_edit_actors_pressed() -> void:
    _session.dialogue_editor.open_actors_editor()


func _on_swap_button_pressed() -> void:
    _session.dialogue_undo_redo.commit_action("Swap Speaker And Listener", self, "_swap_speaker_listener")


func _swap_speaker_listener(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    var node = dialogue.nodes[text_node.id]

    # don't commit action if speaker and listener are equal
    if not node.listener:
        if not node.speaker:
            return null
    else:
        if node.listener.equals(node.speaker):
            return null

    node.speaker = text_node.listener
    node.listener = text_node.speaker
    return dialogue
