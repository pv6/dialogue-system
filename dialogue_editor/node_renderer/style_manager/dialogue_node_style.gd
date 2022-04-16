tool
class_name DialogueNodeStyle
extends Resource


export(String) var node_scipt_path: String setget set_node_scipt_path
export(Color) var color: Color setget set_color

var frame_stylebox: StyleBoxFlat = preload("res://addons/dialogue_system/dialogue_editor/node_renderer/style_manager/frame_stylebox.tres").duplicate()
var selected_frame_stylebox: StyleBoxFlat = preload("res://addons/dialogue_system/dialogue_editor/node_renderer/style_manager/selected_frame_stylebox.tres").duplicate()


func set_node_scipt_path(new_node_scipt_path: String) -> void:
    node_scipt_path = new_node_scipt_path


func set_color(new_color: Color) -> void:
    color = new_color

    frame_stylebox.border_color = color

    selected_frame_stylebox.border_color = color
    selected_frame_stylebox.border_color.h += 0.02
    selected_frame_stylebox.border_color.s -= 0.1
    selected_frame_stylebox.border_color.v += 0.1
