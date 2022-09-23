tool
extends DialogueNodeContentsRenderer


export(bool) var has_comment: bool setget set_has_comment

var _session: DialogueEditorSession = preload("res://addons/dialogue_system/dialogue_editor/session.tres")

onready var _add_comment_button: IconButton = $AddCommentButton
onready var _comment_text_edit: TextEdit = $CommentTextEdit


func _update_contents() -> void:
    if not node:
        self.has_comment = false
        return

    if node.comment != "":
        self.has_comment = true

    # don't update text if already has it to avoid caret resetting
    if _comment_text_edit and _comment_text_edit.text != node.comment:
        _comment_text_edit.text = node.comment


func set_has_comment(new_has_comment: bool) -> void:
    has_comment = new_has_comment
    if not _add_comment_button or not _comment_text_edit:
        return
    if has_comment:
        _add_comment_button.hide()
        _comment_text_edit.show()
    else:
        _add_comment_button.show()
        _comment_text_edit.hide()


static func _edit_comment(dialogue: Dialogue, args: Dictionary) -> Dialogue:
    if dialogue.nodes[args["id"]].comment == args["comment"]:
        return null
    dialogue.nodes[args["id"]].comment = args["comment"]
    return dialogue


func _on_add_comment_button_pressed():
    self.has_comment = true


func _on_comment_text_edit_focus_exited():
    call_deferred("_call_edit_comment")


func _call_edit_comment() -> void:
    _session.dialogue_undo_redo.commit_action("Edit Node Comment", self, "_edit_comment",
                                              {"id": node.id, "comment": _comment_text_edit.text})
