# Parameters that are used for calculating edge instructions.
# FIXME: --A ********* doc
extends Reference
class_name MovementCalcOverallParams

const TILE_MAP_COLLISION_LAYER := 7
# FIXME: Test these
const EDGE_MOVEMENT_TEST_MARGIN := 4.0#2.0
const EDGE_MOVEMENT_ACTUAL_MARGIN := 5.0#2.5

var movement_params: MovementParams

var surface_parser: SurfaceParser

# The Godot collision-detection APIs use this state.
var space_state: Physics2DDirectSpaceState

# The Godot collision-detection APIs use this data structure.
var shape_query_params: Physics2DShapeQueryParameters

# A margin to extend around the Player's Collider. This helps to compensate for the imprecision
# of these calculations.
var constraint_offset: Vector2

# The initial velocity for the current edge instructions.
var velocity_start: Vector2

# The origin for the current edge instructions.
var origin_constraint: MovementConstraint

# The destination for the current edge instructions.
var destination_constraint: MovementConstraint

# Whether the calculations for the current edge are allowed to attempt backtracking to consider a
# higher jump.
var can_backtrack_on_height: bool

# Any Surfaces that have previously been hit while calculating the current edge instructions.
# Dictionary<String, bool>
var _collided_surfaces: Dictionary

var debug_state: MovementCalcOverallDebugState

func _init(movement_params: MovementParams, space_state: Physics2DDirectSpaceState, \
            surface_parser: SurfaceParser, velocity_start: Vector2, \
            origin_constraint: MovementConstraint, destination_constraint: MovementConstraint, \
            can_backtrack_on_height := true) -> void:
    self.movement_params = movement_params
    self.space_state = space_state
    self.surface_parser = surface_parser
    self.velocity_start = velocity_start
    self.origin_constraint = origin_constraint
    self.destination_constraint = destination_constraint
    self.can_backtrack_on_height = can_backtrack_on_height
    
    constraint_offset = calculate_constraint_offset(movement_params)
    
    _collided_surfaces = {}
    
    shape_query_params = Physics2DShapeQueryParameters.new()
    shape_query_params.collide_with_areas = false
    shape_query_params.collide_with_bodies = true
    shape_query_params.collision_layer = TILE_MAP_COLLISION_LAYER
    shape_query_params.exclude = []
    shape_query_params.margin = EDGE_MOVEMENT_TEST_MARGIN
    shape_query_params.motion = Vector2.ZERO
    shape_query_params.shape_rid = movement_params.collider_shape.get_rid()
    shape_query_params.transform = Transform2D(movement_params.collider_rotation, Vector2.ZERO)
    shape_query_params.set_shape(movement_params.collider_shape)
    
    if Global.IN_DEBUG_MODE:
        debug_state = MovementCalcOverallDebugState.new(self)

func is_backtracking_valid_for_surface(surface: Surface, time_jump_release: float) -> bool:
    var key := str(surface) + str(time_jump_release)
    return _collided_surfaces.has(key)

func record_backtracked_surface(surface: Surface, time_jump_release: float) -> void:
    var key := str(surface) + str(time_jump_release)
    _collided_surfaces[key] = true

static func calculate_constraint_offset(movement_params: MovementParams) -> Vector2:
    return movement_params.collider_half_width_height + \
            Vector2(EDGE_MOVEMENT_ACTUAL_MARGIN, EDGE_MOVEMENT_ACTUAL_MARGIN)
