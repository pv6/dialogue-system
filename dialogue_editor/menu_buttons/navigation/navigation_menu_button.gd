tool
extends MyMenuButton

signal go_to_node()

signal open_find_widget()

signal focus_selected_nodes()
signal focus_selected_nodes_with_children()

signal zoom_in()
signal zoom_out()


func _ready() -> void:
    add_button("Go To Node...", "go_to_node", KEY_G, CTRL)

    add_separator()

    add_button("Find Node...", "open_find_widget", KEY_F, CTRL)

    add_separator()

    add_button("Focus Selected Nodes", "focus_selected_nodes", KEY_F)
    add_button("Focus Selected Nodes With Children", "focus_selected_nodes_with_children", KEY_F, SHIFT)

    add_separator()

    add_button("Zoom In", "zoom_in", KEY_PLUS, CTRL)
    add_button("Zoom Out", "zoom_out", KEY_MINUS, CTRL)
