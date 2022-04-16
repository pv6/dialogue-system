tool
class_name Pronouns
extends Resource


export(String) var they := "they"
export(String) var them := "them"
export(String) var their := "their"
export(String) var theirs := "theirs"
export(String) var themself := "themself"

var They: String setget ,get_They
var Them: String setget ,get_Them
var Their: String setget ,get_Their
var Theirs: String setget ,get_Theirs
var Themself: String setget ,get_Themself


func get_They() -> String:
    return they.capitalize()


func get_Them() -> String:
    return them.capitalize()


func get_Their() -> String:
    return their.capitalize()


func get_Theirs() -> String:
    return theirs.capitalize()


func get_Themself() -> String:
    return themself.capitalize()
