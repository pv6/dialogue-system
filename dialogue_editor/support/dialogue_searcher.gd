tool
extends Reference


var dialogue: Dialogue


func _init(dialogue: Dialogue) -> void:
    self.dialogue = dialogue


# return Array[DialogueNode]
func find_nodes(substring: String, match_case: bool) -> Array:
    if not dialogue:
        return []

    var output := []
    for node in dialogue.nodes.values():
        if node is TextDialogueNode:
            var n: int
            if match_case:
                n = node.text.find(substring)
            else:
                n = node.text.findn(substring)
            if n != -1:
                output.append(node)

    return output
