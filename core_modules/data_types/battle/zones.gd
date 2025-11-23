class_name Zones


enum Zone {AZ, SZ1, SZ2, EZ}
enum SupportZone {SZ1, SZ2}
const BASE_FP_RECHARGE = 180
const MAX_FP = 500
const FP_GAIN_AFTER_KNOCKOUT = BASE_FP_RECHARGE * 2

class AZSupportEffects:
	var atk: float
	var def: float
	var acc: float
	var eva: float

	func _init() -> void:
		atk = 0
		def = 0
		acc = 0
		eva = 0
		
# VivosaurBattle | null
var az: VivosaurBattle
var sz1: VivosaurBattle
var sz2: VivosaurBattle
var ez: VivosaurBattle
# TextureButton | null
var az_sprite_btn: TextureButton
var sz1_sprite_btn: TextureButton
var sz2_sprite_btn: TextureButton
var ez_sprite_btn: TextureButton

var fp: int

var az_support_effects: AZSupportEffects

func _init(_az: VivosaurBattle, _sz1: VivosaurBattle, _sz2: VivosaurBattle) -> void:
	az = _az
	az_sprite_btn = null
	sz1 = _sz1
	sz1_sprite_btn = null
	sz2 = _sz2
	sz2_sprite_btn = null
	ez = null
	ez_sprite_btn = null

	fp = 0

	az_support_effects = AZSupportEffects.new()

func get_sz_vivosaurs() -> Array:
	return [sz1, sz2]

func get_support_zones_sprite_btns() -> Array:
	return [sz1_sprite_btn, sz2_sprite_btn]

func get_total_lp():
	var az_lp = az.get('current_lp') if az != null else 0
	var sz1_lp = sz1.get('current_lp') if sz1 != null else 0
	var sz2_lp = sz2.get('current_lp') if sz2 != null else 0

	return az_lp + sz1_lp + sz2_lp

func recharge_fp():
	if fp + BASE_FP_RECHARGE > MAX_FP:
		fp += MAX_FP - fp
	else:
		fp += BASE_FP_RECHARGE

func get_vivosaur_zone(vivo: VivosaurBattle) -> Zone:
	var az_id = az.get('vivosaur_info').get('id')
	var sz1_id = sz1.get('vivosaur_info').get('id')
	var sz2_id = sz2.get('vivosaur_info').get('id')

	match vivo.vivosaur_info.id:
		az_id:
			return Zone.AZ
		sz1_id:
			return Zone.SZ1
		sz2_id:
			return Zone.SZ2
		_:
			return Zone.EZ
