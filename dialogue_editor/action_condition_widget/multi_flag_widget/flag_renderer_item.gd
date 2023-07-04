tool
extends DisableableControl


const DialogueFlagRenderer := preload("../flag_renderer/dialogue_flag_renderer.gd")

onready var flag_renderer: DialogueFlagRenderer = $DialogueFlagRenderer
onready var remove_button: IconButton = $RemoveButton
