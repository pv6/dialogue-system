tool
class_name TextDialogueNode
extends DialogueNode


export(String) var text := "dummy text" setget set_text
export(Resource) var tags setget set_tags


func _init():
    tags = Storage.new()


func set_text(new_text: String) -> void:
    if new_text == text:
        return
    text = new_text
    emit_signal("contents_changed")


func set_tags(new_tags: Storage) -> void:
    if new_tags == tags:
        return
    tags = new_tags
    emit_signal("contents_changed")
