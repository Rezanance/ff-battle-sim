extends Node

enum UI_STEP {SELECT_SKILL, CHOOSE_TARGET, WAIT_FOR_RESULT, WAIT_FOR_OPPONENT}

var formations: Dictionary[int, Formation] = {
	123: Formation.new(
		Vivosaur.new(123, DataLoader.load_vivosaur_info("Trex")),
		Vivosaur.new(123, DataLoader.load_vivosaur_info("Brachio")),
		Vivosaur.new(123, DataLoader.load_vivosaur_info("Mammoth")),
	),
	456: Formation.new(
		Vivosaur.new(456, DataLoader.load_vivosaur_info("Mammoth")),
		null,
		null
	)
}

var previous_selection: VivosaurSelection
var current_selection: VivosaurSelection

var target: VivosaurSprite
var ui_step: UI_STEP = UI_STEP.WAIT_FOR_OPPONENT