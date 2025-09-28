extends TextureButton

var fossilary_index: String

@onready var selected_anim = $SelectedAnimation
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selected_anim.play()
