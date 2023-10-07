tool
extends "base_dialogue_flag_widget.gd"


const DialogueFlagContentsRenderer := preload("dialogue_flag_contents_renderer.gd")

const BLACKBOARD_FLAG_CONTENTS_RENDERER_SCENE := preload("implemented/blackboard_flag/blackboard_flag_contents_renderer.tscn")
const VISITED_NODE_FLAG_CONTENTS_RENDERER_SCENE := preload("implemented/visited_node/visited_node_flag_contents_renderer.tscn")

var _contents: DialogueFlagContentsRenderer

onready var _value_check_box: CheckBox = $ValueContainer/ValueCheckBox


static func create_contents(flag: DialogueFlag) -> DialogueFlagContentsRenderer:
    if flag is BlackboardDialogueFlag:
        return BLACKBOARD_FLAG_CONTENTS_RENDERER_SCENE.instance() as DialogueFlagContentsRenderer
    if flag is VisitedNodeDialogueFlag:
        return VISITED_NODE_FLAG_CONTENTS_RENDERER_SCENE.instance() as DialogueFlagContentsRenderer
    return null


# virtual
func _on_flag_set() -> void:
    if not flag or not _contents or not _contents.flag or flag.get_script() != _contents.flag.get_script():
        if _contents:
            remove_child(_contents)
            _contents.flag = null
            _contents.queue_free()
        _contents = create_contents(flag)
        if _contents:
            add_child(_contents)
            move_child(_contents, 0)

    if _contents:
        _contents.flag = flag
        _contents.property = property
        _contents.node_id = node_id


# virtual
func _on_flag_index_set() -> void:
    if _contents:
        _contents.flag_index = flag_index


# virtual
func _on_property_changed() -> void:
    if _contents:
        _contents.property = property


# virtual
func _on_node_id_changed() -> void:
    if _contents:
        _contents.node_id = node_id


# virtual
func _update_values() -> void:
    if not _value_check_box:
        return
    if flag:
        _value_check_box.pressed = flag.value
    else:
        _value_check_box.pressed = true


func _get_flag(dialogue: Dialogue) -> DialogueFlag:
    return _get_flags(dialogue)[flag_index]


func _on_flag_value_selected(value: bool) -> void:
    _session.dialogue_undo_redo.commit_action("Set Flag Value", self, "_set_flag_value", {"value": value})


func _set_flag_value(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    if property == "" or not flag:
        return null

    _get_flag(dialogue).value = args["value"]
    return dialogue
