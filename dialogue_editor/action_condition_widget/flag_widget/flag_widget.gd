tool
extends "../base_logic_widget/base_dialogue_node_logic_widget.gd"


export(int) var flag_index
# Flag
export(Resource) var flag setget set_flag


func set_flag(new_flag: DialogueFlag) -> void:
    if flag:
        flag.disconnect("changed", self, "_on_flag_changed")
    flag = new_flag
    if flag:
        flag.connect("changed", self, "_on_flag_changed")
    _update_values()


func _on_flag_changed() -> void:
    _update_values()


func _get_flag(dialogue: Dialogue) -> DialogueFlag:
    return _get_flags(dialogue)[flag_index]
