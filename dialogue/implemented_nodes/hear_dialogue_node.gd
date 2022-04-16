tool
class_name HearDialogueNode
extends TextDialogueNode


export(int) var speaker_id := -1 setget set_speaker_id
export(int) var listener_id := -1 setget set_listener_id


func get_name() -> String:
    return "Hear Node " + str(id)


func set_speaker_id(new_speaker_id: int) -> void:
    if new_speaker_id != speaker_id:
        speaker_id = new_speaker_id
        emit_signal("contents_changed")


func set_listener_id(new_listener_id: int) -> void:
    if new_listener_id != listener_id:
        listener_id = new_listener_id
        emit_signal("contents_changed")
