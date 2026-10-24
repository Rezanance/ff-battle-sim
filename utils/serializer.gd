class_name Serializer

# Assumes all members of obj are serializable types 
static func serialize(obj: RefCounted) -> Dictionary[String, Variant]:
	var dict: Dictionary[String, Variant] = {}
	for prop: Dictionary in obj.get_property_list():
		var field: String = prop['name']
		if field not in ['RefCounted', 'script'] and field.find('.gd') == -1:
			dict[field] = obj[field]
	return dict

static func deserialize(dict: Dictionary[Variant, Variant], ObjClass: GDScript) -> Variant:
	var obj: Variant = ObjClass.new()
	for key: Variant in dict.keys():
		obj[key] = dict[key]
	return obj
