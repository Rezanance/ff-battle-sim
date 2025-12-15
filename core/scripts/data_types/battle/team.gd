class_name Team


const TEAM_SLOTS = 5

var uuid: String
var name: String
# VivosaurInfo | null
var slots: Array[VivosaurInfo]
	
func _init(_uuid: String, _name: String = '', _slots: Array[VivosaurInfo] = []):
	uuid = _uuid
	name = _name
	
	if len(_slots) != TEAM_SLOTS:
		slots = [null, null, null, null, null]
	else:
		slots = _slots

func is_valid():
	assert(len(slots) == TEAM_SLOTS)
	
	return slots[0] != null

func serialize() -> Dictionary:
	return {
		'name': name,
		'slots': slots_vivosaur_ids()
	}

func slots_vivosaur_ids():
	return slots.map(func(vivosaur): return vivosaur.id if vivosaur != null else null)

static func unserialize(team_uuid: String, team_dict: Dictionary):
	var _slots: Array[VivosaurInfo] = []
	for i in range(TEAM_SLOTS):
		var vivosaur_id = team_dict.slots[i]
		if vivosaur_id != null:
			_slots.append(Constants.fossilary[vivosaur_id])
		else:
			_slots.append(null)
	
	return Team.new(team_uuid, team_dict['name'], _slots)
