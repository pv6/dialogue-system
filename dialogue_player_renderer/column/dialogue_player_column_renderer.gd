extends "res://addons/dialogue_system/dialogue_player_renderer/dialogue_player_renderer.gd"


const ColumnNodeRenderer := preload("res://addons/dialogue_system/dialogue_player_renderer/column/node_renderer/column_node_renderer.gd")
const COLUMN_NODE_RENDERER_SCENE := preload("res://addons/dialogue_system/dialogue_player_renderer/column/node_renderer/column_node_renderer.tscn")

const SayOptionButton := preload("res://addons/dialogue_system/dialogue_player_renderer/column/say_option_button/say_option_button.gd")
const SAY_OPTION_BUTTON_SCENE := preload("res://addons/dialogue_system/dialogue_player_renderer/column/say_option_button/say_option_button.tscn")

export(Color) var player_text_color := Color.lightblue
export(Color) var say_option_color := Color.orangered

onready var _history: VBoxContainer = $ScrollContainer/Column/TextContainer/History
onready var _say_options: VBoxContainer = $ScrollContainer/Column/TextContainer/SayOptions
onready var _continue_button: Control = $ScrollContainer/Column/TextContainer/ContinueButton
onready var _end_button: Control = $ScrollContainer/Column/TextContainer/EndButton

onready var _scroll_container: ScrollContainer = $ScrollContainer
onready var _scroll_tween: Tween = $ScrollTween

onready var _column: VBoxContainer = $ScrollContainer/Column
onready var _top_padding: Control = $ScrollContainer/Column/TopPadding
onready var _bottom_padding: Control = $ScrollContainer/Column/BottomPadding
onready var _text_container: VBoxContainer = $ScrollContainer/Column/TextContainer

onready var _portrait: TextureRect = $Control/Portrait


func _ready():
    start_dialogue()
    

func _clear() -> void:
    _say_options.hide()
    _continue_button.hide()
    _end_button.show()


func _set_continue() -> void:
    _continue_button.show()


func _spawn_say_button(index: int, say_node: SayDialogueNode) -> void:
    var button: SayOptionButton = SAY_OPTION_BUTTON_SCENE.instance()
    button.index = index
    button.text = say_node.text
    button.text_color = say_option_color
    button.connect("pressed", self, "_on_say_option_selected", [say_node])
    
    _say_options.add_child(button)


func _set_say_options(say_options: Array) -> void:
    _continue_button.hide()
    _say_options.show()
    ._set_say_options(say_options)
    _scroll_down()


func _set_hear_node(hear_node: HearDialogueNode) -> void:
    var actor = _dialogue_player.get_actor_implementation(hear_node.speaker)
    if actor and "portrait" in actor:
        _portrait.texture = actor.portrait
    else:
        _portrait.texture = null
    
    var node_renderer: ColumnNodeRenderer = COLUMN_NODE_RENDERER_SCENE.instance()
    node_renderer.speaker = _dialogue_player.get_actor_implementation(hear_node.speaker)
    node_renderer.node_text = hear_node.text
    _history.add_child(node_renderer)
    _scroll_down()


func _scroll_down() -> void:
    # scroll down
    yield(get_tree(), "idle_frame")
    var target_scroll = (_top_padding.rect_size.y + _text_container.rect_size.y) - (_scroll_container.rect_size.y - 30)
    if _scroll_container.scroll_vertical < target_scroll:
        _scroll_tween.interpolate_property(_scroll_container, "scroll_vertical",
                                        _scroll_container.scroll_vertical,
                                        target_scroll, 0.30)
        _scroll_tween.start()


func _on_say_option_selected(say_node: SayDialogueNode) -> void:
    # clear previous hear node
    _clear_current_node()
    
    # save selected say option into history
    var node_renderer: ColumnNodeRenderer = COLUMN_NODE_RENDERER_SCENE.instance()
    node_renderer.speaker = _dialogue_player.get_actor_implementation(say_node.speaker)
    node_renderer.node_text = say_node.text
    node_renderer.text_color = player_text_color
    _history.add_child(node_renderer)

    ._on_say_option_selected(say_node)


func _clear_current_node() -> void:
    if _history.get_child_count() > 0:
        _history.get_child(_history.get_child_count() - 1).is_history = true
    _say_options.hide()
    _continue_button.hide()
    _end_button.hide()
    


func _clear_say_options() -> void:
    for option in _say_options.get_children():
        option.queue_free()


func _on_continue_button_pressed():
    _set_next_node()


func _on_end_button_pressed():
    start_dialogue()
