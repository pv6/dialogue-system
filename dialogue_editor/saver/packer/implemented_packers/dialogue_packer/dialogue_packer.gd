tool
extends ObjectPacker


const ROOT_NODE_FIELD = "root_node"
const DESCRIPTION_FIELD = "description"
const LOCAL_BLACKBOARD_FIELD = "local_blackboard"
const ACTORS_FIELD = "actors"
const BLACKBOARDS_FIELD = "blackboards"
const MAX_ID_FIELD = "max_id"
const EDITOR_VERSION_FIELD = "editor_version"


# virtual
func get_type_name() -> String:
    return "Dialogue"


# virtual
func pack(object: Object):
    var dialogue := object as Dialogue
    assert(dialogue)

    var output = .pack(dialogue)

    output[ROOT_NODE_FIELD] = _meta_packer.pack(dialogue.root_node)
    output[DESCRIPTION_FIELD] = dialogue.description

    output[LOCAL_BLACKBOARD_FIELD] = _meta_packer.pack(dialogue._local_blackboard_ref.resource)

    output[ACTORS_FIELD] = _meta_packer.pack(dialogue.actors)
    output[BLACKBOARDS_FIELD] = _meta_packer.pack(dialogue.blackboards)

    output[MAX_ID_FIELD] = str(dialogue.max_id)
    output[EDITOR_VERSION_FIELD] = dialogue.editor_version

    return output
