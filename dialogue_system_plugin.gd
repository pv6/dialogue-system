tool
extends EditorPlugin


var dialogue_editor_instance
var dialogue_editor_scene = preload("dialogue_editor/dialogue_editor.tscn")


func _enter_tree():
    dialogue_editor_instance = dialogue_editor_scene.instance()
    # Add the main panel to the editor's main viewport.
    get_editor_interface().get_editor_viewport().add_child(dialogue_editor_instance)
    # Hide the main panel. Very much required.
    make_visible(false)


func _exit_tree():
    if dialogue_editor_instance:
        dialogue_editor_instance.queue_free()


func has_main_screen():
    return true


func make_visible(visible):
    if dialogue_editor_instance:
        dialogue_editor_instance.visible = visible


func get_plugin_name():
    return "Dialogue Editor"


func get_plugin_icon():
    # Must return some kind of Texture for the icon.
    return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")
