class_name DataLoader

static func load_vivosaur_info(vivosaur_id: String) -> VivosaurInfo:
	return VivosaurInfo.new(load("res://core/data/vivosaurs/%s.tres" % vivosaur_id))
