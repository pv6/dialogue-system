tool
class_name StorageEditor
extends Control


signal storage_edited()

export(Resource) var storage: Resource setget set_storage, get_storage
export(Resource) var item_editor_scene: Resource = preload("res://addons/dialogue_system/dialogue_editor/storage_widgets/storage_editor/item_editor/line_edit/storage_item_line_edit_editor.tscn") setget set_item_editor_scene

var item_editor: StorageItemEditor

var has_changes : bool setget ,get_has_changes

var _index_to_id := {}
var _to_remove_ids := []

var _edited_item_id: int

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

onready var _add_item_dialog: ConfirmationDialog = $Dialogs/AddItemDialog
onready var _edit_item_dialog: ConfirmationDialog = $Dialogs/EditItemDialog
onready var _remove_item_dialog: ConfirmationDialog = $Dialogs/RemoveItemDialog

onready var _item_list: ItemList = $ItemList

onready var _add_button: IconButton = $Buttons/AddButton
onready var _edit_button: IconButton = $Buttons/EditButton
onready var _remove_button: IconButton = $Buttons/RemoveButton

onready var _working_storage_manager := $WorkingStorageManager


func _ready() -> void:
    _update_item_list()
    self.item_editor_scene = item_editor_scene
    self.storage = storage


func set_item_editor_scene(new_storage_item_editor_scene: PackedScene) -> void:
    item_editor_scene = new_storage_item_editor_scene
    if item_editor_scene:
        item_editor = item_editor_scene.instance()


func add_item(item) -> void:
    _working_storage_manager.commit_action("Add Item \"" + str(item) + "\"", self, "_add_item", {"item": item})


func edit_item(id: int, new_item) -> void:
    var action_name = "Edit Item \"" + str(self.storage.get_item(id)) + "\" to " + "\"" + str(new_item) + "\""
    _working_storage_manager.commit_action(action_name, self, "_edit_item", {"new_item": new_item, "id": id})


func remove_item(id: int) -> void:
    var action_name = "Remove Item \"" + str(self.storage.get_item(id)) + "\""
    _working_storage_manager.commit_action(action_name, self, "_remove_item", {"id": id})


func set_storage(new_storage: Storage) -> void:
    storage = new_storage
    if _working_storage_manager:
        if new_storage:
            _working_storage_manager.save_path = new_storage.resource_path
        _working_storage_manager.resource = new_storage
        _working_storage_manager.clear_undo_redo_history()


func get_storage() -> Storage:
    if _working_storage_manager:
        return _working_storage_manager.resource
    return null


func get_has_changes() -> bool:
    return _working_storage_manager.has_unsaved_changes


func _add_item(modified_storage: Storage, params: Dictionary) -> Storage:
    if modified_storage.add_item(params["item"]) == -1:
        return null
    return modified_storage


func _edit_item(modified_storage: Storage, params: Dictionary) -> Storage:
    if not modified_storage.set_item(params["id"], params["new_item"]):
        return null
    return modified_storage


func _remove_item(modified_storage: Storage, params: Dictionary) -> Storage:
    modified_storage.remove_item(params["id"])
    return modified_storage


func _update_item_list() -> void:
    if not _item_list:
        return
    _item_list.clear()
    _index_to_id.clear()

    if _add_button:
        _add_button.disabled = not self.storage
    if _edit_button:
        _edit_button.disabled = true
    if _remove_button:
        _remove_button.disabled = true

    if not self.storage:
        return
    var ids = self.storage.ids()
    for i in range(ids.size()):
        _item_list.add_item(str(self.storage.get_item(ids[i])))
        _index_to_id[i] = ids[i]


func _on_multi_selected(index: int, selected: bool) -> void:
    var selected_item_indices = _item_list.get_selected_items()

    _remove_button.disabled = selected_item_indices.size() == 0
    _edit_button.disabled = selected_item_indices.size() != 1

    for index in selected_item_indices:
        if self.storage.is_locked(_index_to_id[index]):
            _edit_button.disabled = true
            _remove_button.disabled = true
            break


func _on_add_item_dialog_confirmed() -> void:
    add_item(item_editor.get_item())


func _on_edit_item_dialog_confirmed() -> void:
    edit_item(_edited_item_id, item_editor.get_item())


func _on_remove_item_dialog_confirmed() -> void:
    for id in _to_remove_ids:
        remove_item(id)


func _on_add_button_pressed() -> void:
    # set as child before setting item name because init
    _set_item_editor_to_dialog(_add_item_dialog)
    item_editor.reset_item()
    _add_item_dialog.popup_centered()


func _on_edit_button_pressed() -> void:
    var selected_item_indices := _item_list.get_selected_items()
    if selected_item_indices.size() != 1:
        return
    # set as child before setting item name because "ready"
    _set_item_editor_to_dialog(_edit_item_dialog)
    item_editor.set_item(self.storage.get_item(_index_to_id[selected_item_indices[0]]))
    _edited_item_id = _index_to_id[selected_item_indices[0]]
    _edit_item_dialog.popup_centered()


func _on_remove_button_pressed() -> void:
    var selected := _item_list.get_selected_items()
    _to_remove_ids.clear()
    _to_remove_ids.append(_index_to_id[selected[0]])
    var to_remove_text := "\"" + _item_list.get_item_text(selected[0]) + "\""
    for i in range(1, selected.size()):
        _to_remove_ids.append(_index_to_id[selected[i]])
        var name = _item_list.get_item_text(selected[i])
        to_remove_text += ", \"" + name + "\""

    _remove_item_dialog.dialog_text = "Remove item(s) " + to_remove_text + "?"
    _remove_item_dialog.popup_centered()


func _set_item_editor_to_dialog(dialog: ConfirmationDialog) -> void:
    var parent := item_editor.get_parent()
    if parent:
        parent.remove_child(item_editor)
    dialog.add_child(item_editor)


func _on_working_storage_manager_resource_changed() -> void:
    _update_item_list()
    emit_signal("storage_edited")


func _on_menu_button_redo():
    _working_storage_manager.redo()


func _on_menu_button_undo():
    _working_storage_manager.undo()
