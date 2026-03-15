class_name DataLoader

static func load_vivosaur_info(vivosaur_id: Variant) -> VivosaurInfo:
	if vivosaur_id == null:
		return null
	return VivosaurInfo.new(load("res://core/data/vivosaurs/%s.tres" % vivosaur_id))
