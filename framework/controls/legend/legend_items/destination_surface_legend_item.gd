extends SurfaceLegendItem
class_name DestinationSurfaceLegendItem

const TYPE := LegendItemType.DESTINATION_SURFACE
const TEXT := "Destination\nsurface"
var COLOR_PARAMS: ColorParams = \
        AnnotationElementDefaults.DESTINATION_SURFACE_COLOR_PARAMS

func _init().( \
        TYPE, \
        TEXT, \
        COLOR_PARAMS) -> void:
    pass