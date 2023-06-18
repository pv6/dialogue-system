tool
class_name DialogueNodeLogic
extends Clonable


# Array[DialogueFlag]
export(Array) var flags setget set_flags
# Array[DialogueFlag]
export(Array) var auto_flags setget set_auto_flags
export(String) var node_script := "" setget set_node_script
export(bool) var use_flags := true setget set_use_flags
export(bool) var use_script := false setget set_use_script


func set_flags(new_flags: Array) -> void:
    if new_flags != flags:
        flags = new_flags
        emit_changed()


func set_auto_flags(new_auto_flags: Array) -> void:
    if new_auto_flags != auto_flags:
        auto_flags = new_auto_flags
        emit_changed()


func set_node_script(new_node_script: String) -> void:
    if new_node_script != node_script:
        node_script = new_node_script
        emit_changed()


func set_use_flags(new_use_flags: bool) -> void:
    if new_use_flags != use_flags:
        use_flags = new_use_flags
        emit_changed()


func set_use_script(new_use_script: bool) -> void:
    if new_use_script != use_script:
        use_script = new_use_script
        emit_changed()


func clone() -> Clonable:
    var copy := duplicate() as DialogueNodeLogic

    var flags_copy = []
    for flag in flags:
        flags_copy.push_back(flag.clone())
    # set directly to trigger setter function (only once)
    copy.flags = flags_copy

    return copy


func check(input: DialogueNodeLogicInput) -> bool:
    # check auto-flags
    for flag in auto_flags:
        if not flag.check(input):
            return false

    # check flags
    if use_flags:
        for flag in flags:
            if not flag.check(input):
                return false

    # check script
    if use_script:
        return bool(input.execute_script(node_script))

    return true


func do_action(input: DialogueNodeLogicInput) -> void:
    for auto_flag in auto_flags:
        assert(auto_flag is ActionableDialogueFlag)
        auto_flag.do_action(input)

    if use_flags:
        for flag in flags:
            assert(flag is ActionableDialogueFlag)
            flag.do_action(input)
    if use_script:
        input.execute_script(node_script)
