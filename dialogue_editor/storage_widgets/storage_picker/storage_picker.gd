tool
class_name StoragePicker
extends DisableableControl


signal item_selected(id)
signal item_forced_selected(id)
signal edit_storage_pressed()

export(Resource) var storage setget set_storage
export(bool) var can_select_none := true

var selected_item_id: int setget select, get_selected_item_id

onready var _option_button: OptionButton = $OptionButton
onready var _edit_button: IconButton = $EditButton


func _init() -> void:
    _update_options()


func select(id) -> void:
    if id == self.selected_item_id:
        return

    if storage and id in storage.ids():
        _option_button.select(_option_button.get_item_index(id))
    else:
        _option_button.select(0)
        emit_signal("item_forced_selected", _convert_id(_option_button.get_selected_id()))


func get_selected_item_id() -> int:
    if _option_button:
        return _convert_id(_option_button.get_selected_id())
    return -1


func set_storage(new_storage: Storage) -> void:
    if new_storage == storage:
        return

    if storage and storage.is_connected("changed", self, "_on_items_changed"):
        storage.disconnect("changed", self, "_on_items_changed")
    storage = new_storage
    if storage and not storage.is_connected("changed", self, "_on_items_changed"):
        storage.connect("changed", self, "_on_items_changed")

    if _edit_button:
        _edit_button.disabled = disabled or not storage

    _update_options()


func _update_options() -> void:
    if not _option_button:
        return

    if storage:
        var shown_ids = storage.shown_ids()
        var need_none: bool = can_select_none or shown_ids.empty()
        var num_of_options: int = shown_ids.size() + (1 if need_none else 0)

        # adjust number of items
        var old_num_of_options: int = _option_button.get_item_count()
        if num_of_options < old_num_of_options:
            for i in range(num_of_options, old_num_of_options):
                _option_button.remove_item(i)
        elif num_of_options > old_num_of_options:
            for i in range(old_num_of_options, num_of_options):
                _option_button.add_item("")
        var new_num_of_options: int = _option_button.get_item_count()

        # set first item as none
        if need_none:
            _option_button.set_item_text(0, "None")
            _option_button.set_item_id(0, -2)

        # set items
        var start_index: int = 1 if need_none else 0
        for i in range(shown_ids.size()):
            var id = shown_ids[i]
            _option_button.set_item_text(start_index + i, str(storage.get_item(id)))
            _option_button.set_item_id(start_index + i, id)
    else:
        _option_button.clear()
        _option_button.add_item("None", -2)


func _on_items_changed() -> void:
    var selected_id = get_selected_item_id()
    _update_options()
    select(selected_id)


func _on_item_selected(index: int) -> void:
    emit_signal("item_selected", _convert_id(_option_button.get_item_id(index)))


func _on_edit_pressed() -> void:
    emit_signal("edit_storage_pressed")


func _convert_id(option_button_id) -> int:
    if option_button_id == -2:
        return -1
    return option_button_id
