tool
class_name WorkingResourceManager
extends Control


signal resource_changed()
signal has_unsaved_changes_changed(value)
signal file_changed()
signal save_path_changed()

signal save_dialog_closed()
signal open_dialog_closed()

export(String) var resource_class_name := "Resource" setget set_resource_class_name
export(Resource) var resource: Resource setget set_resource
export(String) var save_path := "" setget set_save_path
export(bool) var autosave := false setget set_autosave

var has_unsaved_changes := false setget set_has_unsaved_changes

var _undo_redo := UndoRedo.new()

var _open_dialog: FileDialog
var _save_as_dialog: FileDialog

var _resource_script_path = ""

func _init():
    _open_dialog = _create_file_dialog("Open", FileDialog.MODE_OPEN_FILE, "_on_open_file_selected", "_on_open_dialog_closed")
    _save_as_dialog = _create_file_dialog("Save", FileDialog.MODE_SAVE_FILE, "_on_save_as_file_selected", "_on_save_dialog_closed")


func set_has_unsaved_changes(value: bool) -> void:
    has_unsaved_changes = value
    emit_signal("has_unsaved_changes_changed", value)
    _autosave()


func set_save_path(new_save_path: String) -> void:
    if resource:
        resource.take_over_path(new_save_path)
#    if save_path == new_save_path:
#        return
    save_path = new_save_path
    emit_signal("save_path_changed")


func set_autosave(new_autosave: bool) -> void:
    autosave = new_autosave
    _autosave()


func new_file() -> void:
    self.save_path = ""
    self.resource = _new_resource()
    clear_undo_redo_history()
    emit_signal("file_changed")


func open() -> void:
    if save_path.get_file().is_valid_filename():
        _open_dialog.current_path = save_path
    else:
        _open_dialog.current_file = ""
    _open_dialog.popup_centered()


func save() -> void:
    if save_path == "":
        save_as()
    else:
        _save()


func save_as() -> void:
    if save_path.get_file().is_valid_filename():
        _save_as_dialog.current_path = save_path
    else:
        _save_as_dialog.current_file = "new_" + resource_class_name.to_lower() + ".tres"
    _save_as_dialog.popup_centered()


func set_resource(new_resource: Clonable) -> void:
    if new_resource:
        resource = new_resource.clone()
        resource.take_over_path(save_path)
    else:
        resource = null
    emit_signal("resource_changed")
    self.has_unsaved_changes = true


func set_resource_class_name(new_resource_class_name: String) -> void:
    resource_class_name = new_resource_class_name

    _resource_script_path = ""
    var script_classes: Array = ProjectSettings.get_setting("_global_script_classes") as Array if ProjectSettings.has_setting("_global_script_classes") else []
    for class_data in script_classes:
        if class_data["class"] == new_resource_class_name:
            _resource_script_path = class_data["path"]


func clear_undo_redo_history() -> void:
    _undo_redo.clear_history()
    self.has_unsaved_changes = false


func undo() -> void:
    if _undo_redo.has_undo():
        print("UNDO: " + _undo_redo.get_current_action_name())
        _undo_redo.undo()
        self.has_unsaved_changes = true


func redo() -> void:
    if _undo_redo.has_redo():
        print("REDO: " + _undo_redo.get_current_action_name())
        _undo_redo.redo()
        self.has_unsaved_changes = true


func commit_action(action_name: String, object, method: String, args: Dictionary = {},
        merge_mode: int = UndoRedo.MERGE_DISABLE) -> bool:
    var old_resource = resource.clone()
    var new_resource = resource.clone()

    new_resource = object.call(method, new_resource, args)
    if not new_resource:
        return false

    var prev_action_name = _undo_redo.get_current_action_name()

    _undo_redo.create_action(action_name, merge_mode)
    _undo_redo.add_do_property(self, "resource", new_resource)
    _undo_redo.add_undo_property(self, "resource", old_resource)
    _undo_redo.commit_action()

    if merge_mode != UndoRedo.MERGE_ENDS or prev_action_name != action_name:
        print(action_name)

    return true


func _save() -> void:
    if not resource:
        return
    assert(save_path.get_file().is_valid_filename())

    ResourceSaver.save(save_path, resource.clone(), ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS)

    self.has_unsaved_changes = false


func _autosave() -> void:
    if autosave and has_unsaved_changes and save_path != "":
        _save()


func _on_save_as_file_selected(save_path: String):
    self.save_path = save_path
    _save()


func _on_open_file_selected(new_save_path: String):
    var res = ResourceLoader.load(new_save_path, "", true)
#    var res = load(save_path)
    if res:
        save_path = ""
        self.resource = res
        self.save_path = new_save_path
        clear_undo_redo_history()
        emit_signal("file_changed")


func _on_save_dialog_closed() -> void:
    emit_signal("save_dialog_closed")


func _on_open_dialog_closed() -> void:
    emit_signal("open_dialog_closed")


func _new_resource() -> Resource:
    if _resource_script_path == "":
        return null
    return load(_resource_script_path).new()


func _create_file_dialog(title: String, mode: int, callback: String, close_callback: String) -> FileDialog:
    var dialog = FileDialog.new()
    # first set mode then title, because Godot changes window title with mode...
    dialog.mode = mode
    dialog.window_title = title + " " + resource_class_name.capitalize()
    dialog.connect("file_selected", self, callback)
    dialog.connect("hide", self, close_callback)
    dialog.rect_min_size = Vector2(300, 300)
    add_child(dialog)

    return dialog
