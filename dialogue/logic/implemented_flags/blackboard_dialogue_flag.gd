tool
class_name BlackboardDialogueFlag
extends ActionableDialogueFlag


# StorageItem that points to field within blackboard
export(Resource) var blackboard_field: Resource setget set_blackboard_field

var name: String setget set_name, get_name
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


func set_field_id(new_field_id: int) -> void:
    if blackboard_field:
        blackboard_field.storage_id = new_field_id


func get_field_id() -> int:
    if blackboard_field:
        return blackboard_field.storage_id
    return UIDGenerator.DUMMY_ID


func set_name(new_name: String) -> void:
    var blackboard_ref := get_blackboard()
    if not blackboard_ref or not blackboard_ref.resource:
        return
    set_field_id(blackboard_ref.resource.find_item(new_name))


func get_name() -> String:
    return str(self)


func set_blackboard(new_blackboard: ResourceReference) -> void:
    if not blackboard_field:
        self.blackboard_field = StorageItem.new(new_blackboard)
    else:
        # reset field_id to DUMMY_ID if assigned a new blackboard
        if not new_blackboard.equals(blackboard_field.storage_reference):
            self.field_id = UIDGenerator.DUMMY_ID
        blackboard_field.storage_reference = new_blackboard


func get_blackboard() -> ResourceReference:
    if blackboard_field:
        return blackboard_field.storage_reference
    return null


func clone() -> Clonable:
    var copy: BlackboardDialogueFlag = .clone()

    if blackboard_field:
        copy.blackboard_field = blackboard_field.clone()

    return copy


# virtual
func do_action(input: DialogueNodeLogicInput) -> void:
    input.blackboards.g(get_blackboard()).s(self, value)


# virtual
func check(input: DialogueNodeLogicInput) -> bool:
    var blackboard := get_blackboard()
    return blackboard and input.blackboards.g(blackboard).g(self) == value
