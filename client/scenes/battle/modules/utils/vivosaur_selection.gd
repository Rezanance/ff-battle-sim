class_name VivosaurSelection

var zone: PlayerZone.Zone
var player_id: int

func _init(_zone: PlayerZone.Zone, _player_id: int) -> void:
	zone = _zone
	player_id = _player_id

func equals(selection: VivosaurSelection) -> bool:
	return self.zone == selection.zone and self.player_id == selection.player_id