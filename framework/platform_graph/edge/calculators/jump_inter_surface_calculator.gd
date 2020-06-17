extends EdgeCalculator
class_name JumpInterSurfaceCalculator

const NAME := "JumpInterSurfaceCalculator"
const EDGE_TYPE := EdgeType.JUMP_INTER_SURFACE_EDGE
const IS_A_JUMP_CALCULATOR := true

# FIXME: LEFT OFF HERE: ------------------------------------------------------A
# FIXME: -----------------------------
# 
# - When showing preselection surface, also show a big highlighted navigation
#   path.
# 
# - Profiler!
#   - Put together some interesting aggregations, such as:
#     - Time spent calculating individual edges, edges of type, all edges.
#       - And time spent calculating different parts of an edge:
#         - Jump/land position, broad phase, narrow phase.
#         - Waypoints
#         - Horizontal steps
#         - Vertical steps
#         - Collisions
#         - Distance, duration, and weight
#           - Avg, mean, min, max
#           - All edges, edges of type
#         - Number of jump/land positions:
#           - Avg, mean, min, max
#           - All edges, edges of type
#           - Number of less likely to be valid
#           - Number needing extra jump duration
#         - Number of edges for each EdgeCalcResultType.
#     - How many collisions on avg for jump/fall.
#     - How many steps calculated for an edge (avg, mean, min, max).
#     - Step recursion depth (with and without backtracking) (avg, mean, min,
#       max).
#     - 
#     
#     - ...
#   - Step through and consider whether I want to show any other analytic
#     description children for each item.
#   - Spend some time thinking through the actual timings of the various parts
#     of calculations (horizontal more than vertical, when possible).
#   - Figure out how/where to store this.
#     - Don't just keep all step debug state--too much.
#     - In particular, don't keep any PositionAlongSurface references--would
#       break deduping in PlatformGraph.
#   - Log a bit of metadata and duration info on every calculated edge attempt,
#     such as:
#     - number of attempted steps,
#     - types of steps,
#     - number of collisions,
#     - number of backtracking attempts,
#   - Support multiple modes of displaying these analytics:
#     - Global
#     - For a single surface
#     - For a single edge
#     - For a single edge-step attempt?
#       - Should this be listed/nested under the edge mode somehow?
#         - FIXME
#     - Also, dynamically calculate edge attempts, in order to capture deeper
#       debugging info, when expanding their tree items.
#     - When selecting something by clicking on the level, open the
#       corresponding path in the tree, rather than displaying something new
#       and out of context with the global tree.
#   - Single-surface data structure draft:
#     - 
#   - Single-edge data structure draft:
#     - 
#   - Use the Godot Debugger profiler tools.
#   - Try to use these analytics to inform decisions around which calculations
#     are worth it.
#     - Maybe add a new configuration for max number of
#       collisions/intermediate-waypoints to allow in an edge calculation before
#       giving up (or, recursion depth (with and without backtracking))?
#     - Tweak movement_params.exceptional_jump_instruction_duration_increase, and
#       ensure that it is actually cutting down on the number of times we have to
#       backtrack.
# 
# - Re-implement/use DEBUG_MODE flag:
#   - Switch some MovementParam values when it's on:
#     - syncs_player_velocity_to_edge_trajectory
#     - ACTUALLY, maybe just implement another version of CatPlayer that only
#       has MovementParams as different, then it's easy to toggle.
#       - Would need to make it easy to re-use same animator logic though...
#   - Switch which annotations are used.
#   - Switch which level is used?
# 
# - When "backtracking" for height, re-use all previous waypoints, but reset
#   their times and maybe velocities.
#   - This should actually mean that we no longer "backtrack"/recurse
#     specially.
#   - Conditionally use this approach behind a movement_params flag. This
#     should improve efficiency and decrease accuracy.
#   - Then also add another flag for whether to run a final collision test over
#     the combined steps after calculating the result.
#     - This should be useful, since we'll want to ensure that such
#       calculations don't produce false positives.
# 
# - Debug performance with how many jump/land pairs get returned, and how
#   costly the new extra previous-jump/land-position-distance checks are.
# 
# - Debug all the new jump/land optimization logic.
# 
# - Finish logic to consume Waypoint.needs_extra_jump_duration.
#   - Started, but stopped partway through, with adding this usage in
#     _update_waypoint_velocity_and_time.
# 
# - Check on current behavior of
#   EdgeInstructionsUtils.JUMP_DURATION_INCREASE_EPSILON and 
#   EdgeInstructionsUtils.MOVE_SIDEWAYS_DURATION_INCREASE_EPSILON.
# 
# --- Debug ---
# 
# - Check whether the dynamic edge optimizations are too expensive.
# 
# - Things to debug:
#   - Jumping from floor of lower-small-block to floor of upper-small-black.
#     - Collision detection isn't correctly detecting the collision with the
#       right-side of the upper block.
#   - Jumping from floor of lower-small-block to far right-wall of
#     upper-small-black.
#   - Jumping from left-wall of upper-small-block to right-wall of
#     upper-small-block.
# 
# >>- Fix how things work when minimizes_velocity_change_when_jumping is true.
#   - [no] Find and move all movement-offset constants to one central location?
#     - EdgeInstructionsUtils
#     - WaypointUtils
#     - FrameCollisionCheckUtils
#     - EdgeCalcParams
#   >>>- Compare where instructions are pressed/released vs when I expect them.
#   - Step through movement along an edge?
#   >>- Should this be when I implement the logic to force the player's
#     position to match the expected edge positions (with a weighted avg)?
# 
# - Debug edges.
#   - Calculation: Check all edge-cases; look at all expected edge trajectories
#     in each level.
#   - Execution: Check that navigation actually follows paths and executes
#     trajectories as expected.
# 
# - Debug why this edge calculation generates 35 steps...
#   - test_level_long_rise
#   - from top-most floor to bottom-most (wide) floor, on the right side
# 
# - Fix frame collision detection...
#   - Seeing pre-existing collisions when jumping from walls.
#   - Fix collision-detection errors from logs.
#   - Go through levels and verify that all expected edges work.
# 
# - Fix issue where jumping around edge sometimes isn't going far enough; it's
#   clipping the corner.
# 
# - Re-visit GRAVITY_MULTIPLIER_TO_ADJUST_FOR_FRAME_DISCRETIZATION
# 
# - Fix performance.
#   - Should I almost never be actually storing things in Pool arrays? It seems
#     like I mostly end up passing them around as arguments to functions, to
#     they get copied as values...
# 
# - Adjust cat_params to only allow subsets of EdgeCalculators, in
#   order to test the non-jump edges
# 
# - Test/debug FallMovementUtils.find_a_landing_trajectory (when clicking from
#   an air position).
# 
# --- EASIER BITS ---
# 
# - Figure out how to fix scaling/aliasing in Godot when adjusting to different
#   screen sizes and camera zoom.
# 
# - Update level images:
#   - Make background layers more faded
#   - Make foreground images more wood-like
# 
# - Think up ways to make some debug annotations more
#   dynamic/intelligent/useful...
#   - Make jump/land positions (along with start v, and which pairs connect)
#     more discoverable when ctrl+clicking.
#   - A mode to dynamically show next edge debug state while navigating a path?
#     - Maybe the goal here should be to make all the the complexity of the
#       graph/waypoints/alternative-or-failed-branches somehow visible or
#       understandable to others with a quick viewing.
#   - Have a mode that hides all the other background, foreground, and player
#     images, so that we can just show the annotations.
# 
# - In the README, list the types of MovementParams.
# 
# - Prepare a different, more interesting level for demo (some walls connecting
#   to floors too).
# 
# - Put together some illustrative screenshots with special one-off annotations
#   to explain the graph parsing steps in the README.
#   - Use Config.DEBUG_PARAMS.extra_annotations
#   - Screenshots:
#     - A couple surfaces
#     - Show different tiles, to illustrate how surfaces get merged.
#     - All surfaces (different colors)
#     - A couple edges
#     - All edges
#     - 
# 
# - Update panel styling.
#   - Flat.
#   - Square corners.
#   - Probably should do this with Godot theming...
# 
# ---  ---
# 
# - Add squirrel assets and animation.
#   - Start by copying-over the Piskel squirrel animation art.
#   - Create squirrel parts art in Aseprite.
#   - Create squirrel animation key frames in Godot.
#     - Idle, standing
#     - Idle, climbing
#     - Crawl-walk-sniff
#     - Bounding walk
#     - Climbing up
#     - Climbing down (just run climbing-up in reverse? Probably want to bound
#       down, facing down, as opposed to cat. Will make transition weird, but
#       whatever?)
#     - 
# 
# ---  ---
# 
# - Loading screen
#   - While downloading, and while parsing level graph
#   - Hand-animated pixel art
#   - Simple GIF file
#   - Host/load/show separately from the rest of the JavaScript and assets
#   - Squirrels digging-up/eating tulips
# 
# - Welcome screen
#   - Hand-animated pixel art
#   x- Gratuitous whooshy sliding shine and a sparkle at the end
#   x- With squirrels running and climbing over the letters?
#   >- Approach:
#     - Start simple. Pick font. Render in Inkscape. Create a hand-pixel-drawn
#       copy in Aseprite.
#     - V1: Show "Squirrel Away" text. Animate squirrel running across, right
#           to left, in front of letters.
#     - V2: Have squirrel pause to the left of the S, with its tail overlapping
#           the S. Give a couple tail twitches. Then have squirrel leave.
#     
# ---  ---
# 
# - Improve annotation configuration.
#   - Implement the bits of utility-menu UI to toggle annotations.
#     - Add support for configuring in the menu which edge-type calculator to
#       use with the inspector-selector.
#     - And to configure which player to use.
#     - Add a way to re-display the controls list.
#     - Also support adjusting how many previous player positions to render.
#     - Also list controls in the utility menu.
#     - Collision calculation annotator bits.
#     - Add a top-level button to utility menu to hide all annotations.
#       - (grid, clicks, player position, player recent movement, platform
#         graph, ...)
#     - Toggle whether the legend (and current selection description) is shown.
#     - Also, update the legend as annotations are toggled.
#   - Include other items in the legend:
#     - Step items:
#       - Fake waypoint?
#       - Invalid waypoint?
#       - Collision boundary at moment of collision
#       - Collision debugging: previous frame, current frame, next frame
#         boundaries
#       - Mid waypoints?
#     - Navigator path (current and previous)
#     - Recent movement
#   - Add shortcuts for toggling debugging annotations
#     - Add support for triggering the calc-step annotations based on a
#       shortcut.
#       - i
#       - also, require clicking on the start and end positions in order to
#         select which edge to debug.
#         - Use this _in addition to_ the current top-level configuration for
#           specifying which edge to calculate?
#       - also, then only actually calculate the edge debug state when using
#         this click-to-specify debug mode.
#     - also, add other shortcuts for toggling other annotations:
#       - whether all surfaces are highlighted
#       - whether the player's position+collision boundary are rendered
#       - whether the player's current surface is rendered
#       - whether all edges are rendered
#       - whether grid boundaries+indices are rendered
#       - whether the ruler is rendered
#       - whether the actual level tilemap is rendered
#       - whether the background is rendered
#       - whether the actual players are rendered
#     - create a collapsible dat.GUI-esque menu at the top-right that lists all
#       the possible annotation configuration options.
#       - set up a nice API for creating these, setting values, listening for
#         value changes, and defining keyboard shortcuts.
#   - Use InputMap to programatically add keybindings.
#     - This should enable our framework to setup all the shortcuts it cares
#       about, without consumers needing to ever redeclare anything in their
#       project settings.
#     - This should also enable better API design for configuring keybindings
#       and menu items from the same place.
#     - https://godot-es-docs.readthedocs.io/en/latest/classes/
#               class_inputmap.html#class-inputmap
# 
# - Finish remaining surface-closest-point-jump-off calculation cases.
#   - Also, maybe still not quite far enough with the offset?
# 
# - Implement fall-through/walk-through movement-type utils.
# 
# - Cleanup frame_collison_check_utils:
#   - Clean-up/break-apart/simplify current logic.
#   - Maybe add some old ideas for extra improvements to
#     check_frame_for_collision:
#     - [maybe?] Rather than just using closest_intersection_point, sort all
#       intersection_points, and try each of them in sequence when the first
#       one fails	
#     - [easy to add, might be nice for future] If that also fails, use a
#       completely separate new cheap-and-dirty check-for-collision-in-frame
#       method?	
#       - Check if intersection_points is not-empty.
#       - Sort them by closest in direction of motion (and ignoring behind
#         points).
#       - Iterate through points, trying to get tile index by a slight nudge
#         offset from each
#         intersection point in the direction of motion until one sticks.
#       - Choose surface side just from dominant motion component.
#     - Add a field on the collision class for the type of collision check
#       used.
#     - Add another field (or another option for the above field) to indicate
#       that none of the collision checks worked, and this collision is in an
#       error state.
#     - Use this error state to abort collision/step/edge calculations (rather
#       than the current approach of returning null, which is the same as with
#       not detecting any collisions at all).
#     - It might be worth adding a check before ray-tracing to check whether
#       the starting point is_far_enough_from_other_jump_land_positionslies
#       within a populated tile in the tilemap, and then trying the other
#       perpendicular offset direction if so. However, this would require
#       configuring a single global tile map that we expect collisions from,
#       and plumbing that tile map through to here.
# 
# - Look into themes, and what default/global theme state I should set up.
# - Look into what sort of anti-aliasing and scaling to do with GUI vs level vs
#   camera/window zoom...
# 
# - Fix the behavior that causes vertical movement along a wall to get sucked
#   slightly toward the wall after passing the end of the wall (assuming the
#   motion was actually touching the wall).
#   - This is not caused by my logic; it's a property of the underlying Godot
#     collision engine.
# 
# - Add a configurable method to the MovementParams API for defining arbitrary
#   weight calculation for each character type (it could do things like
#   strongly prefer certain edge types). 
# 
# - Check FIXMEs in CollisionCheckUtils. We should check on their accuracy now.
# 
# - Add some sort of warning message when the player's run-time velocity is too
#   far from what's expected?
# 
# - Switch to built-in Godot gradients for surface annotations.
# 
# - Refactor pre-existing annotator classes to use the new
#   AnnotationElementType system.
#   - At least remove ExtraAnnotator and replace it with the new
#     general-purpose annotator.
#   - And probably just remove some obsolete annotators.
# 
# - Refactor old color and const systems to use the new
#   AnnotationElementDefaults system.
#   - Colors class.
#   - Look for const values scattered throughout.
# 
# - Create another annotator to indicate the current navigation destination
#   more boldly.
#   - After selecting the destination, animate the surface and position
#     indicator annotations downward (and inward) onto the surface, and then
#     have the position indicator stay there until navigation is done (pulsing
#     indicator with opacity and size (use sin wave) and pulsing overlapping
#     two/three repeating outward-growing surface ellipses).
#   - Use some sort of pulsing/growing elliptical gradient from the position
#     indicator along the nearby surface face.
#     - Will have to be a custom radial gradient:
#       - https://github.com/Maujoe/godot-custom-gradient-texture/blob/master/
#              assets/maujoe.custom_gradient_texture/custom_gradient_texture.gd
#     - Will probably want to create a texture out of this radial gradient, set
#       the texture to not repeat, render the texture offset within a
#       transparent rectangle, then just animate the UV coordinates.
# 
# - [or skip? (should be fixed when turning on v sync)] Fix a bug where jump
#   falls way short; from right-end of short-low floor to bottom-end of
#   short-high-right-side wall.
# 
# - Add TODOs to use easing curves with all annotation animations.
# 



func _init().( \
        NAME, \
        EDGE_TYPE, \
        IS_A_JUMP_CALCULATOR) -> void:
    pass

func get_can_traverse_from_surface(surface: Surface) -> bool:
    return surface != null

func get_all_inter_surface_edges_from_surface( \
        inter_surface_edges_results: Array, \
        collision_params: CollisionCalcParams, \
        origin_surface: Surface, \
        surfaces_in_fall_range_set: Dictionary, \
        surfaces_in_jump_range_set: Dictionary) -> void:
    var debug_params := collision_params.debug_params
    
    var jump_land_position_results_for_destination_surface := []
    var jump_land_positions_to_consider: Array
    var inter_surface_edges_result: InterSurfaceEdgesResult
    var edge_result_metadata: EdgeCalcResultMetadata
    var failed_attempt: FailedEdgeAttempt
    var edge: JumpInterSurfaceEdge
    
    for destination_surface in surfaces_in_jump_range_set:
        # This makes the assumption that traversing through any
        # fall-through/walk-through surface would be better handled by some
        # other Movement type, so we don't handle those cases here.
        
        #######################################################################
        # Allow for debug mode to limit the scope of what's calculated.
        if EdgeCalculator.should_skip_edge_calculation( \
                debug_params, \
                origin_surface, \
                destination_surface):
            continue
        #######################################################################
        
        if origin_surface == destination_surface:
            # We don't need to calculate edges for the degenerate case.
            continue
        
        jump_land_position_results_for_destination_surface.clear()
        
        jump_land_positions_to_consider = JumpLandPositionsUtils \
                .calculate_jump_land_positions_for_surface_pair( \
                        collision_params.movement_params, \
                        origin_surface, \
                        destination_surface)
        
        inter_surface_edges_result = InterSurfaceEdgesResult.new( \
                origin_surface, \
                destination_surface, \
                edge_type, \
                jump_land_positions_to_consider)
        inter_surface_edges_results.push_back(inter_surface_edges_result)
        
        for jump_land_positions in jump_land_positions_to_consider:
            ###################################################################
            # Record some extra debug state when we're limiting calculations to
            # a single edge (which must be this edge).
            var record_calc_details: bool = \
                    debug_params.has("limit_parsing") and \
                    debug_params.limit_parsing.has("edge") and \
                    debug_params.limit_parsing.edge.has("origin") and \
                    debug_params.limit_parsing.edge.origin.has( \
                            "position") and \
                    debug_params.limit_parsing.edge.has("destination") and \
                    debug_params.limit_parsing.edge.destination.has("position")
            ###################################################################
            
            edge_result_metadata = \
                    EdgeCalcResultMetadata.new(record_calc_details)
            
            if !EdgeCalculator.broad_phase_check( \
                    edge_result_metadata, \
                    collision_params, \
                    jump_land_positions, \
                    jump_land_position_results_for_destination_surface, \
                    false):
                failed_attempt = FailedEdgeAttempt.new( \
                        jump_land_positions, \
                        edge_result_metadata, \
                        self)
                inter_surface_edges_result.failed_edge_attempts.push_back( \
                        failed_attempt)
                continue
            
            edge = calculate_edge( \
                    edge_result_metadata, \
                    collision_params, \
                    jump_land_positions.jump_position, \
                    jump_land_positions.land_position, \
                    jump_land_positions.velocity_start, \
                    jump_land_positions.needs_extra_jump_duration, \
                    jump_land_positions.needs_extra_wall_land_horizontal_speed)
            
            if edge != null:
                # Can reach land position from jump position.
                inter_surface_edges_result.valid_edges.push_back(edge)
                edge = null
                jump_land_position_results_for_destination_surface.push_back( \
                        jump_land_positions)
            else:
                failed_attempt = FailedEdgeAttempt.new( \
                        jump_land_positions, \
                        edge_result_metadata, \
                        self)
                inter_surface_edges_result.failed_edge_attempts.push_back( \
                        failed_attempt)

func calculate_edge( \
        edge_result_metadata: EdgeCalcResultMetadata, \
        collision_params: CollisionCalcParams, \
        position_start: PositionAlongSurface, \
        position_end: PositionAlongSurface, \
        velocity_start := Vector2.INF, \
        needs_extra_jump_duration := false, \
        needs_extra_wall_land_horizontal_speed := false) -> Edge:
    edge_result_metadata = \
            edge_result_metadata if \
            edge_result_metadata != null else \
            EdgeCalcResultMetadata.new(false)
    
    var edge_calc_params := \
            EdgeCalculator.create_edge_calc_params( \
                    edge_result_metadata, \
                    collision_params, \
                    position_start, \
                    position_end, \
                    true, \
                    velocity_start, \
                    needs_extra_jump_duration, \
                    needs_extra_wall_land_horizontal_speed)
    if edge_calc_params == null:
        # Cannot reach destination from origin.
        assert(edge_result_metadata.edge_calc_result_type != \
                EdgeCalcResultType.EDGE_VALID)
        return null
    
    return create_edge_from_edge_calc_params( \
            edge_result_metadata, \
            edge_calc_params)

func optimize_edge_jump_position_for_path( \
        collision_params: CollisionCalcParams, \
        path: PlatformGraphPath, \
        edge_index: int, \
        previous_velocity_end_x: float, \
        previous_edge: IntraSurfaceEdge, \
        edge: Edge) -> void:
    assert(edge is JumpInterSurfaceEdge)
    
    EdgeCalculator.optimize_edge_jump_position_for_path_helper( \
            collision_params, \
            path, \
            edge_index, \
            previous_velocity_end_x, \
            previous_edge, \
            edge, \
            self)

func optimize_edge_land_position_for_path( \
        collision_params: CollisionCalcParams, \
        path: PlatformGraphPath, \
        edge_index: int, \
        edge: Edge, \
        next_edge: IntraSurfaceEdge) -> void:
    assert(edge is JumpInterSurfaceEdge)
    
    EdgeCalculator.optimize_edge_land_position_for_path_helper( \
            collision_params, \
            path, \
            edge_index, \
            edge, \
            next_edge, \
            self)

func create_edge_from_edge_calc_params( \
        edge_result_metadata: EdgeCalcResultMetadata, \
        edge_calc_params: EdgeCalcParams) -> \
        JumpInterSurfaceEdge:
    var calc_result := \
            EdgeStepUtils.calculate_steps_with_new_jump_height( \
                    edge_result_metadata, \
                    edge_calc_params, \
                    null, \
                    null)
    if calc_result == null:
        # Unable to calculate a valid edge.
        assert(edge_result_metadata.edge_calc_result_type != \
                EdgeCalcResultType.EDGE_VALID)
        return null
    
    assert(edge_result_metadata.edge_calc_result_type == \
            EdgeCalcResultType.EDGE_VALID)
    
    var instructions := EdgeInstructionsUtils \
            .convert_calculation_steps_to_movement_instructions( \
                    calc_result, \
                    true, \
                    edge_calc_params.destination_position.surface.side)
    var trajectory := EdgeTrajectoryUtils \
            .calculate_trajectory_from_calculation_steps( \
                    calc_result, \
                    instructions)
    
    var velocity_end: Vector2 = \
            calc_result.horizontal_steps.back().velocity_step_end
    
    var edge := JumpInterSurfaceEdge.new( \
            self, \
            edge_calc_params.origin_position, \
            edge_calc_params.destination_position, \
            edge_calc_params.velocity_start, \
            velocity_end, \
            edge_calc_params.needs_extra_jump_duration, \
            edge_calc_params.needs_extra_wall_land_horizontal_speed, \
            edge_calc_params.movement_params, \
            instructions, \
            trajectory)
    
    return edge
