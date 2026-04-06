extends Node

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
