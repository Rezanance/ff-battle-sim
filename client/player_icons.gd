extends OptionButton


func _ready() -> void:
	add_icon_options()
	ClientServerConnectionOUT.player_connecting.connect(_on_player_connecting)
	ClientServerConnectionOUT.player_connect_failed.connect(_on_player_disconnected)

func _on_player_connecting() -> void:
	disabled = true
	
func add_icon_options(path: String = 'res://client/assets/player-icons') -> void:
	var icon_files: PackedStringArray = ResourceLoader.list_directory(path)
	for i: int in range(len(icon_files)):
		var file: String = icon_files[i]
		if file.ends_with('.png'):
			add_icon_item(load(path + '/' + file), '', i)

func _on_player_disconnected() -> void:
	disabled = false
