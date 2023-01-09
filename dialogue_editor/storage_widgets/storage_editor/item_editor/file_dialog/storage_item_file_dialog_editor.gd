tool
extends StorageItemEditor


const DEFAULT_PATH := "res://"

var _path setget _set_path

onready var _file_dialog: FileDialog = $Dialog/FileDialog
onready var _path_edit: LineEdit = $Contents/PathEdit


func get_item():
    if Directory.new().file_exists(_path):
        # var resource = load(_path)
        # TODO: validate resource
        # ...
        return ExternalResourceReference.new(_path)
    return null


func set_item(item) -> void:
    self._path = item.external_path


func reset_item() -> void:
    self._path = DEFAULT_PATH


func _on_file_selected(path):
    self._path = path


func _set_path(new_path: String) -> void:
    if _path == new_path:
        return

    _path = new_path

    if _path_edit.text != _path:
        _path_edit.text = new_path

    if Directory.new().file_exists(_path):
        _path_edit.modulate = Color.green
    else:
        # todo: also check file validity
        _path_edit.modulate = Color.red


func _on_load_button_pressed():
    _file_dialog.popup_centered()


func _on_path_edit_text_changed(new_text):
    self._path = new_text
