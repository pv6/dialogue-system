tool
extends "../saver.gd"


# virtual
func save(object: Object, path: String) -> void:

    var meta_packer := MetaPacker.new()
    var packed_object = meta_packer.pack(object)

    var json_text := JSON.print(packed_object, "    ")
    var error := validate_json(json_text)
    assert(not error)

    var file = File.new()
    file.open("%s.json" % path, File.WRITE)
    file.store_line(json_text)
    file.close()


# virtual
func load(path: String) -> Reference:
    return null
