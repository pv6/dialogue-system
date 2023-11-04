tool
class_name DialogueEditorProject
extends Resource


# Storage
export(Resource) var actors: Resource setget set_actors
export(Resource) var tags: Resource setget set_tags


func set_actors(new_actors: Storage) -> void:
    if actors != new_actors:
        actors = new_actors
        emit_changed()


func set_tags(new_tags: Storage) -> void:
    if tags != new_tags:
        tags = new_tags
        emit_changed()
