tool
class_name TextDialogueNode
extends DialogueNode


export(String) var text := "" setget set_text
# Storage
export(Resource) var tags setget set_tags
# StorageItem
export(Resource) var speaker: Resource setget set_speaker
# StorageItem
export(Resource) var listener: Resource setget set_listener


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


func set_speaker(new_speaker: Resource) -> void:
    if new_speaker != speaker:
        speaker = new_speaker
        emit_signal("contents_changed")


func set_listener(new_listener: Resource) -> void:
    if new_listener != listener:
        listener = new_listener
        emit_signal("contents_changed")


func clone() -> Clonable:
    var copy = .clone()

    copy.tags = tags.clone()
    if speaker:
        copy.speaker = speaker.clone()
    if listener:
        copy.listener = listener.clone()

    return copy
