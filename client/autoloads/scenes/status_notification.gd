extends Panel

func push(status_icon_path: String, bg_color: Color, message: String) -> void:
	var style_box_flat: StyleBoxFlat = theme.get_stylebox('panel', 'Panel').duplicate()
	style_box_flat.bg_color = bg_color
	add_theme_stylebox_override('panel', style_box_flat)
	$RichTextLabel.text = "[img=48,center,center]%s[/img]  	[b]%s[/b]" % [status_icon_path, message]
	$AnimationPlayer.play("push")
