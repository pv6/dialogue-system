tool
extends "dialogue_node_packer.gd"


const JUMP_TO_FIELD := "jump_to"
const JUMP_TO_VALUES := {
    ReferenceDialogueNode.JumpTo.START_OF_NODE: "START_OF_NODE",
    ReferenceDialogueNode.JumpTo.END_OF_NODE: "END_OF_NODE"
}
const REFERENCED_NODE_ID_FIELD := "referenced_node_id"


# virtual
func pack(object: Object):
    var reference_node := object as ReferenceDialogueNode
    assert(reference_node)

    var output = .pack(reference_node)

    output[JUMP_TO_FIELD] = str(reference_node.jump_to)
    output[REFERENCED_NODE_ID_FIELD] = JUMP_TO_VALUES[reference_node.jump_to]

    return output
