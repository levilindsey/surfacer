extends InspectorItemController
class_name EdgesTopLevelGroupItemController

const TYPE := InspectorItemType.EDGES_TOP_LEVEL_GROUP
const STARTS_COLLAPSED := true
const PREFIX := "Edges"

var graph: PlatformGraph

func _init( \
        parent_item: TreeItem, \
        tree: Tree, \
        graph: PlatformGraph) \
        .( \
        TYPE, \
        STARTS_COLLAPSED, \
        parent_item, \
        tree) -> void:
    self.graph = graph
    _update_text()

func get_text() -> String:
    return "%s [%s]" % [ \
        PREFIX, \
        graph.counts.total_edges, \
    ]

func to_string() -> String:
    return "%s { count=%s }" % [ \
        InspectorItemType.get_type_string(type), \
        graph.counts.total_edges, \
    ]

func find_and_expand_controller( \
        search_type: int, \
        metadata: Dictionary) -> InspectorItemController:
    Utils.error("find_and_expand_controller should not be called for EDGES_TOP_LEVEL_GROUP.")
    return null

func _create_children() -> void:
    for edge_type in EdgeType.values():
        if InspectorItemController.EDGE_TYPES_TO_SKIP.find(edge_type) >= 0:
            continue
        EdgeTypeInEdgesGroupItemController.new( \
                tree_item, \
                tree, \
                graph, \
                edge_type)

func _destroy_children() -> void:
    for child in tree_item.get_children():
        child.get_metadata(0).destroy()

func _draw_annotations() -> void:
    # FIXME: -----------------
    pass
