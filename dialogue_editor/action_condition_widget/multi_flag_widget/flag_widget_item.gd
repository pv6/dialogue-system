tool
extends DisableableControl


const FlagWidget := preload("../flag_widget/flag_widget.gd")

const BLACKBOARD_FLAG_WIDGET_SCENE := preload("../flag_widget/implemented/blackboard_flag/blackboard_flag_widget.tscn")
const VISITED_NODE_FLAG_WIDGET_SCENE := preload("../flag_widget/implemented/visited_node/visited_node_flag_widget.tscn")

var flag_widget: FlagWidget
onready var remove_button: IconButton = $RemoveButton


func set_flag(flag: DialogueFlag) -> void:
    var flag_widget_scene: PackedScene
    if flag.name.begins_with("auto_visited_node_"):
        flag_widget_scene = VISITED_NODE_FLAG_WIDGET_SCENE
    else:
        flag_widget_scene = BLACKBOARD_FLAG_WIDGET_SCENE
    _set_flag_widget(flag_widget_scene)
    flag_widget.flag = flag


func _set_flag_widget(flag_widget_scene: PackedScene) -> void:
    if flag_widget:
        remove_child(flag_widget)
        flag_widget.queue_free()
    flag_widget = flag_widget_scene.instance()
    add_child(flag_widget)
    move_child(flag_widget, 0)
    flag_widget.disabled = disabled
