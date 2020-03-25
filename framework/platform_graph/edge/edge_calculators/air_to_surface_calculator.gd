extends EdgeMovementCalculator
class_name AirToSurfaceCalculator

const MovementCalcOverallParams := preload("res://framework/platform_graph/edge/calculation_models/movement_calculation_overall_params.gd")

const NAME := "AirToSurfaceCalculator"

func _init().(NAME) -> void:
    pass

func get_can_traverse_from_surface(surface: Surface) -> bool:
    return surface == null

func get_all_inter_surface_edges_from_surface( \
        collision_params: CollisionCalcParams, \
        edges_result: Array, \
        surfaces_in_fall_range_set: Dictionary, \
        surfaces_in_jump_range_set: Dictionary, \
        origin_surface: Surface) -> void:
    Utils.error( \
            "AirToSurfaceCalculator.get_all_inter_surface_edges_from_surface should not be called")

func calculate_edge( \
        collision_params: CollisionCalcParams, \
        position_start: PositionAlongSurface, \
        position_end: PositionAlongSurface, \
        velocity_start := Vector2.INF, \
        in_debug_mode := false) -> Edge:
    return find_a_landing_trajectory( \
            collision_params, \
            {}, \
            position_start, \
            velocity_start, \
            position_end, \
            position_end)

func optimize_edge_land_position_for_path( \
        collision_params: CollisionCalcParams, \
        path: PlatformGraphPath, \
        edge_index: int, \
        edge: Edge, \
        next_edge: IntraSurfaceEdge, \
        in_debug_mode: bool) -> void:
    assert(edge is AirToSurfaceEdge)
    
    EdgeMovementCalculator.optimize_edge_land_position_for_path_helper( \
            collision_params, \
            path, \
            edge_index, \
            edge, \
            next_edge, \
            in_debug_mode, \
            self)

# Finds a movement step that will result in landing on a surface, with an attempt to minimize the
# path the player would then have to travel between surfaces to reach the given target.
#
# Returns null if no possible landing exists.
func find_a_landing_trajectory( \
        collision_params: CollisionCalcParams, \
        possible_surfaces_set: Dictionary, \
        origin: PositionAlongSurface, \
        velocity_start: Vector2, \
        goal: PositionAlongSurface, \
        exclusive_land_position: PositionAlongSurface) -> AirToSurfaceEdge:
    # TODO: Use goal param.
    
    var calc_results: MovementCalcResults
    
    if exclusive_land_position != null:
        calc_results = FallMovementUtils.find_landing_trajectory_between_positions( \
                origin, \
                exclusive_land_position, \
                velocity_start, \
                collision_params)
    else:
        var landing_surfaces_to_skip := {}
        
        # Find all possible surfaces in landing range.
        var result_set := {}
        FallMovementUtils.find_surfaces_in_fall_range_from_point( \
                collision_params.movement_params, \
                possible_surfaces_set, \
                result_set, \
                origin.target_point, \
                velocity_start, \
                landing_surfaces_to_skip)
        var possible_landing_surfaces := result_set.keys()
        possible_landing_surfaces.sort_custom(SurfaceMaxYComparator, "sort")
        
        # Find the closest landing trajectory.
        var landing_trajectories := FallMovementUtils.find_landing_trajectories_to_any_surface( \
                collision_params, \
                possible_surfaces_set, \
                origin, \
                velocity_start, \
                landing_surfaces_to_skip, \
                possible_landing_surfaces, \
                true)
        if landing_trajectories.empty():
            return null
        calc_results = landing_trajectories[0]
    
    # Calculate instructions for the given landing trajectory.
    var land_position := calc_results.overall_calc_params.destination_position
    var instructions := MovementInstructionsUtils \
            .convert_calculation_steps_to_movement_instructions( \
                    calc_results, \
                    false, \
                    land_position.surface.side)
    var trajectory := MovementTrajectoryUtils.calculate_trajectory_from_calculation_steps( \
            calc_results, \
            instructions)
    
    var velocity_end: Vector2 = calc_results.horizontal_steps.back().velocity_step_end
    
    return AirToSurfaceEdge.new( \
            self, \
            origin, \
            land_position, \
            velocity_start, \
            velocity_end, \
            collision_params.movement_params, \
            instructions, \
            trajectory)

class SurfaceMaxYComparator:
    static func sort(a: Surface, b: Surface) -> bool:
        return a.bounding_box.position.y < b.bounding_box.position.y