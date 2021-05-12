# Information for how to move through the air from a start position to an end position.
class_name AirToAirEdge
extends Edge

const TYPE := EdgeType.AIR_TO_AIR_EDGE
const IS_TIME_BASED := true
const SURFACE_TYPE := SurfaceType.AIR
const ENTERS_AIR := false
const INCLUDES_AIR_TRAJECTORY := true

func _init(
        calculator = null,
        start := Vector2.INF,
        end := Vector2.INF,
        velocity_start := Vector2.INF,
        velocity_end := Vector2.INF,
        movement_params: MovementParams = null,
        instructions: EdgeInstructions = null,
        trajectory: EdgeTrajectory = null,
        edge_calc_result_type := EdgeCalcResultType.UNKNOWN,
        time_peak_height := INF) \
        .(TYPE,
        IS_TIME_BASED,
        SURFACE_TYPE,
        ENTERS_AIR,
        INCLUDES_AIR_TRAJECTORY,
        calculator,
        Edge.vector2_to_position_along_surface(start),
        Edge.vector2_to_position_along_surface(end),
        velocity_start,
        velocity_end,
        false,
        false,
        movement_params,
        instructions,
        trajectory,
        edge_calc_result_type,
        time_peak_height) -> void:
    pass

func _calculate_distance(
        start: PositionAlongSurface,
        end: PositionAlongSurface,
        trajectory: EdgeTrajectory) -> float:
    return trajectory.distance_from_continuous_frames

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
    if edge_time < time_peak_height:
        result.animation_type = PlayerAnimationType.JUMP_RISE
        result.animation_position = edge_time
    else:
        result.animation_type = PlayerAnimationType.JUMP_FALL
        result.animation_position = edge_time - time_peak_height
    # TODO: Check instructions to determine actual facing-direction.
    result.facing_left = get_velocity_at_time(edge_time).x < 0.0

func _check_did_just_reach_destination(
        navigation_state: PlayerNavigationState,
        surface_state: PlayerSurfaceState,
        playback) -> bool:
    if movement_params.bypasses_runtime_physics:
        return playback.get_elapsed_time_scaled() >= duration
    else:
        return playback.is_finished
