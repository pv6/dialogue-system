tool
extends Control


const DialogueSearcher := preload("res://addons/dialogue_system/dialogue_editor/support/dialogue_searcher.gd")

# Array[DialogueNode]
var _matched_nodes := [] setget _set_matched_nodes
var _current_match_index := -1
var _current_match_node_id := DialogueNode.DUMMY_ID
var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

onready var _query_line_edit: LineEdit = $"%QueryLineEdit"
onready var _match_case_check_box: CheckBox = $"%MatchCaseCheckBox"
onready var _matches_label: Label = $"%MatchesLabel"


func focus_query() -> void:
    _query_line_edit.grab_focus()
    _query_line_edit.select_all()


func search(focus_current_node := true) -> void:
    if not visible:
        return

    # search according to the query
    var searcher := DialogueSearcher.new(_session.dialogue)
    _set_matched_nodes(searcher.find_nodes(_query_line_edit.text, _match_case_check_box.pressed))

    # check if old current_match is in the new result
    var need_select_first := true
    if _current_match_index != -1:
        for i in range(_matched_nodes.size()):
            if _matched_nodes[i].id == _current_match_node_id:
                _set_current_match_index(i, focus_current_node)
                need_select_first = false
                break
    if need_select_first:
        _set_current_match_index(0, focus_current_node)


func select_prev_match() -> void:
    _set_current_match_index(_current_match_index - 1, true)


func select_next_match() -> void:
    _set_current_match_index(_current_match_index + 1, true)


# new_matched_nodes: Array[DialogueNode]
func _set_matched_nodes(new_matched_nodes: Array) -> void:
    _matched_nodes = new_matched_nodes

    _matches_label.text = "%d matches." % _matched_nodes.size()
    if _matched_nodes.empty():
        _matches_label.modulate = Color.red
    else:
        _matches_label.modulate = Color.white


func _set_current_match_index(new_current_match_index: int, focus_current_node : bool) -> void:
    if _matched_nodes.empty():
        _current_match_index = -1
        return

    if new_current_match_index >= _matched_nodes.size():
        new_current_match_index %= _matched_nodes.size()
    elif new_current_match_index < 0:
        new_current_match_index += _matched_nodes.size()
    _current_match_index = new_current_match_index

    var match_node: DialogueNode = _matched_nodes[_current_match_index]
    _current_match_node_id = match_node.id

    if focus_current_node:
        _session.dialogue_editor.focus_nodes([match_node])
        _session.dialogue_editor.select_node(match_node)


func _on_query_line_edit_text_changed(new_text: String):
    search()


func _on_query_line_edit_text_entered(new_text: String):
    select_next_match()


func _on_prev_button_pressed():
    select_prev_match()


func _on_next_button_pressed():
    select_next_match()


func _on_close_button_pressed():
    hide()
    _session.dialogue_editor.focus_graph_renderer()


func _on_match_case_check_box_toggled(button_pressed):
    search()
