tool
extends MyMenuButton


signal insert_child_hear_node()
signal insert_child_say_node()
signal insert_parent_hear_node()
signal insert_parent_say_node()

signal move_selected_nodes_up()
signal move_selected_nodes_down()

signal copy_selected_nodes()
signal cut_selected_nodes()
signal paste_nodes()
signal paste_cut_nodes_with_children()
signal paste_cut_node_as_parent()
signal paste_cut_node_with_children_as_parent()

signal shallow_duplicate_selected_nodes()
signal deep_duplicate_selected_nodes()

signal shallow_delete_selected_nodes()
signal deep_delete_selected_nodes()

signal edit_selected_node_text()
signal unselect_all()


func _ready() -> void:
    add_button("Insert Child Hear Node", "insert_child_hear_node", KEY_A)
    add_button("Insert Child Say Node", "insert_child_say_node", KEY_A, ALT)
    add_button("Insert Parent Hear Node", "insert_parent_hear_node", KEY_A, SHIFT)
    add_button("Insert Parent Say Node", "insert_parent_say_node", KEY_A, SHIFT | ALT)

    add_separator()

    add_button("Move Selected Nodes Up", "move_selected_nodes_up", KEY_UP, CTRL)
    add_button("Move Selected Nodes Down", "move_selected_nodes_down", KEY_DOWN, CTRL)

    add_separator()

    add_button("Copy Selected Nodes", "copy_selected_nodes", KEY_C, CTRL)
    add_button("Cut Selected Nodes", "cut_selected_nodes", KEY_X, CTRL)
    add_button("Paste Nodes", "paste_nodes", KEY_V, CTRL)
    add_button("Paste Cut Nodes With Children", "paste_cut_nodes_with_children", KEY_V, ALT)
    add_button("Paste Cut Node As Parent", "paste_cut_node_as_parent", KEY_V, SHIFT)
    add_button("Paste Cut Node With Children As Parent", "paste_cut_node_with_children_as_parent", KEY_V, CTRL | SHIFT)

    add_separator()

    add_button("Duplicate Selected Nodes", "shallow_duplicate_selected_nodes", KEY_D, CTRL)
    add_button("Duplicate Selected Nodes With Children", "deep_duplicate_selected_nodes", KEY_D, CTRL | SHIFT)

    add_separator()

    add_button("Delete Selected Nodes", "shallow_delete_selected_nodes", KEY_DELETE)
    add_button("Delete Selected Nodes With Children", "deep_delete_selected_nodes", KEY_DELETE, SHIFT)

    add_separator()

    add_button("Edit Selected Node's Text", "edit_selected_node_text", KEY_ENTER)
    add_button("Unselect All", "unselect_all", KEY_ESCAPE)
