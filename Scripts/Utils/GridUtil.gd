extends RefCounted
class_name GridUtil

static func snap_to_grid(pos: Vector2, grid_size: int = 16) -> Vector2:
	var x: float = (floor(pos.x / grid_size) + 0.5) * grid_size
	var y: float = (floor(pos.y / grid_size) + 0.5) * grid_size
	return Vector2(x, y)

static func has_only_platform_at(
	self_body: CollisionObject2D,
	position: Vector2,
	platform_layer_mask: int,
	probe_radius: float = 4.0,
	max_results: int = 16
) -> bool:
	var space := self_body.get_world_2d().direct_space_state
	var circle := CircleShape2D.new()
	circle.radius = probe_radius

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = Transform2D(0.0, position)
	query.collision_mask = 0xFFFFFFFF
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.exclude = [self_body.get_rid()]

	var hits := space.intersect_shape(query, max_results)
	if hits.is_empty():
		return false

	var found_platform := false
	for hit in hits:
		if not hit.has("rid"):
			return false
		var rid: RID = hit["rid"]
		var layers: int = PhysicsServer2D.body_get_collision_layer(rid)
		var has_platform_bit := (layers & platform_layer_mask) != 0
		var has_non_platform_bit := (layers & ~platform_layer_mask) != 0
		if not has_platform_bit or has_non_platform_bit:
			return false
		found_platform = true

	return found_platform
