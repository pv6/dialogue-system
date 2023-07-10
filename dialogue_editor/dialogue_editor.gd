tool
extends Control


signal open_dialogue_error()
signal _dialogue_saved()

const StorageEditorDialog := preload("storage_widgets/storage_editor_dialog/storage_editor_dialog.gd")
const TabsWidget := preload("tabs_widget/tabs_widget.gd")
const DialogueEditorTab := preload("dialogue_editor_tab/dialogue_editor_tab.gd")
const GoToNodeWidget := preload("go_to_node_widget/go_to_node_widget.gd")

const DEFAULT_SETTINGS_PATH := "res://dialogue_editor_settings.tres"
const DEFAULT_GLOBAL_ACTORS_PATH := "res://dialogue_global_actors.tres"
const DEFAULT_GLOBAL_TAGS_PATH := "res://dialogue_global_tags.tres"

const DIALOGUE_EDITOR_TAB_SCENE := preload("dialogue_editor_tab/dialogue_editor_tab.tscn")

export(Resource) var settings: Resource setget set_settings

var session: DialogueEditorSession = preload("session.tres")

var editor_config := ConfigFile.new()

# for tag editor
# i am sorry ok i just didn't care to make a whole new class for this one field
var _edited_text_node_id: int

var _close_after_save_as := false

var _is_saving := false

onready var actors_editor: StorageEditorDialog = $Editors/ActorsEditor
onready var tags_editor: StorageEditorDialog = $Editors/TagsEditor
onready var dialogue_blackboards_editor: StorageEditorDialog = $Editors/DialogueBlackboardsEditor
onready var blackboard_editor: AcceptDialog = $Editors/BlackboardEditor
onready var global_actors_editor: StorageEditorDialog = $Editors/GlobalActorsEditor
onready var global_tags_editor: StorageEditorDialog = $Editors/GlobalTagsEditor

onready var _open_dialogue_dialog: FileDialog = $Dialogs/OpenDialogueDialog
onready var _save_dialogue_as_dialog: FileDialog = $Dialogs/SaveDialogueAsDialog

onready var _tabs_widget: TabsWidget = $VBoxContainer/TabsWidget

onready var _close_unsaved_dialog: ConfirmationDialog = $Dialogs/CloseUnsavedDialog

onready var _go_to_node_widget: GoToNodeWidget = $Dialogs/GoToNodeWidget


func _init() -> void:
    session.clear_connections()
    session.dialogue_editor = self

    editor_config.load("res://addons/dialogue_system/plugin.cfg")


func _ready() -> void:
    session.dialogue_undo_redo = _get_current_working_dialogue_manager()

    set_settings(_init_settings())

    # set open global editors callback functions to GUI buttons
    actors_editor.storage_editor.item_editor.connect("edit_storage_pressed", self, "open_global_actors_editor")
    tags_editor.storage_editor.item_editor.connect("edit_storage_pressed", self, "open_global_tags_editor")

    _close_unsaved_dialog.add_button("Don't Save", true, "close_without_save")
    _close_unsaved_dialog.connect("canceled", self, "_on_save_dialogue_as_dialog_canceled")


func _notification(what) -> void:
    if what == NOTIFICATION_PREDELETE:
        set_settings(null)


func set_settings(new_settings: DialogueEditorSettings) -> void:
    if settings:
        settings.disconnect("changed", self, "_on_settings_changed")
    settings = new_settings
    if settings:
        settings.connect("changed", self, "_on_settings_changed")

    _apply_settings()


# return Array[DialogueNode]
func get_selected_nodes() -> Array:
    var cur_tab := _get_current_editor_tab()
    if not cur_tab:
        return []
    return cur_tab.get_selected_nodes()


# return Array[int]
func get_selected_node_ids() -> Array:
    var cur_tab := _get_current_editor_tab()
    if not cur_tab:
        return []
    return cur_tab.get_selected_node_ids()


func unselect_all():
    call_current_tab_method("unselect_all")


func undo() -> void:
    call_current_tab_method("undo")


func redo() -> void:
    call_current_tab_method("redo")


func copy_selected_nodes() -> void:
    call_current_tab_method("copy_selected_nodes")


func cut_selected_nodes() -> void:
    call_current_tab_method("cut_selected_nodes")


func shallow_duplicate_selected_nodes() -> void:
    call_current_tab_method("shallow_duplicate_selected_nodes")


func deep_duplicate_selected_nodes() -> void:
    call_current_tab_method("deep_duplicate_selected_nodes")


func move_selected_nodes_up() -> void:
    call_current_tab_method("move_selected_nodes_up")


func move_selected_nodes_down() -> void:
    call_current_tab_method("move_selected_nodes_down")


func paste_nodes() -> void:
    call_current_tab_method("paste_nodes")


func paste_cut_nodes_with_children() -> void:
    call_current_tab_method("paste_cut_nodes_with_children")


func paste_cut_node_as_parent() -> void:
    call_current_tab_method("paste_cut_node_as_parent")


func paste_cut_node_with_children_as_parent() -> void:
    call_current_tab_method("paste_cut_node_with_children_as_parent")


func insert_parent_hear_node() -> void:
    call_current_tab_method("insert_parent_hear_node")


func insert_parent_say_node() -> void:
    call_current_tab_method("insert_parent_say_node")


func insert_child_hear_node() -> void:
    call_current_tab_method("insert_child_hear_node")


func insert_child_say_node() -> void:
    call_current_tab_method("insert_child_say_node")


func deep_delete_selected_nodes() -> void:
    call_current_tab_method("deep_delete_selected_nodes")


func shallow_delete_selected_nodes() -> void:
    call_current_tab_method("shallow_delete_selected_nodes")


func edit_selected_node_text() -> void:
    call_current_tab_method("edit_selected_node_text")


# nodes: Array[DialogueNode]
func focus_nodes(nodes: Array) -> void:
    call_current_tab_method_one_arg("focus_nodes", nodes)


func new_dialogue() -> void:
    _tabs_widget.add_tab()
    var cur_tab := _get_current_editor_tab()
    cur_tab.new_dialogue()


func open_dialogue() -> void:
    _open_dialogue_dialog.popup_centered()


func save_dialogue() -> void:
    var current_tab := _get_current_editor_tab()
    if not current_tab:
        print("No dialogue opened!")
        return

    if current_tab.get_save_path() == "":
        save_dialogue_as()
    else:
        _is_saving = true
        var result = current_tab.save_dialogue()
        if result is GDScriptFunctionState:
            yield(result, "completed")
        _is_saving = false
        emit_signal("_dialogue_saved")


func save_dialogue_as() -> void:
    var current_tab := _get_current_editor_tab()
    if not current_tab:
        print("No dialogue opened!")
        return

    var save_path := current_tab.get_save_path()
    if save_path.get_file().is_valid_filename():
        _save_dialogue_as_dialog.current_path = save_path
    else:
        _save_dialogue_as_dialog.current_file = "new_dialogue.tres"
    _save_dialogue_as_dialog.popup_centered()


func save_all_dialogues() -> void:
    for tab in _tabs_widget.get_tabs():
        if tab.working_dialogue_manager.save_path != "":
            tab.working_dialogue_manager.save()


func close_dialogue() -> void:
    var working_dialogue_manager := _get_current_working_dialogue_manager()
    if working_dialogue_manager.has_unsaved_changes:
        var name := working_dialogue_manager.save_path
        if name == "":
            name = "unsaved dialogue"
        _close_unsaved_dialog.dialog_text = "Save changes to '%s' before closing?" % name
        _close_unsaved_dialog.popup_centered()
    else:
        if _is_saving:
            yield(self, "_dialogue_saved")
        _tabs_widget.remove_current_tab()


func next_dialogue() -> void:
    _tabs_widget.set_next_tab()


func previous_dialogue() -> void:
    _tabs_widget.set_previous_tab()


func open_actors_editor() -> void:
    var dialogue := get_dialogue()
    if not dialogue:
        print("No dialogue opened!")
        return
    actors_editor.storage_editor.storage = dialogue.actors
    actors_editor.popup_centered()


func open_tags_editor(text_node: TextDialogueNode) -> void:
    tags_editor.storage_editor.storage = text_node.tags
    _edited_text_node_id = text_node.id
    tags_editor.popup_centered()


func open_global_actors_editor() -> void:
    global_actors_editor.storage_editor.storage = settings.global_actors
    global_actors_editor.popup_centered()


func open_global_tags_editor() -> void:
    global_tags_editor.storage_editor.storage = settings.global_tags
    global_tags_editor.popup_centered()


func open_dialogue_blackboards_editor() -> void:
    var dialogue := get_dialogue()
    if not dialogue:
        print("No dialogue opened!")
        return
    dialogue_blackboards_editor.storage_editor.storage = dialogue.blackboards
    dialogue_blackboards_editor.popup_centered()


func open_blackboard_editor(blackboard: StorageItem = null) -> void:
    if not blackboard:
        var dialogue := get_dialogue()
        if not dialogue:
            print("No dialogue opened!")
            return
        blackboard = dialogue.get_local_blackboard_ref().storage_item
    blackboard_editor.blackboard = blackboard
    blackboard_editor.popup_centered()


func get_dialogue() -> Dialogue:
    var working_dialogue_manager := _get_current_working_dialogue_manager()
    if not working_dialogue_manager:
        return null
    return working_dialogue_manager.resource as Dialogue


func go_to_node() -> void:
    var dialogue := get_dialogue()
    if not dialogue:
        return
    _go_to_node_widget.valid_ids = dialogue.nodes
    _go_to_node_widget.popup_centered()



func _on_actors_editor_confirmed() -> void:
    if actors_editor.storage_editor.has_changes:
        _get_current_working_dialogue_manager().commit_action("Edit Dialogue Actors", self, "_edit_actors")


func _on_tags_editor_confirmed() -> void:
    if tags_editor.storage_editor.has_changes:
        _get_current_working_dialogue_manager().commit_action("Edit Node Tags", self, "_edit_tags")


func _on_dialogue_blackboards_editor_confirmed() -> void:
    if dialogue_blackboards_editor.storage_editor.has_changes:
        _get_current_working_dialogue_manager().commit_action("Edit Dialogue Blackboards", self, "_edit_blackboards")


func _edit_actors(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    dialogue.actors = actors_editor.storage_editor.storage
    return dialogue


func _edit_tags(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    dialogue.nodes[_edited_text_node_id].tags = tags_editor.storage_editor.storage
    return dialogue


func _edit_blackboards(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    dialogue.blackboards = dialogue_blackboards_editor.storage_editor.storage
    return dialogue


func _save_external_resource(resource: Resource) -> void:
    var ref = ExternalResourceReference.new(resource.resource_path)
    ref.set_resource(resource)


func _on_global_actors_editor_confirmed() -> void:
    session.settings.global_actors = global_actors_editor.storage_editor.storage
    _save_external_resource(session.settings.global_actors)


func _on_global_actors_tags_confirmed():
    session.settings.global_tags = global_tags_editor.storage_editor.storage
    _save_external_resource(session.settings.global_tags)


func _on_settings_changed() -> void:
    _apply_settings()


func _apply_settings() -> void:
    if not settings or not actors_editor:
        return

    actors_editor.storage_editor.item_editor.storage = settings.global_actors
    tags_editor.storage_editor.item_editor.storage = settings.global_tags

    for tab in _tabs_widget.get_tabs():
        tab.apply_settings()


func _open_or_create_external_resource(path: String, default_value: Resource) -> Resource:
    var ref := ExternalResourceReference.new(path)
    if not ref.get_resource():
        ref.set_resource(default_value)
    return ref.get_resource()


func _init_settings() -> DialogueEditorSettings:
    var output: DialogueEditorSettings = settings

    if not output:
        output = _open_or_create_external_resource(
                DEFAULT_SETTINGS_PATH, DialogueEditorSettings.new()
        )
    if not output.global_actors:
        output.global_actors = _open_or_create_external_resource(
                DEFAULT_GLOBAL_ACTORS_PATH, Storage.new()
        )
    if not output.global_tags:
        output.global_tags = _open_or_create_external_resource(
                DEFAULT_GLOBAL_TAGS_PATH, Storage.new()
        )

    _save_external_resource(output)

    return output


func _get_current_working_dialogue_manager() -> WorkingResourceManager:
    return _get_working_dialogue_manager(_tabs_widget.get_current_tab_index())


func _get_working_dialogue_manager(tab_index: int) -> WorkingResourceManager:
    var tab := _tabs_widget.get_tab(tab_index)
    if tab:
        return tab.working_dialogue_manager
    return null


func _get_current_editor_tab() -> DialogueEditorTab:
    return _tabs_widget.get_current_tab() as DialogueEditorTab


func _on_tab_close(tab) -> void:
    close_dialogue()


func _on_tab_changed(tab_index: int) -> void:
    session.dialogue_undo_redo = _get_current_working_dialogue_manager()
    var cur_tab := _get_current_editor_tab()
    if cur_tab:
        cur_tab.graph_renderer.grab_focus()


func _on_save_before_close_pressed():
    var working_dialogue_manager := _get_current_working_dialogue_manager()
    var need_save_as: bool = working_dialogue_manager.save_path == ""
    if need_save_as:
        _close_after_save_as = true
    save_dialogue_as()


func _on_close_unsaved_dialog_custom_action(action: String) -> void:
#    _close_unsaved_dialog.
    if action == "close_without_save":
        _tabs_widget.remove_current_tab()
        _close_unsaved_dialog.hide()


func _on_open_dialogue_dialog_file_selected(path: String):
    _tabs_widget.add_tab()
    var cur_tab := _get_current_editor_tab()
    cur_tab.open_dialogue(path)


func _on_save_dialogue_as_dialog_file_selected(path: String):
    _is_saving = true
    var result = _get_current_editor_tab().save_dialogue_as(path)
    if result is GDScriptFunctionState:
        yield(result, "completed")
    _is_saving = false
    emit_signal("_dialogue_saved")

    if _close_after_save_as:
        _tabs_widget.remove_current_tab()
        _close_after_save_as = false


func _on_save_dialogue_as_dialog_canceled():
    _close_after_save_as = false


func call_current_tab_method(method: String) -> void:
    var current_tab := _get_current_editor_tab()
    if current_tab:
        current_tab.call(method)
    else:
        print("No dialogue opened!")


func call_current_tab_method_one_arg(method: String, arg) -> void:
    var current_tab := _get_current_editor_tab()
    if current_tab:
        current_tab.call(method, arg)
    else:
        print("No dialogue opened!")


func _on_go_to_node_widget_go_to_node(id: int) -> void:
    focus_nodes([get_dialogue().nodes[id]])
