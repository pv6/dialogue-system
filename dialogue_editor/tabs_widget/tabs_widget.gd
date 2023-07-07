tool
extends Control


signal tab_close(tab_index)
signal tab_changed(tab_index)


const Tab := preload("tab.gd")
const TabsWithAdd := preload("tabs_with_add/tabs_with_add.gd")

export(PackedScene) var tab_scene: PackedScene
export(bool) var show_add_button := true setget set_show_add_button

onready var _tabs: TabsWithAdd = $TabsWithAdd
onready var _tab_container: TabContainer = $TabContainer


func _ready():
    set_show_add_button(show_add_button)


func get_current_tab_index() -> int:
    return _tabs.current_tab


func get_tab(tab_index: int) -> Tab:
    return _tab_container.get_tab_control(tab_index) as Tab


func get_current_tab() -> Tab:
    return _tab_container.get_current_tab_control() as Tab


# returns Array[Tab]
func get_tabs() -> Array:
    return _tab_container.get_children()


func add_tab() -> void:
    _tabs.add_tab()
    var new_tab_index := _tabs.get_tab_count() - 1

    var new_tab: Tab = tab_scene.instance()
    new_tab.connect("title_changed", self, "_on_title_changed", [new_tab_index])
    _tab_container.add_child(new_tab)

    _tabs.set_tab_title(new_tab_index, new_tab.get_title())

    set_current_tab(get_tab_count() - 1)


func remove_tab(tab_index: int) -> void:
    _tabs.remove_tab(tab_index)
    var tab_to_remove := _tab_container.get_tab_control(tab_index)
    if tab_to_remove:
        _tab_container.remove_child(tab_to_remove)
        tab_to_remove.queue_free()
    set_current_tab(get_tab_count() - 1)


func remove_current_tab() -> void:
    remove_tab(get_current_tab_index())


func get_tab_count() -> int:
    return _tabs.get_tab_count()


func set_current_tab(tab_index: int) -> void:
    _tabs.current_tab = tab_index
    emit_signal("tab_changed", tab_index)


func set_show_add_button(value: bool) -> void:
    show_add_button = value
    if _tabs:
        _tabs.show_add_button = value


func _on_tab_add() -> void:
    add_tab()


func _on_title_changed(new_title: String, tab_index: int) -> void:
    _tabs.set_tab_title(tab_index, new_title)


func _on_tab_changed(tab_index: int) -> void:
    _tab_container.current_tab = tab_index
    emit_signal("tab_changed", tab_index)


func _on_tab_close(tab_index: int) -> void:
    emit_signal("tab_close", tab_index)
