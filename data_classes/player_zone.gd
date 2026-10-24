class_name PlayerZone

enum Zone {AZ, SZ1, SZ2, EZ}

var player_id: int
var zone: Zone

func _init(_player_id: int, _zone: Zone) -> void:
    player_id = _player_id
    zone = _zone

func equals(player_zone: PlayerZone) -> bool:
    return (
        self.player_id == player_zone.player_id and
        self.name == player_zone.name
    )