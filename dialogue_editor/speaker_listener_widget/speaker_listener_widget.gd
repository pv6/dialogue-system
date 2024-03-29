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
    _on_actor_selected(item, "speaker")


func _on_listener_selected(item: StorageItem) -> void:
    _on_actor_selected(item, "listener")


func _on_actor_selected(item: StorageItem, actor: String) -> void:
    # Array[DialogueNode]
    var selected_nodes: Array = _session.dialogue_editor.get_selected_nodes()
    var args := {"item": item, "selected_nodes": selected_nodes, "actor": actor}
    _session.dialogue_undo_redo.commit_action("Select %s" % actor.capitalize(), self, "_select_actor", args)


func _on_speaker_forced_selected(item: StorageItem) -> void:
    if text_node:
        text_node.speaker = item


func _on_listener_forced_selected(item: StorageItem) -> void:
    if text_node:
        text_node.listener = item


# args = {"actor": String, "item": StorageItem, "selected_nodes": Array[DialogueNode]}
func _select_actor(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    if not text_node:
        return null

    var actor: String = args["actor"]
    var item: StorageItem = args["item"]

    dialogue.nodes[text_node.id].set(actor, item)

    var selected_nodes: Array = args["selected_nodes"]
    if selected_nodes.has(text_node):
        for node in selected_nodes:
            if node is TextDialogueNode and dialogue.nodes.has(node.id):
                dialogue.nodes[node.id].set(actor, item)

    return dialogue


func _on_edit_actors_pressed() -> void:
    _session.dialogue_editor.open_actors_editor()


func _on_swap_button_pressed() -> void:
    # Array[DialogueNode]
    var selected_nodes: Array = _session.dialogue_editor.get_selected_nodes()
    _session.dialogue_undo_redo.commit_action("Swap Speaker And Listener", self, "_swap_speaker_listener", {"selected_nodes": selected_nodes})


# args = {"selected_nodes": Array[DialogueNode]}
func _swap_speaker_listener(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    var made_changes := false
    var res: bool

    res = _swap_node_speaker_listener(dialogue.nodes[text_node.id])
    made_changes = made_changes or res

    var selected_nodes: Array = args["selected_nodes"]
    if selected_nodes.has(text_node):
        for node in selected_nodes:
            if node is TextDialogueNode and node.id != text_node.id and dialogue.nodes.has(text_node.id):
                res = _swap_node_speaker_listener(dialogue.nodes[node.id])
                made_changes = made_changes or res

    if not made_changes:
        return null

    return dialogue


func _swap_node_speaker_listener(node: TextDialogueNode) -> bool:
    # don't commit action if speaker and listener are equal
    if not node.listener:
        if not node.speaker:
            return false
    else:
        if node.listener.equals(node.speaker):
            return false

    var tmp = node.speaker
    node.speaker = node.listener
    node.listener = tmp

    return true
