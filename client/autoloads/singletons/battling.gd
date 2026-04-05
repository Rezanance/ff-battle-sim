extends Node

var player_formation: Formation = Formation.new(
	Vivosaur.new(123, DataLoader.load_vivosaur_info("Trex")),
	Vivosaur.new(123, DataLoader.load_vivosaur_info("Brachio")),
	Vivosaur.new(123, DataLoader.load_vivosaur_info("Mammoth")),
)
var opponent_formation: Formation = Formation.new(
	Vivosaur.new(456, DataLoader.load_vivosaur_info("Mammoth")),
	null,
	null
)
