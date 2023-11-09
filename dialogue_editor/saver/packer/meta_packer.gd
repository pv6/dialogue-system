tool
class_name MetaPacker
extends Packer


var _packer_manager: PackerManager


# virtual
func pack(object):
    if object is Object:
        return pack_object(object)

    if object is Array:
        return pack_array(object)

    if object is Dictionary:
        return pack_dictionary(object)

    if object is int:
        return str(object)

    return object


func pack_object(object: Object) -> Dictionary:
    _packer_manager = load("res://addons/dialogue_system/dialogue_editor/saver/packer/packer_data/packer_manager.tres")
    var packer = _packer_manager.get_packer(object)
    if packer:
        return packer.pack(object)
    return pack(object)


func pack_array(array: Array) -> Array:
    var packed := []
    for item in array:
        packed.push_back(pack(item))
    return packed


func pack_dictionary(dictionary: Dictionary) -> Dictionary:
    var packed := {}
    for key in dictionary.keys():
        packed[str(key)] = pack(dictionary[key])
    return packed


func pack_set(set: Dictionary) -> Array:
    var packed := []
    for key in set.keys():
        packed.push_back(str(key))
    return packed
