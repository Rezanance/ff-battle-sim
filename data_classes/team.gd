class_name Team

enum Zone {AZ, SZ1, SZ2, EXTRA1, EXTRA2}
const TEAM_SLOTS: int = 5

var uuid: String
var name: String
# String | null
var slots: Array[Variant]
	
func _init(_uuid: String = '', _name: String = '', _slots: Array[Variant] = []) -> void:
	uuid = _uuid
	name = _name
	
	if len(_slots) != TEAM_SLOTS:
		slots = [null, null, null, null, null]
	else:
		slots = _slots

func is_valid() -> bool:
	assert(len(slots) == TEAM_SLOTS)
	
	return slots[0] != null

func shuffle() -> void:
	slots.shuffle()

func serialize() -> Dictionary:
	return {
		'uuid': uuid,
		'name': name,
		'slots': slots
	}


static func deserialize(team_info: Dictionary) -> Team:
	return Team.new(
		team_info['uuid'],
		team_info['name'],
		team_info['slots'],
	)
