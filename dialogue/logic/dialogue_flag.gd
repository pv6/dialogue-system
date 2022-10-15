tool
class_name DialogueFlag
extends Resource


# StorageItem that points to field within blackboard
export(Resource) var blackboard_field: Resource setget set_blackboard_field
export(bool) var value := true setget set_value

var name: String setget ,get_name
var field_id: int setget set_field_id, get_field_id
var blackboard: ResourceReference setget set_blackboard, get_blackboard


func _to_string() -> String:
    if blackboard_field:
        return str(blackboard_field)
    return ""


func set_blackboard_field(new_blackboard_field: StorageItem) -> void:
    if new_blackboard_field == blackboard_field:
        return

    if blackboard_field:
        blackboard_field.disconnect("changed", self, "emit_changed")
    blackboard_field = new_blackboard_field
    if blackboard_field:
        blackboard_field.connect("changed", self, "emit_changed")

    emit_changed()


func set_value(new_value: bool) -> void:
    if value == new_value:
        return
    value = new_value
    emit_changed()


func set_field_id(new_field_id: int) -> void:
    if blackboard_field:
        blackboard_field.storage_id = new_field_id


func get_field_id() -> int:
    if blackboard_field:
        return blackboard_field.storage_id
    return -1


func get_name() -> String:
    if blackboard_field:
        return blackboard_field.value
    return ""


func set_blackboard(new_blackboard: ResourceReference) -> void:
    if not blackboard_field:
        self.blackboard_field = StorageItem.new(new_blackboard)
    else:   
        # reset field field_id to -1 if assigned a new blackboard
        if not new_blackboard.equals(blackboard_field.storage_reference):
            self.field_id = -1
        blackboard_field.storage_reference = new_blackboard


func get_blackboard() -> ResourceReference:
    if blackboard_field:
        return blackboard_field.storage_reference
    return null


func clone() -> DialogueFlag:
    var copy: DialogueFlag = duplicate()
    
    if blackboard_field:
        copy.blackboard_field = blackboard_field.clone()
    
    return copy
