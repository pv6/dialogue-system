tool
extends StorageItemEditor


onready var _item_name_line_edit: LineEdit = $LineEdit


func get_item():
    if _item_name_line_edit:
        return _item_name_line_edit.text
    return ""


func set_item(item) -> void:
    if _item_name_line_edit:
        _item_name_line_edit.text = item


func reset_item() -> void:
    if _item_name_line_edit:
        _item_name_line_edit.text = "NewItem"
