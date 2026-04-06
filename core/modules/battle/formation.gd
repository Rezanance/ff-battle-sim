class_name Formation

enum Zone {AZ, SZ1, SZ2, EZ}
const BASE_FP_RECHARGE: int = 180
const MAX_FP: int = 500
const FP_GAIN_AFTER_KNOCKOUT: int = BASE_FP_RECHARGE * 2

class PlayerZone:
	var player_id: int
	var zone: Zone
	
	func _init(_player_id: int, _zone: Zone) -> void:
		player_id = _player_id
		zone = _zone
	
	func equals(player_zone: PlayerZone) -> bool:
		return (
			self.player_id == player_zone.player_id and 
			self.zone == player_zone.zone
		)

# Vivosaur | null
var az: Vivosaur
var sz1: Vivosaur
var sz2: Vivosaur
var ez: Vivosaur

var fp: int

func _init(_az: Vivosaur, _sz1: Vivosaur = null, _sz2: Vivosaur= null) -> void:
	az = _az
	sz1 = _sz1
	sz2 = _sz2
	ez = null
	fp = 0

# Server shouldn't send the whole formation data since it can be computed on client side
# Just for initial formation
func serialize() -> Dictionary[String, Variant]:
	@warning_ignore("incompatible_ternary")
	return {
		'az': az.serialize(),
		'sz1': sz1.serialize() if sz1 else null,
		'sz2': sz2.serialize() if sz2 else null,
	}

static func deserialize(formation_dict: Dictionary[String, Variant]) -> Formation:
	return Formation.new(
		Vivosaur.deserialize(formation_dict['az']),
		Vivosaur.deserialize(formation_dict['sz1']) if formation_dict['sz1'] else null,
		Vivosaur.deserialize(formation_dict['sz2']) if formation_dict['sz2'] else null,
	)

func get_sz_vivosaurs() -> Array[Vivosaur]:
	return [sz1, sz2]

func calculate_total_lp() -> int:
	var az_lp: int = az.get('current_lp') if az != null else 0
	var sz1_lp : int= sz1.get('current_lp') if sz1 != null else 0
	var sz2_lp: int = sz2.get('current_lp') if sz2 != null else 0

	return az_lp + sz1_lp + sz2_lp

func recharge_fp() -> void:
	if fp + BASE_FP_RECHARGE > MAX_FP:
		fp += MAX_FP - fp
	else:
		fp += BASE_FP_RECHARGE

func get_vivosaur_zone(vivo: Vivosaur) -> Zone:
	var az_id: String = az.get('vivosaur_info').get('id')
	var sz1_id: String = sz1.get('vivosaur_info').get('id')
	var sz2_id: String = sz2.get('vivosaur_info').get('id')

	match vivo.vivosaur_info.id:
		az_id:
			return Zone.AZ
		sz1_id:
			return Zone.SZ1
		sz2_id:
			return Zone.SZ2
		_:
			return Zone.EZ

func swap_to_ez(sz_vivosaur: Vivosaur) -> void:
	return
