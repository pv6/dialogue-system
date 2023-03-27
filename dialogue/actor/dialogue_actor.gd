tool
class_name DialogueActor
extends Resource


export(String) var name: String = "None"
export(String) var surname: String
export(Resource) var pronouns: Resource = preload("implemented_pronouns/they_them.tres")
export(Texture) var portrait: Texture = preload("res://icon.png")
export(Color) var name_color := Color.white


func _to_string():
    return name + " " + surname
