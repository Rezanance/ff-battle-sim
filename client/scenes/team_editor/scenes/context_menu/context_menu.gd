extends PopupMenu
class_name ContextMenu

var menu_items: Array[MenuItem]

class MenuItem:
	var name: String
	var can_show: Callable
	var action: Callable
	
	func _init(_name: String, _can_show: Callable, _action: Callable) -> void:
		name = _name
		can_show = _can_show
		action = _action

func init(_menu_items: Array[MenuItem]) -> void:
	menu_items = _menu_items
	
func _on_id_pressed(context_menu_id: int) -> void:
	menu_items[context_menu_id].action.call()

func show_menu(
	mouse_position: Vector2, 
	medal_btn: MedalBtn
) -> void:
	clear()
	var id: int = 0
	for item: MenuItem in menu_items:
		if item.can_show.call(medal_btn):
			add_item(item.name, id)
		id += 1
	position = mouse_position
	visible = true
