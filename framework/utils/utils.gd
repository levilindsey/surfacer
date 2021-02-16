extends Node

const GROUP_NAME_HUMAN_PLAYERS := "human_players"
const GROUP_NAME_COMPUTER_PLAYERS := "computer_players"
const GROUP_NAME_SURFACES := "surfaces"
const GROUP_NAME_SQUIRREL_DESTINATIONS := "squirrel_destinations"

static func error( \
        message := "An error occurred", \
        should_assert := true):
    push_error("ERROR: %s" % message)
    if should_assert:
        assert(false)

static func warning(message := "An warning occurred"):
    push_warning("WARNING: %s" % message)

# TODO: Replace this with any built-in feature whenever it exists
#       (https://github.com/godotengine/godot/issues/4715).
static func subarray( \
        array: Array, \
        start: int, \
        length := -1) -> Array:
    if length < 0:
        length = array.size() - start
    var result := []
    result.resize(length)
    for i in range(length):
        result[i] = array[start + i]
    return result

# TODO: Replace this with any built-in feature whenever it exists
#       (https://github.com/godotengine/godot/issues/4715).
static func sub_pool_vector2_array( \
        array: PoolVector2Array, \
        start: int, \
        length := -1) -> PoolVector2Array:
    if length < 0:
        length = array.size() - start
    var result := PoolVector2Array()
    result.resize(length)
    for i in range(length):
        result[i] = array[start + i]
    return result

# TODO: Replace this with any built-in feature whenever it exists
#       (https://github.com/godotengine/godot/issues/4715).
static func concat( \
        result: Array, \
        other: Array) -> void:
    var old_result_size := result.size()
    var other_size := other.size()
    result.resize(old_result_size + other_size)
    for i in range(other_size):
        result[old_result_size + i] = other[i]

static func array_to_set(array: Array) -> Dictionary:
    var set := {}
    for element in array:
        set[element] = element
    return set

static func translate_polyline( \
        vertices: PoolVector2Array, \
        translation: Vector2) \
        -> PoolVector2Array:
    var result := PoolVector2Array()
    result.resize(vertices.size())
    for i in range(vertices.size()):
        result[i] = vertices[i] + translation
    return result

static func get_children_by_type( \
        parent: Node, \
        type, \
        recursive := false) -> Array:
    var result = []
    for child in parent.get_children():
        if child is type:
            result.push_back(child)
        if recursive:
            get_children_by_type( \
                    child, \
                    type, \
                    recursive)
    return result

static func get_which_wall_collided_for_body(body: KinematicBody2D) -> int:
    if body.is_on_wall():
        for i in range(body.get_slide_count()):
            var collision := body.get_slide_collision(i)
            var side := get_which_surface_side_collided(collision)
            if side == SurfaceSide.LEFT_WALL or side == SurfaceSide.RIGHT_WALL:
                return side
    return SurfaceSide.NONE

static func get_which_surface_side_collided( \
        collision: KinematicCollision2D) -> int:
    if abs(collision.normal.angle_to(Geometry.UP)) <= \
            Geometry.FLOOR_MAX_ANGLE:
        return SurfaceSide.FLOOR
    elif abs(collision.normal.angle_to(Geometry.DOWN)) <= \
            Geometry.FLOOR_MAX_ANGLE:
        return SurfaceSide.CEILING
    elif collision.normal.x > 0:
        return SurfaceSide.LEFT_WALL
    else:
        return SurfaceSide.RIGHT_WALL

static func get_floor_friction_multiplier(body: KinematicBody2D) -> float:
    var collision := _get_floor_collision(body)
    # Collision friction is a property of the TileMap node.
    if collision != null and collision.collider.collision_friction != null:
        return collision.collider.collision_friction
    return 0.0

static func _get_floor_collision( \
        body: KinematicBody2D) -> KinematicCollision2D:
    if body.is_on_floor():
        for i in range(body.get_slide_count()):
            var collision := body.get_slide_collision(i)
            if abs(collision.normal.angle_to(Geometry.UP)) <= \
                    Geometry.FLOOR_MAX_ANGLE:
                return collision
    return null

static func add_scene( \
        parent: Node, \
        resource_path: String, \
        is_attached := true, \
        is_visible := true) -> Node:
    var scene := load(resource_path)
    var node: Node = scene.instance()
    if node is CanvasItem:
        node.visible = is_visible
    if is_attached:
        parent.add_child(node)
    return node

static func get_global_touch_position(input_event: InputEvent) -> Vector2:
    return Global.current_level.make_input_local(input_event).position
