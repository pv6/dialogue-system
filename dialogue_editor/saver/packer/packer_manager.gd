tool
class_name PackerManager
extends Resource


# Dictionary[Script, Packer]
export(Dictionary) var packers: Dictionary


func get_packer(object: Reference) -> Packer:
    var object_script: Script = object.get_script()
    if packers.has(object_script):
        return packers[object_script]
    return null
