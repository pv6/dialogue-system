tool
extends "dialogue_node_packer.gd"


const TEXT_FIELD := "text"
const SPEAKER_FIELD := "speaker"
const LISTENER_FIELD := "listener"
const TAGS_FIELD := "tags"


# virtual
func pack(object: Object):
    var text_node := object as TextDialogueNode
    assert(text_node)

    var output = .pack(text_node)

    output[TEXT_FIELD] = text_node.text

    output[SPEAKER_FIELD] = _meta_packer.pack(text_node.speaker)
    output[LISTENER_FIELD] = _meta_packer.pack(text_node.listener)
    output[TAGS_FIELD] = _meta_packer.pack(text_node.tags)

    return output
