class_name FallFromWallEdge
extends Edge
# Information for how to let go of a wall in order to fall.
# 
# The instructions for this edge consist of a single sideways key press, with
# no corresponding release.


const TYPE := EdgeType.FALL_FROM_WALL_EDGE
const IS_TIME_BASED := false
const SURFACE_TYPE := SurfaceType.AIR
const ENTERS_AIR := true
const INCLUDES_AIR_TRAJECTORY := true


func _init(
        calculator = null,
        start: PositionAlongSurface = null,
        end: PositionAlongSurface = null,
        velocity_end := Vector2.INF,
        includes_extra_wall_land_horizontal_speed := false,
        movement_params: MovementParams = null,
        instructions: EdgeInstructions = null,
        trajectory: EdgeTrajectory = null,
        edge_calc_result_type := EdgeCalcResultType.UNKNOWN) \
        .(TYPE,
        IS_TIME_BASED,
        SURFACE_TYPE,
        ENTERS_AIR,
        INCLUDES_AIR_TRAJECTORY,
        calculator,
        start,
        end,
        _get_velocity_start(movement_params, start),
        velocity_end,
        false,
        includes_extra_wall_land_horizontal_speed,
        movement_params,
        instructions,
        trajectory,
        edge_calc_result_type,
        0.0) -> void:
    pass


func _calculate_distance(
        start: PositionAlongSurface,
        end: PositionAlongSurface,
        trajectory: EdgeTrajectory) -> float:
    return trajectory.distance_from_continuous_trajectory


func _calculate_duration(
        start: PositionAlongSurface,
        end: PositionAlongSurface,
        instructions: EdgeInstructions,
        distance: float) -> float:
    return instructions.duration


func get_animation_state_at_time(
        result: PlayerAnimationState,
        edge_time: float) -> void:
    result.player_position = get_position_at_time(edge_time)
    result.animation_type = PlayerAnimationType.JUMP_FALL
    result.animation_position = edge_time
    result.facing_left = instructions.get_is_facing_left_at_time(
            edge_time,
            start_position_along_surface.side == SurfaceSide.LEFT_WALL)


func _check_did_just_reach_surface_destination(
        navigation_state: PlayerNavigationState,
        surface_state: PlayerSurfaceState,
        playback) -> bool:
    return check_just_landed_on_expected_surface(
            surface_state,
            self.get_end_surface(),
            playback)


static func _get_velocity_start(
        movement_params: MovementParams,
        start: PositionAlongSurface) -> Vector2:
    return Vector2(movement_params.wall_fall_horizontal_boost * \
                        start.surface.normal.x,
                0.0) if \
            movement_params != null and start != null else \
            Vector2.INF
