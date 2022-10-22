tool
class_name DialoguePlayer
extends Reference


signal playback_started()
signal playback_ended()


var _actors: StorageImplementation
var _blackboards: StorageImplementation

var _dialogue: Dialogue
var _cur_node: DialogueNode setget _set_cur_node

var _expression := Expression.new()
var _base_instance


func play(dialogue: Dialogue, actors: StorageImplementation,
          blackboards: StorageImplementation, script_base_instance = null) -> void:
    _dialogue = dialogue
    _actors = actors
    _blackboards = blackboards

    assert(_is_actors_valid())
    assert(_is_blackboards_valid())

    _base_instance = script_base_instance

    self._cur_node = dialogue.root_node

    emit_signal("playback_started")


func stop() -> void:
    emit_signal("playback_ended")


func hear() -> HearDialogueNode:
    if not _cur_node:
        return null

    # find first valid child node
    for next_node in _get_valid_children(_cur_node.children):
        if next_node is HearDialogueNode:
            # first valid node is hear node
            self._cur_node = next_node
            return _translate_text_node(next_node) as HearDialogueNode
        else:
            # first valid node is not hear node
            return null

    # no valid child nodes, dialogue is over
    self._cur_node = null
    return null


func get_say_options() -> Array:
    if not _cur_node:
        return []

    var is_continuous := false
    var output = []
    for next_node in _get_valid_children(_cur_node.children):
        # find continuous valid say child nodes
        # (non-valid say nodes don't break continuation)
        if next_node is SayDialogueNode:
            output.push_back(_translate_text_node(next_node))
            is_continuous = true
        # only stop gathering say nodes, if encountered a valid non-say node
        elif is_continuous:
            break

    return output

    
func can_continue() -> bool:
    return _cur_node and not _cur_node.children.empty()


func say(say_option: SayDialogueNode) -> void:
    assert(_is_say_option_valid(say_option))
    self._cur_node = _dialogue.nodes[say_option.id]


func is_over() -> bool:
    return not _cur_node
    

func get_actor_implementation(actor: StorageItem):
    if not actor or not _actors.has(actor):
        return null
    return _actors.g(actor)


func _get_valid_children(children: Array) -> Array:
    var output = []
    for next_node in children:
        if _is_node_valid(next_node):
            if next_node is ReferenceDialogueNode:
                var referenced_node = _dialogue.nodes[next_node.referenced_node_id]
                if (next_node.jump_to == ReferenceDialogueNode.JumpTo.START_OF_NODE and
                        not referenced_node is RootDialogueNode):
                    output.push_back(referenced_node)
                else:
                    assert(not next_node in referenced_node.children)
                    output.append_array(_get_valid_children(referenced_node.children))
            else:
                output.push_back(next_node)
    return output


func _is_say_option_valid(say_node: SayDialogueNode) -> bool:
    for option in get_say_options():
        if say_node.id == option.id and _is_node_valid(say_node):
            return true
    return false


static func _multisplit(string: String, delimiters: PoolStringArray) -> PoolStringArray:
    var tokens := PoolStringArray([string])

    for d in delimiters:
        var new_tokens := PoolStringArray()
        for t in tokens:
            new_tokens += t.split(d)
        tokens = new_tokens

    return tokens


func _translate_text_node(node: TextDialogueNode) -> TextDialogueNode:
    var output := node.duplicate() as TextDialogueNode
    var translated_text := tr(output.text)

    # find bracketed code snippets
    var compiled_text := ""
    var tokens := _multisplit(translated_text, ["{", "}"])
    for i in range(len(tokens)):
        if i % 2 == 0:  # regular text
            compiled_text += tokens[i]
        else:  # code snippet
            compiled_text += tr(str(_execute_script(tokens[i])))

    output.text = compiled_text
    return output


func _set_cur_node(new_cur_node: DialogueNode) -> void:
    _cur_node = new_cur_node
    if _cur_node:
        _do_node_action(_cur_node)


func _do_node_action(node) -> void:
    if node.action_logic.use_flags:
        # set flag values
        for flag in node.action_logic.flags:
            _blackboards.g(flag.blackboard).s(flag, flag.value)
    if node.action_logic.use_script:
        _execute_script(node.action_logic.node_script)


func _execute_script(script: String):
    var blackboard_names = []
    for template in _blackboards.data.keys():
        blackboard_names.push_back(str(template))
    var input_names = _actors.data.keys()
    input_names.append_array(blackboard_names)

    var error = _expression.parse(script, input_names)

    if error != OK:
        print_debug(_expression.get_error_text())
        return false

    var inputs = _actors.data.values()
    inputs.append_array(_blackboards.data.values())
    var result = _expression.execute(inputs, _base_instance)
    if not _expression.has_execute_failed():
        return result

    print_debug("Script execution failed")
    return false


func _is_node_valid(node: DialogueNode) -> bool:
    # for reference nodes, check referenced node validity
    if node is ReferenceDialogueNode:
        return _is_node_valid(_dialogue.nodes[node.referenced_node_id])

    if node.condition_logic.use_flags:
        # check flags
        for flag in node.condition_logic.flags:
            if (flag.blackboard and _blackboards.g(flag.blackboard).g(flag) != flag.value):
                return false
    if node.condition_logic.use_script:
        return bool(_execute_script(node.condition_logic.node_script))
    return true


func _is_actors_valid() -> bool:
    for actor_item in _dialogue.actors.items():
        if not _actors.has(actor_item):
            return false
    return true


func _is_blackboards_valid() -> bool:
    for template_reference in _dialogue.blackboards.items():
        var template: Storage = template_reference.resource
        if not _blackboards.has(template) or not _blackboards.g(template).is_valid(template):
            return false
    return true
