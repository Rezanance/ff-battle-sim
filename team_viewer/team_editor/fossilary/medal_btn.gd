extends TextureButton

var vivosaur_id: int

@onready var selected_anim = $SelectedAnimation
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selected_anim.play()
