class_name Effect

enum EffectParam {
	CHANCE, LP, STATUS,
}

var id: String
var parameters: Dictionary[EffectParam, Variant]

func _init(effect_res: SkillEffectResource) -> void:
	for required_param: EffectParam in effect_res.effect.required_params:
		assert(effect_res.params.has(required_param), 'Missing required param')
	
	id = effect_res.resource_name
	parameters = effect_res.params