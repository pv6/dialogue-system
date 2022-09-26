tool
class_name TextDialogueNode
extends DialogueNode


export(String) var text := "dummy text" setget set_text
export(Resource) var tags setget set_tags
export(int) var speaker_id := -1 setget set_speaker_id
export(int) var listener_id := -1 setget set_listener_id


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

    
func set_speaker_id(new_speaker_id: int) -> void:
    if new_speaker_id != speaker_id:
        speaker_id = new_speaker_id
        emit_signal("contents_changed")


func set_listener_id(new_listener_id: int) -> void:
    if new_listener_id != listener_id:
        listener_id = new_listener_id
        emit_signal("contents_changed")
