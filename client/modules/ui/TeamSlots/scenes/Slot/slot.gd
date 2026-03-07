class_name Slot extends AnimatedSprite2D

signal slot_clicked()

## MedalBtn | null
var medal_btn: Variant

func _ready() -> void:
	hide()
	play()
	
func _on_button_pressed() -> void:
	slot_clicked.emit()
