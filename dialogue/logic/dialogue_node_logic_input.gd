tool
class_name DialogueNodeLogicInput
extends Reference


var base_instance
var actors: StorageImplementation
var blackboards: StorageImplementation

var _expression := Expression.new()


func execute_script(script_text: String):
    var blackboard_names = []
    for template in blackboards.data.keys():
        blackboard_names.push_back(str(template))
    var input_names = actors.data.keys()
    input_names.append_array(blackboard_names)

    var error = _expression.parse(script_text, input_names)

    if error != OK:
        print_debug(_expression.get_error_text())
        return false

    var inputs = actors.data.values()
    inputs.append_array(blackboards.data.values())
    var result = _expression.execute(inputs, base_instance)
    if not _expression.has_execute_failed():
        return result

    print_debug("Script execution failed")
    return false
