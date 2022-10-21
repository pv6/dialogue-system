tool
extends Resource
class_name Clonable


func clone() -> Clonable:
    var copy = duplicate()
    return copy
