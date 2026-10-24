# Autoload Battling
extends Node

enum UI_STEP {SELECT_ACTION, CHOOSE_SKILL_TARGET, CHOOSE_SWAP_TARGET, WAIT_FOR_SERVER, WAIT_FOR_OPPONENT}

var formations: Dictionary[int, Formation] = {
	123: Formation.new(
		VivosaurState.new(123, VivosaurInfo.load("Trex")),
		VivosaurState.new(123, VivosaurInfo.load("Brachio")),
		VivosaurState.new(123, VivosaurInfo.load("Mammoth")),
	),
	456: Formation.new(
		VivosaurState.new(456, VivosaurInfo.load("Mammoth")),
		null,
		null
	)
}

var selection: VivosaurSelection
var initiator: PlayerZone.Zone
var skill_id_selected: String
var target: VivosaurSelection
var ui_step: UI_STEP = UI_STEP.WAIT_FOR_SERVER