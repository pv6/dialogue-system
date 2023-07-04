tool
extends "../base_logic_widget/base_dialogue_node_logic_widget.gd"


export(int) var flag_index setget set_flag_index
# DialogueFlag
export(Resource) var flag setget set_flag


func set_flag(new_flag: DialogueFlag) -> void:
    if new_flag == flag:
        return

    if flag:
        flag.disconnect("changed", self, "_update_values")
    flag = new_flag
    if flag:
        flag.connect("changed", self, "_update_values")
    _update_values()
    _on_flag_set()


func set_flag_index(new_flag_index: int) -> void:
    if flag_index == new_flag_index:
        return
    flag_index = new_flag_index
    _on_flag_index_set()


# virtual
func _on_flag_index_set() -> void:
    pass


# virtual
func _on_flag_set() -> void:
    pass


func _get_flag(dialogue: Dialogue) -> DialogueFlag:
    return _get_flags(dialogue)[flag_index]
