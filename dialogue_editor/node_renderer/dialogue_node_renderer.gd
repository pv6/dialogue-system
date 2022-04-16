tool
class_name DialogueNodeRenderer
extends GraphNode


const ROOT_NODE_CONTENTS_SCENE = preload("implemented_contents/root_node/root_dialogue_node_contents_renderer.tscn")
const TEXT_NODE_CONTENTS_SCENE = preload("implemented_contents/text_node/text_dialogue_node_contents_renderer.tscn")
const HEAR_NODE_CONTENTS_SCENE = preload("implemented_contents/hear_node/hear_dialogue_node_contents_renderer.tscn")
const REFERENCE_NODE_CONTENTS_SCENE = preload("implemented_contents/reference_node/reference_dialogue_node_contents_renderer.tscn")
const COMMENT_CONTENTS_SCENE = preload("implemented_contents/comment_contents/comment_dialogue_node_contents_renderer.tscn")

export(Resource) var node setget set_node

var contents: DialogueNodeContentsRenderer

var style_manager: DialogueNodeStyleManager = preload("style_manager/style_manager.tres")


func _ready():
    self.node = node


func set_node(new_node: DialogueNode) -> void:
    node = new_node

    if new_node:
        title = new_node.get_name()

    if contents:
        contents.node = null
        remove_child(contents)
        contents.queue_free()
    contents = create_contents(new_node)
    if contents:
        add_child(contents)

    set_style(style_manager.get_style(new_node))

    if node as ReferenceDialogueNode:
        modulate.v *= 0.8

    set_slot(0, true, 0, Color.gray, true, 0, Color.gray)


func set_style(style: DialogueNodeStyle) -> void:
    add_stylebox_override("frame", style.frame_stylebox)
    add_stylebox_override("selectedframe", style.selected_frame_stylebox)


static func create_contents(node) -> DialogueNodeContentsRenderer:
    var contents := CombinedDialogueNodeContentsRenderer.new()

    if node as RootDialogueNode:
        contents.add_child_contents(ROOT_NODE_CONTENTS_SCENE.instance())
    if node as HearDialogueNode:
        contents.add_child_contents(HEAR_NODE_CONTENTS_SCENE.instance())
    if node as TextDialogueNode:
        contents.add_child_contents(TEXT_NODE_CONTENTS_SCENE.instance())
    if node as ReferenceDialogueNode:
        contents.add_child_contents(REFERENCE_NODE_CONTENTS_SCENE.instance())
    else:
        contents.add_child_contents(COMMENT_CONTENTS_SCENE.instance())

    contents.node = node
    return contents
