extends Node2D
class_name GridIndicesAnnotator

var TILE_INDICES_COLOR := Color.from_hsv(0.0, 0.0, 1.0, 0.6)

var graph: PlatformGraph

func _init(graph: PlatformGraph) -> void:
    self.graph = graph

func _draw() -> void:
    _draw_tile_indices()

func _draw_tile_indices(only_render_used_indices := false) -> void:
    var half_cell_size: Vector2
    var positions: Array
    var cell_center: Vector2
    var tile_map_index: int
    var color = TILE_INDICES_COLOR
    
    var label = Label.new()
    var font = label.get_font("")
    
    for tile_map in graph.surface_parser._tile_map_index_to_surface_maps:
        half_cell_size = tile_map.cell_size / 2
        
        if only_render_used_indices:
            positions = tile_map.get_used_cells()
        else:
            var tile_map_used_rect = tile_map.get_used_rect()
            var tile_map_start_x = tile_map_used_rect.position.x
            var tile_map_start_y = tile_map_used_rect.position.y
            var tile_map_width = tile_map_used_rect.size.x
            var tile_map_height = tile_map_used_rect.size.y
            positions = []
            positions.resize(tile_map_width * tile_map_height)
            for y in range(tile_map_height):
                for x in range(tile_map_width):
                    positions[y * tile_map_width + x] = \
                            Vector2(x + tile_map_start_x, y + tile_map_start_y)
        
        for position in positions:
            cell_center = tile_map.map_to_world(position) + half_cell_size
            tile_map_index = Geometry.get_tile_map_index_from_grid_coord(position, tile_map)
            draw_string(font, cell_center, str(tile_map_index), color)
            draw_circle(cell_center, 1.0, color)
    
    label.free()