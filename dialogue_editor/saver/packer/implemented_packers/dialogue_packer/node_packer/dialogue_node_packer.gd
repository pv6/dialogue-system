tool
extends ObjectPacker


const ID_FIELD := "id"
const CHILDREN_FIELD := "children"
const COMMENT_FIELD := "comment"
const ACTION_LOGIC_FIELD := "action_logic"
const CONDITION_LOGIC_FIELD := "condition_logic"

export(String) var type := ""


# virtual
func get_type_name() -> String:
    return "%sDialogueNode" % type


# virtual
func pack(object: Object):
    var node := object as DialogueNode
    assert(node)

    var output = {}

    output[ID_FIELD] = str(node.id)

    output[COMMENT_FIELD] = node.comment

    output[ACTION_LOGIC_FIELD] = _meta_packer.pack(node.action_logic)
    output[CONDITION_LOGIC_FIELD] = _meta_packer.pack(node.condition_logic)

    output[CHILDREN_FIELD] = _meta_packer.pack(node.children)

    return output
