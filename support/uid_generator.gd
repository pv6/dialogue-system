tool
class_name UIDGenerator
extends Reference


const DUMMY_ID := -1

var _uniquifier: int
var _session_id: int


func _init() -> void:
    randomize()
    _session_id = randi()
    _uniquifier = randi()


func generate_id() -> int:
    # 64 bit identifier
    # ~70 years worth of identifiers
    # 1 dummy id bit + 31 timestamp bits + 16 uniqifier bits + 16 session bits
    var timestamp := Time.get_unix_time_from_system() as int
    var output := ((timestamp & 0x7FFFFFFF) << 32) + ((_uniquifier & 0xFFFF) << 16) + (_session_id & 0xFFFF)
    _uniquifier += 1
    return output
