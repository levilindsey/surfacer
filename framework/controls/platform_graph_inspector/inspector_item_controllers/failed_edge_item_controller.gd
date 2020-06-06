extends InspectorItemController
class_name FailedEdgeItemController

const TYPE := InspectorItemType.FAILED_EDGE
const IS_LEAF := false
const STARTS_COLLAPSED := true

var failed_edge_attempt: FailedEdgeAttempt
var edge_result_metadata: EdgeCalcResultMetadata

var edge_calc_result_metadata_controller: EdgeCalcResultMetadataItemController

func _init( \
        parent_item: TreeItem, \
        tree: Tree, \
        graph: PlatformGraph, \
        failed_edge_attempt: FailedEdgeAttempt) \
        .( \
        TYPE, \
        IS_LEAF, \
        STARTS_COLLAPSED, \
        parent_item, \
        tree, \
        graph) -> void:
    assert(failed_edge_attempt != null)
    self.failed_edge_attempt = failed_edge_attempt
    _post_init()

func to_string() -> String:
    return "%s { %s; [%s] %s; [%s, %s] }" % [ \
        InspectorItemType.get_type_string(type), \
        EdgeType.get_type_string(failed_edge_attempt.edge_type), \
        "BP" if \
        failed_edge_attempt.is_broad_phase_failure else \
        "NP", \
        EdgeCalcResultType.get_type_string( \
                failed_edge_attempt.edge_calc_result_type) if \
        failed_edge_attempt.edge_calc_result_type != \
                EdgeCalcResultType.WAYPOINT_INVALID else \
        WaypointValidity.get_type_string( \
                failed_edge_attempt.waypoint_validity), \
        str(failed_edge_attempt.start), \
        str(failed_edge_attempt.end), \
    ]

func get_text() -> String:
    return "[%s] %s [%s, %s]" % [ \
        "BP" if \
        failed_edge_attempt.is_broad_phase_failure else \
        "NP", \
        EdgeCalcResultType.get_type_string( \
                failed_edge_attempt.edge_calc_result_type) if \
        failed_edge_attempt.edge_calc_result_type != \
                EdgeCalcResultType.WAYPOINT_INVALID else \
        WaypointValidity.get_type_string( \
                failed_edge_attempt.waypoint_validity), \
        str(failed_edge_attempt.start), \
        str(failed_edge_attempt.end), \
    ]

func get_description() -> String:
    # FIXME: -------------
    # - Also describe difference between narrow and broad phase failure.
    return ""

func find_and_expand_controller( \
        search_type: int, \
        metadata: Dictionary) -> bool:
    assert(search_type == InspectorSearchType.EDGE)
    if Geometry.are_points_equal_with_epsilon( \
                    failed_edge_attempt.start, \
                    metadata.start, \
                    0.01) and \
            Geometry.are_points_equal_with_epsilon( \
                    failed_edge_attempt.end, \
                    metadata.end, \
                    0.01):
        expand()
        select()
        return true
    else:
        return false

func get_has_children() -> bool:
    return !failed_edge_attempt.is_broad_phase_failure

func _create_children_inner() -> void:
    if edge_result_metadata == null:
        _calculate_edge_calc_result_metadata()
    
    edge_calc_result_metadata_controller = \
            EdgeCalcResultMetadataItemController.new( \
                    tree_item, \
                    tree, \
                    graph, \
                    failed_edge_attempt, \
                    edge_result_metadata)

func _calculate_edge_calc_result_metadata() -> void:
    edge_result_metadata = EdgeCalcResultMetadata.new(true)
    var start_position_along_surface := \
            MovementUtils.create_position_offset_from_target_point( \
                    failed_edge_attempt.start, \
                    failed_edge_attempt.origin_surface, \
                    graph.movement_params.collider_half_width_height)
    var end_position_along_surface := \
            MovementUtils.create_position_offset_from_target_point( \
                    failed_edge_attempt.end, \
                    failed_edge_attempt.destination_surface, \
                    graph.movement_params.collider_half_width_height)
    failed_edge_attempt.calculator.calculate_edge( \
            edge_result_metadata, \
            graph.collision_params, \
            start_position_along_surface, \
            end_position_along_surface, \
            failed_edge_attempt.velocity_start, \
            failed_edge_attempt.needs_extra_jump_duration, \
            failed_edge_attempt.needs_extra_wall_land_horizontal_speed)

func _destroy_children_inner() -> void:
    edge_calc_result_metadata_controller = null

func get_annotation_elements() -> Array:
    var element := FailedEdgeAttemptAnnotationElement.new( \
            failed_edge_attempt, \
            AnnotationElementDefaults.EDGE_DISCRETE_TRAJECTORY_COLOR_PARAMS, \
            AnnotationElementDefaults.FAILED_EDGE_ATTEMPT_COLOR_PARAMS, \
            AnnotationElementDefaults.FAILED_EDGE_ATTEMPT_DASH_LENGTH, \
            AnnotationElementDefaults.FAILED_EDGE_ATTEMPT_DASH_GAP, \
            AnnotationElementDefaults.FAILED_EDGE_ATTEMPT_DASH_STROKE_WIDTH, \
            false)
    return [element]