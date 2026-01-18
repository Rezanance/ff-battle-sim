extends Panel


enum MessageType {SUCCESS, ERROR}

func reveal_dialog(message_type: MessageType, message: String) -> void:
	var style_box_flat: StyleBoxFlat = theme.get_stylebox('panel', 'Panel').duplicate()

	var icon: String
	if message_type == MessageType.SUCCESS:
		style_box_flat.bg_color = Color.hex(0xc8ffddc8)
		icon = "res://client/assets/dialog_popups/green-checkmark.png"
	else:
		style_box_flat.bg_color = Color.hex(0xfdebe9c8)
		icon = "res://client/assets/dialog_popups/red-error.png"
	
	add_theme_stylebox_override('panel', style_box_flat)

	$RichTextLabel.text = "[img=48,center,center]%s[/img]  	[b]%s[/b]" % [icon, message]
	$AnimationPlayer.play("reveal_dialog")
