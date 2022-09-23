tool
extends Control


const TagRenderer = preload("res://addons/dialogue_system/dialogue_editor/tag_widgets/tag_renderer/tag_renderer.gd")
const StorageEditorDialog = preload("res://addons/dialogue_system/dialogue_editor/storage_widgets/storage_editor_dialog/storage_editor_dialog.gd")

export(Resource) var text_node: Resource setget set_text_node
export(bool) var disabled: bool setget set_disabled

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

var _tag_renderer_scene: PackedScene = preload("res://addons/dialogue_system/dialogue_editor/tag_widgets/tag_renderer/tag_renderer.tscn")

onready var _tag_container: GridContainer = $ScrollContainer/TagContainer

onready var _add_tag_button: IconButton = $ScrollContainer/TagContainer/AddTagButton
onready var _add_tag_dialog: ConfirmationDialog = $Dialogs/AddTagDialog
onready var _add_tag_storage_picker: StoragePicker = $Dialogs/AddTagDialog/StoragePicker

onready var _edit_button: IconButton = $EditButton


func _ready() -> void:
    _session.connect("changed", self, "_on_session_changed")
    _update_tag_picker()


func update_tag_renderers() -> void:
    if not _tag_container:
        return

    # clear old renderers
    for tag_renderer in _tag_container.get_children():
        # spare the add tag button
        if tag_renderer is TagRenderer:
            _tag_container.remove_child(tag_renderer)
            tag_renderer.queue_free()

    # create new renderers
    if not text_node:
        return
    for tag_id in text_node.tags.ids():
        var tag = text_node.tags.get_item(tag_id)
        var tag_renderer: TagRenderer = _tag_renderer_scene.instance()
        _tag_container.add_child(tag_renderer)
        tag_renderer.tag_name = str(tag)
        tag_renderer.connect("delete_button_pressed", self, "_on_delete_button_pressed", [tag_id])

    _tag_container.move_child(_add_tag_button, _tag_container.get_child_count() - 1)

func set_text_node(new_text_node: TextDialogueNode) -> void:
    text_node = new_text_node
    update_tag_renderers()


func set_disabled(new_disabled: bool) -> void:
    disabled = new_disabled
    if _edit_button:
        _edit_button.disabled = new_disabled
    if _tag_container:
        for child in _tag_container.get_children():
            child.disabled = new_disabled


func _on_edit_button_pressed() -> void:
    _session.dialogue_editor.open_tags_editor(text_node)


func _on_delete_button_pressed(tag_id: int) -> void:
    _session.dialogue_undo_redo.commit_action("Remove Tag", self, "_delete_tag", {"id": tag_id})


func _delete_tag(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    if not text_node:
        return null

    # i am truly sorry for this
    # having said that
    # dialogue merely duplicates nodes, so tag storage reference remains the same
    # so need to clone tag storage manually
    # this way, undoredo stores old dialogue with old storage reference
    # and new dialogue with new storage reference
    dialogue.nodes[text_node.id].tags = dialogue.nodes[text_node.id].tags.clone()
    dialogue.nodes[text_node.id].tags.remove_item(args["id"])

    return dialogue


func _add_tag(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    # look up my "_delete_tag" apology
    dialogue.nodes[text_node.id].tags = dialogue.nodes[text_node.id].tags.clone()
    if dialogue.nodes[text_node.id].tags.add_item(args["tag"]) == -1:
        return null
    return dialogue


func _on_add_tag_button_pressed():
    _add_tag_dialog.popup_centered()


func _on_add_tag_dialog_confirmed():
    var tag_to_add = StorageItem.new()
    tag_to_add.storage_id = _add_tag_storage_picker.selected_item_id
    tag_to_add.storage_path = _add_tag_storage_picker.storage.resource_path
    _session.dialogue_undo_redo.commit_action("Add Tag", self, "_add_tag", {"tag": tag_to_add})


func _on_add_tag_dialog_about_to_show():
    _add_tag_storage_picker.select(-1)


func _update_tag_picker() -> void:
    # set selectable tags to global tags
    _add_tag_storage_picker.storage = _session.global_tags
    update_tag_renderers()


func _on_session_changed() -> void:
    _update_tag_picker()


func _on_add_tag_storage_picker_edit_storage_pressed() -> void:
    _session.dialogue_editor.open_global_tags_editor()
