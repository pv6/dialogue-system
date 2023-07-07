tool
extends "base_dialogue_flag_widget.gd"


const DialogueFlagContentsRenderer := preload("dialogue_flag_contents_renderer.gd")
const VALUES := [true, false]

const BLACKBOARD_FLAG_CONTENTS_RENDERER_SCENE := preload("implemented/blackboard_flag/blackboard_flag_contents_renderer.tscn")
const VISITED_NODE_FLAG_CONTENTS_RENDERER_SCENE := preload("implemented/visited_node/visited_node_flag_contents_renderer.tscn")

var _contents: DialogueFlagContentsRenderer

onready var _value_option_button: OptionButton = $ValueContainer/ValueOptionButton


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
    if not _value_option_button:
        return
    if flag:
        _value_option_button.select(0 if flag.value else 1)
    else:
        _value_option_button.select(0)


func _get_flag(dialogue: Dialogue) -> DialogueFlag:
    return _get_flags(dialogue)[flag_index]


func _on_flag_value_selected(value_index: int) -> void:
    _session.dialogue_undo_redo.commit_action("Set Flag Value", self, "_set_flag_value", {"value": VALUES[value_index]})


func _set_flag_value(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    if property == "":
        return null

    _get_flag(dialogue).value = args["value"]
    return dialogue
