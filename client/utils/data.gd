class_name DataUtils

static func load_vivosaur_data(vivosaur_id: String) -> VivosaurInfo:
	return VivosaurInfo.new(load("res://core/data/vivosaurs/%s.tres" % vivosaur_id))
