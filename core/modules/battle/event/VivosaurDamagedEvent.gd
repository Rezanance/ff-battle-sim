class_name VivosaurDamagedEvent

var damage: int
var player_id: int
var zone: Formation.Zone
var is_critical_hit: bool

func _init(_damage: int, _player_id: int, _zone: Formation.Zone, _is_critical_hit: bool) -> void:
    damage = _damage
    player_id = _player_id
    zone = _zone
    is_critical_hit = _is_critical_hit

func serialize() -> Dictionary[String, Variant]:
    return {
        'damage': damage,
		'player_id': player_id,
        'zone': zone,
        'is_critical_hit': is_critical_hit,
	}

static func deserialize(event_dict: Dictionary[String, Variant]) -> VivosaurDamagedEvent:
    return VivosaurDamagedEvent.new(
		event_dict['damage'],
		event_dict['player_id'],
		event_dict['zone'],
		event_dict['is_critical_hit'],
	)
