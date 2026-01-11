extends Resource
class_name StatusResource

@export var name: String
@export var is_negative: bool
@export var description: String
@export_range(1, 5) var turns_active: int
@export var icon: Texture
