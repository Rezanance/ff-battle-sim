class_name VivosaurDamagedEvent

var damage: int
var current_lp_percent: float
var player_id: int
var zone: Formation.Zone
var is_critical_hit: bool

func _init(_damage: int, _current_lp_percent: float, _player_id: int, _zone: Formation.Zone, _is_critical_hit: bool) -> void:
    damage = _damage
    current_lp_percent = _current_lp_percent
    player_id = _player_id
    zone = _zone
    is_critical_hit = _is_critical_hit

func serialize() -> Dictionary[String, Variant]:
    return {
        'damage': damage,
        'current_lp_percent': current_lp_percent,
		'player_id': player_id,
        'zone': zone,
        'is_critical_hit': is_critical_hit,
	}

static func deserialize(event_dict: Dictionary[String, Variant]) -> VivosaurDamagedEvent:
    return VivosaurDamagedEvent.new(
		event_dict['damage'],
		event_dict['current_lp_percent'],
		event_dict['player_id'],
		event_dict['zone'],
		event_dict['is_critical_hit'],
	)
