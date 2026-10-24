class_name Formation

const BASE_FP_RECHARGE: int = 180
const MAX_FP: int = 500
const FP_GAIN_AFTER_KNOCKOUT: int = BASE_FP_RECHARGE * 2

# Vivosaur | null
var vivosaurs: Array[VivosaurState]
var fp: int
var turns_left_in_ez: int

func _init(_az: VivosaurState, _sz1: VivosaurState = null, _sz2: VivosaurState = null) -> void:
	vivosaurs = [_az, _sz1, _sz2, null]
	fp = 0
	turns_left_in_ez = 0
