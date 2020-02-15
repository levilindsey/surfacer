# Information for how to climb up and over a wall to stand on the adjacent floor.
# 
# The instructions for this edge consist of two consecutive directional-key presses (into the wall,
# and upward), with no corresponding release.
extends Edge
class_name ClimbOverWallToFloorEdge

const NAME := "ClimbOverWallToFloorEdge"
const IS_TIME_BASED := false
const ENTERS_AIR := true

func _init(start: PositionAlongSurface, end: PositionAlongSurface) \
        .(NAME, IS_TIME_BASED, ENTERS_AIR, start, end, null) -> void:
    pass

func _calculate_instructions(start: PositionAlongSurface, \
        end: PositionAlongSurface, calc_results: MovementCalcResults) -> MovementInstructions:
    assert(start.surface.side == SurfaceSide.LEFT_WALL || \
            start.surface.side == SurfaceSide.RIGHT_WALL)
    assert(end.surface.side == SurfaceSide.FLOOR)
    
    var sideways_input_key := \
            "move_left" if start.surface.side == SurfaceSide.LEFT_WALL else "move_right"
    var inward_instruction := MovementInstruction.new(sideways_input_key, 0.0, true)
    
    var upward_instruction := MovementInstruction.new("move_up", 0.0, true)
    
    return MovementInstructions.new([inward_instruction, upward_instruction], INF)

func _calculate_distance(start: PositionAlongSurface, end: PositionAlongSurface, \
        instructions: MovementInstructions) -> float:
    return Geometry.calculate_manhattan_distance(start.target_point, end.target_point)

func _calculate_duration(start: PositionAlongSurface, end: PositionAlongSurface, \
        instructions: MovementInstructions, distance: float) -> float:
    # FIXME: ----------
    return INF

func _check_did_just_reach_destination(navigation_state: PlayerNavigationState, \
        surface_state: PlayerSurfaceState, playback) -> bool:
    return surface_state.just_grabbed_floor
