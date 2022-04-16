tool
extends AcceptDialog


export(String) var storage_name := "storage" setget set_storage_name
var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

onready var storage_editor: StorageEditor = $StorageEditor


func set_storage_name(new_storage_name: String) -> void:
    storage_name = new_storage_name
    window_title = "Edit " + storage_name.capitalize()
