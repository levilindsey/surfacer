extends Node
class_name Geometry

const UP := Vector2.UP
const DOWN := Vector2.DOWN
const LEFT := Vector2.LEFT
const RIGHT := Vector2.RIGHT
const FLOOR_MAX_ANGLE := PI / 4.0
const GRAVITY := 5000.0
const FLOAT_EPSILON := 0.00001

# Calculates the minimum squared distance between a line segment and a point.
static func get_distance_squared_from_point_to_segment( \
        point: Vector2, segment_a: Vector2, segment_b: Vector2) -> float:
    var closest_point := get_closest_point_on_segment_to_point(point, segment_a, segment_b)
    return point.distance_squared_to(closest_point)

# Calculates the minimum squared distance between two line segments.
static func get_distance_squared_between_segments( \
        segment_1_a: Vector2, segment_1_b: Vector2, \
        segment_2_a: Vector2, segment_2_b: Vector2) -> float:
    var closest_on_2_to_1_a = \
            get_closest_point_on_segment_to_point(segment_1_a, segment_2_a, segment_2_b)
    var closest_on_2_to_1_b = \
            get_closest_point_on_segment_to_point(segment_1_b, segment_2_a, segment_2_b)
    var closest_on_1_to_2_a = \
            get_closest_point_on_segment_to_point(segment_2_a, segment_1_a, segment_1_b)
    var closest_on_1_to_2_b = \
            get_closest_point_on_segment_to_point(segment_2_a, segment_1_a, segment_1_b)
    
    var distance_squared_from_2_to_1_a = closest_on_2_to_1_a.distance_squared_to(segment_1_a)
    var distance_squared_from_2_to_1_b = closest_on_2_to_1_b.distance_squared_to(segment_1_b)
    var distance_squared_from_1_to_2_a = closest_on_1_to_2_a.distance_squared_to(segment_2_a)
    var distance_squared_from_1_to_2_b = closest_on_1_to_2_b.distance_squared_to(segment_2_b)
    
    return min(min(distance_squared_from_2_to_1_a, distance_squared_from_2_to_1_b), \
            min(distance_squared_from_1_to_2_a, distance_squared_from_1_to_2_b))

# Calculates the closest position on a line segment to a point.
static func get_closest_point_on_segment_to_point( \
        point: Vector2, segment_a: Vector2, segment_b: Vector2) -> Vector2:
    var v = segment_b - segment_a
    var u = segment_a - point
    var t = - v.dot(u) / v.dot(v)
    
    if t >= 0 and t <= 1:
        # The projection of the point lies within the bounds of the segment.
        return (1 - t) * segment_a + t * segment_b
    else:
        # The projection of the point lies outside bounds of the segment.
        var distance_squared_a = point.distance_squared_to(segment_a)
        var distance_squared_b = point.distance_squared_to(segment_b)
        return segment_a if distance_squared_a < distance_squared_b else segment_b

# Determine whether the points of the polygon are defined in a clockwise direction. This uses the
# shoelace formula.
static func is_polygon_clockwise(vertices: Array) -> bool:
    var vertex_count := vertices.size()
    var sum := 0.0
    var v1: Vector2 = vertices[vertex_count - 1]
    var v2: Vector2 = vertices[0]
    sum += (v2.x - v1.x) * (v2.y + v1.y)
    for i in range(vertex_count - 1):
        v1 = vertices[i]
        v2 = vertices[i + 1]
        sum += (v2.x - v1.x) * (v2.y + v1.y)
    return sum < 0

static func get_bounding_box_for_points(points: PoolVector2Array) -> Rect2:
    assert(points.size() > 0)
    var bounding_box = Rect2(points[0], Vector2.ZERO)
    for i in range(1, points.size()):
        bounding_box.expand(points[i])
    return bounding_box

# The build-in TileMap.world_to_map generates incorrect results around cell boundaries, so we use a
# custom utility.
static func world_to_tile_map(position: Vector2, tile_map: TileMap) -> Vector2:
    var cell_size_world_coord := tile_map.cell_size
    var position_map_coord := position / cell_size_world_coord
    position_map_coord = Vector2(floor(position_map_coord.x), floor(position_map_coord.y))
    return position_map_coord

# Calculates the TileMap (grid-based) coordinates of the given position, relative to the origin of
# the TileMap's bounding box.
static func get_tile_map_index_from_world_coord(position: Vector2, tile_map: TileMap, \
        side: String) -> int:
    var position_grid_coord = world_to_tile_map(position, tile_map)
    return get_tile_map_index_from_grid_coord(position_grid_coord, tile_map)

# Calculates the TileMap (grid-based) coordinates of the given position, relative to the origin of
# the TileMap's bounding box.
static func get_tile_map_index_from_grid_coord(position: Vector2, tile_map: TileMap) -> int:
    var used_rect := tile_map.get_used_rect()
    var tile_map_start := used_rect.position
    var tile_map_width: int = used_rect.size.x
    var tile_map_position: Vector2 = position - tile_map_start
    return (tile_map_position.y * tile_map_width + tile_map_position.x) as int

static func get_collision_tile_map_coord(position_world_coord: Vector2, tile_map: TileMap, \
        is_touching_floor: bool, is_touching_ceiling: bool, \
        is_touching_left_wall: bool, is_touching_right_wall: bool) -> Vector2:
    var half_cell_size = tile_map.cell_size / 2
    var used_rect = tile_map.get_used_rect()
    var position_relative_to_tile_map = \
            position_world_coord - used_rect.position * tile_map.cell_size
    
    var cell_width_mod = abs(fmod(position_relative_to_tile_map.x, tile_map.cell_size.x))
    var cell_height_mod = abs(fmod(position_relative_to_tile_map.y, tile_map.cell_size.y))
    
    var is_between_cells_horizontally = cell_width_mod < FLOAT_EPSILON or \
            tile_map.cell_size.x - cell_width_mod < FLOAT_EPSILON
    var is_between_cells_vertically = cell_height_mod < FLOAT_EPSILON or \
            tile_map.cell_size.y - cell_height_mod < FLOAT_EPSILON
    
    var tile_coord: Vector2
    
    if is_between_cells_horizontally and is_between_cells_vertically:
        var top_left_cell_coord = \
                world_to_tile_map(Vector2(position_world_coord.x - half_cell_size.x, \
                        position_world_coord.y - half_cell_size.y), tile_map)
        
        var is_there_a_tile_at_top_left = \
                tile_map.get_cellv(top_left_cell_coord) >= 0
        var is_there_a_tile_at_top_right = \
                tile_map.get_cell(top_left_cell_coord.x + 1, top_left_cell_coord.y) >= 0
        var is_there_a_tile_at_bottom_left = \
                tile_map.get_cell(top_left_cell_coord.x, top_left_cell_coord.y + 1) >= 0
        var is_there_a_tile_at_bottom_right = \
                tile_map.get_cell(top_left_cell_coord.x + 1, top_left_cell_coord.y + 1) >= 0
        
        if is_touching_floor:
            if is_touching_left_wall:
                assert(is_there_a_tile_at_bottom_left)
                tile_coord = Vector2(top_left_cell_coord.x, top_left_cell_coord.y + 1)
            if is_touching_right_wall:
                assert(is_there_a_tile_at_bottom_right)
                tile_coord = Vector2(top_left_cell_coord.x + 1, top_left_cell_coord.y + 1)
            elif is_there_a_tile_at_bottom_left:
                tile_coord = Vector2(top_left_cell_coord.x, top_left_cell_coord.y + 1)
            elif is_there_a_tile_at_bottom_right:
                tile_coord = Vector2(top_left_cell_coord.x + 1, top_left_cell_coord.y + 1)
            else:
                Utils.error("Invalid state: Problem calculating colliding cell on floor")
        elif is_touching_ceiling:
            if is_touching_left_wall:
                assert(is_there_a_tile_at_top_left)
                tile_coord = Vector2(top_left_cell_coord.x, top_left_cell_coord.y)
            if is_touching_right_wall:
                assert(is_there_a_tile_at_top_right)
                tile_coord = Vector2(top_left_cell_coord.x + 1, top_left_cell_coord.y)
            elif is_there_a_tile_at_top_left:
                tile_coord = Vector2(top_left_cell_coord.x, top_left_cell_coord.y)
            elif is_there_a_tile_at_top_right:
                tile_coord = Vector2(top_left_cell_coord.x + 1, top_left_cell_coord.y)
            else:
                Utils.error("Invalid state: Problem calculating colliding cell on ceiling")
        elif is_touching_left_wall:
            if is_there_a_tile_at_top_left:
                tile_coord = Vector2(top_left_cell_coord.x, top_left_cell_coord.y)
            elif is_there_a_tile_at_bottom_left:
                tile_coord = Vector2(top_left_cell_coord.x, top_left_cell_coord.y + 1)
            else:
                Utils.error("Invalid state: Problem calculating colliding cell on left wall")
        elif is_touching_right_wall:
            if is_there_a_tile_at_top_right:
                tile_coord = Vector2(top_left_cell_coord.x + 1, top_left_cell_coord.y)
            elif is_there_a_tile_at_bottom_right:
                tile_coord = Vector2(top_left_cell_coord.x + 1, top_left_cell_coord.y + 1)
            else:
                Utils.error("Invalid state: Problem calculating colliding cell on right wall")
        else:
            Utils.error("Invalid state: Problem calculating colliding cell")
        
    elif is_between_cells_horizontally:
        var left_cell_coord = \
                world_to_tile_map(Vector2(position_world_coord.x - half_cell_size.x, \
                        position_world_coord.y), tile_map)
        var is_there_a_tile_at_left = tile_map.get_cellv(left_cell_coord) >= 0
        var is_there_a_tile_at_right = \
                tile_map.get_cell(left_cell_coord.x + 1, left_cell_coord.y) >= 0
        
        if is_touching_left_wall:
            if is_there_a_tile_at_left:
                tile_coord = Vector2(left_cell_coord.x, left_cell_coord.y)
            else:
                Utils.error("Invalid state: Problem calculating colliding cell on left wall")
        elif is_touching_right_wall:
            if is_there_a_tile_at_right:
                tile_coord = Vector2(left_cell_coord.x + 1, left_cell_coord.y)
            else:
                Utils.error("Invalid state: Problem calculating colliding cell on right wall")
        elif is_there_a_tile_at_left:
            tile_coord = Vector2(left_cell_coord.x, left_cell_coord.y)
        elif is_there_a_tile_at_right:
            tile_coord = Vector2(left_cell_coord.x + 1, left_cell_coord.y)
        else:
            Utils.error("Invalid state: Problem calculating colliding cell")
        
    elif is_between_cells_vertically:
        var top_cell_coord = world_to_tile_map(Vector2(position_world_coord.x, \
                position_world_coord.y - half_cell_size.y), tile_map)
        var is_there_a_tile_at_bottom = \
                tile_map.get_cell(top_cell_coord.x, top_cell_coord.y + 1) >= 0
        var is_there_a_tile_at_top = tile_map.get_cellv(top_cell_coord) >= 0
        
        if is_touching_floor:
            if is_there_a_tile_at_bottom:
                tile_coord = Vector2(top_cell_coord.x, top_cell_coord.y + 1)
            else:
                Utils.error("Invalid state: Problem calculating colliding cell on floor")
        elif is_touching_ceiling:
            if is_there_a_tile_at_top:
                tile_coord = Vector2(top_cell_coord.x, top_cell_coord.y)
            else:
                Utils.error("Invalid state: Problem calculating colliding cell on ceiling")
        elif is_there_a_tile_at_bottom:
            tile_coord = Vector2(top_cell_coord.x, top_cell_coord.y + 1)
        elif is_there_a_tile_at_top:
            tile_coord = Vector2(top_cell_coord.x, top_cell_coord.y)
        else:
            Utils.error("Invalid state: Problem calculating colliding cell")
        
    else:
        tile_coord = world_to_tile_map(position_world_coord, tile_map)
    
    # Ensure the cell we calculated actually contains content.
    assert(tile_map.get_cellv(tile_coord) >= 0)
    
    return tile_coord
