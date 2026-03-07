extends Node
class_name StatusNotificationComponent

@export_category("Success")
@export_file var success_icon_path: String = "res://client/assets/notification_icons/green-checkmark.png"
@export var success_bg_color: Color = Color.hex(0xc8ffddc8)
@export var success_messages: Dictionary[String, String] = {'default': 'Success!'}

@export_category("Error")
@export_file var error_icon_path: String = "res://client/assets/notification_icons/red-error.png"
@export var error_bg_color: Color = Color.hex(0xfdebe9c8)
@export var error_messages: Dictionary[String, String] = {'default': 'Error'}

func push(status: Error, key: String = 'default', message_args: Variant = null) -> void:
	if status == OK:
		StatusNotification.push(
			success_icon_path,
			success_bg_color,
			success_messages[key] % message_args if message_args != null else success_messages[key],
		)
		return
	var message: String = error_messages[key] % [message_args] if message_args != null else error_messages[key]
	StatusNotification.push(
		error_icon_path, 
		error_bg_color,
		'%s (error code = %d)' % [message, status]
	)
