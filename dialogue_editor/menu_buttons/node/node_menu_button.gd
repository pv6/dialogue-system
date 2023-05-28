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


func _ready() -> void:
    _add_button("Insert Child Hear Node", "insert_child_hear_node", KEY_A)
    _add_button("Insert Child Say Node", "insert_child_say_node", KEY_A, false, false, true)
    _add_button("Insert Parent Hear Node", "insert_parent_hear_node", KEY_A, false, true)
    _add_button("Insert Parent Say Node", "insert_parent_say_node", KEY_A, false, true, true)

    _popup.add_separator()

    _add_button("Move Selected Nodes Up", "move_selected_nodes_up", KEY_UP, true)
    _add_button("Move Selected Nodes Down", "move_selected_nodes_down", KEY_DOWN, true)

    _popup.add_separator()

    _add_button("Copy Selected Nodes", "copy_selected_nodes", KEY_C, true)
    _add_button("Cut Selected Nodes", "cut_selected_nodes", KEY_X, true)
    _add_button("Paste Nodes", "paste_nodes", KEY_V, true)
    _add_button("Paste Cut Nodes With Children", "paste_cut_nodes_with_children", KEY_V, false, false, true)
    _add_button("Paste Cut Node As Parent", "paste_cut_node_as_parent", KEY_V, false, true)
    _add_button("Paste Cut Node With Children As Parent", "paste_cut_node_with_children_as_parent", KEY_V, false, true, true)

    _popup.add_separator()

    _add_button("Shallow Duplicate Selected Nodes", "shallow_duplicate_selected_nodes", KEY_D, true)
    _add_button("Deep Duplicate Selected Nodes", "deep_duplicate_selected_nodes", KEY_D, true, true)

    _popup.add_separator()

    _add_button("Shallow Delete Selected Nodes", "shallow_delete_selected_nodes", KEY_DELETE)
    _add_button("Deep Delete Selected Nodes", "deep_delete_selected_nodes", KEY_DELETE, false, true)
