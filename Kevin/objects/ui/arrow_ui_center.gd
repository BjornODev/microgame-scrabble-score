extends Node2D

var arrow_ui = preload("res://Kevin/objects/ui/arrow_ui.tscn")

var current_index: int = 0
var children = []

func ready_by_parent(arrow_count: int) -> void:
	for i in arrow_count:
		var new_arrow = arrow_ui.instantiate()
		add_child(new_arrow)
		new_arrow.position = Vector2(-i * 32, 0)
		children.append(new_arrow)
	current_index = children.size() - 1
	#children[-1].ready_up()

## Run when the secret target is hit.
func restock() -> void:
	if current_index > -1:
		children[current_index].reset()
	current_index += 1
	children[current_index].reset()
	#current_index = children.size() - 1
	#for child in children:
		#child.reset()

func nock_arrow() -> void:
	if current_index > -1:#!children.is_empty():
		children[current_index].nock()#children[-1].nock()

func shoot_arrow() -> void:
	if current_index > -1:#!children.is_empty():
		children[current_index].fade_out() #children[-1].fade_out()#modulate = Color.DIM_GRAY
		current_index -= 1 #children.pop_at(-1)
	#if !children.is_empty():
		#children[-1].ready_up()
