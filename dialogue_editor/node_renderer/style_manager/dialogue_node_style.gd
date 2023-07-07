tool
class_name DialogueNodeStyle
extends Resource


export(Script) var node_scipt: Script
export(Color) var color: Color setget set_color

var frame_stylebox: StyleBoxFlat = preload("frame_stylebox.tres").duplicate()
var selected_frame_stylebox: StyleBoxFlat = preload("selected_frame_stylebox.tres").duplicate()


func set_color(new_color: Color) -> void:
    color = new_color

    frame_stylebox.border_color = color

    selected_frame_stylebox.border_color = color
    selected_frame_stylebox.border_color.h += 0.02
    selected_frame_stylebox.border_color.s -= 0.1
    selected_frame_stylebox.border_color.v += 0.1
