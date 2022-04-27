tool
extends MyMenuButton


signal insert_child_hear_node()
signal insert_child_say_node()
signal insert_parent_hear_node()
signal copy_selected_nodes()
signal paste_nodes()
signal shallow_dublicate_selected_nodes()
signal deep_dublicate_selected_nodes()
signal shallow_delete_selected_nodes()
signal deep_delete_selected_nodes()


func _ready() -> void:
    _add_button("Insert Child Hear Node", "insert_child_hear_node", KEY_INSERT)
    _add_button("Insert Child Say Node", "insert_child_say_node", KEY_INSERT, true)
    _add_button("Insert Parent Hear Node", "insert_parent_hear_node", KEY_INSERT, false, true)

    _popup.add_separator()

    _add_button("Copy Selected Nodes", "copy_selected_nodes", KEY_C, true)
    _add_button("Paste Nodes", "paste_nodes", KEY_V, true)

    _popup.add_separator()

    _add_button("Shallow Dublicate Selected Nodes", "shallow_dublicate_selected_nodes", KEY_D, true)
    _add_button("Deep Dublicate Selected Nodes", "deep_dublicate_selected_nodes", KEY_DELETE, true, true)

    _popup.add_separator()

    _add_button("Shallow Delete Selected Nodes", "shallow_delete_selected_nodes", KEY_DELETE)
    _add_button("Deep Delete Selected Nodes", "deep_delete_selected_nodes", KEY_DELETE, false, true)
