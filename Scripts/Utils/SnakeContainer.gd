extends Container
class_name SnakeContainer

@export var columns: int = 5
@export var separation: Vector2 = Vector2(8, 8)

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		_arrange_children()

func _arrange_children() -> void:
	var children := get_children()
	if children.is_empty() or columns <= 0:
		return

	var current_y := 0.0
	var row_index := 0
	var index := 0

	while index < children.size():
		var row: Array[Control] = []
		var row_width := 0.0
		var max_height := 0.0

		for i in range(columns):
			if index >= children.size():
				break
			var child := children[index]
			index += 1
			if child is not Control:
				continue
			var c := child as Control
			var size := c.get_combined_minimum_size()
			row.append(c)
			row_width += size.x
			if i > 0:
				row_width += separation.x
			max_height = max(max_height, size.y)

		var reverse := (row_index % 2) == 1
		var current_x := row_width if reverse else 0.0

		for child in row:
			var size := child.get_combined_minimum_size()
			if reverse:
				current_x -= size.x
			fit_child_in_rect(child, Rect2(current_x, current_y, size.x, size.y))
			if not reverse:
				current_x += size.x + separation.x
			else:
				current_x -= separation.x

		current_y += max_height + separation.y
		row_index += 1

func _get_minimum_size() -> Vector2:
	return Vector2.ZERO
