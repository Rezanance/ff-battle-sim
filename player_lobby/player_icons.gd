extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_add_icon_options()

func _add_icon_options(path='res://common_assets/player-icons'):
	var icon_dir = DirAccess.open(path)
	var icon_files = icon_dir.get_files()
	for i in range(len(icon_files)):
		var file =  icon_files[i]
		if file.ends_with('.png'):
			add_icon_item(load(path + '/' + file), '', i)
		
	
