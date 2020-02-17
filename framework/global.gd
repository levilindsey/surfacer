extends Node
class_name Global

const LEVEL_RESOURCE_PATHS := [
    "res://levels/level_1.tscn",
    "res://levels/level_2.tscn",
    "res://levels/level_3.tscn",
    "res://levels/level_4.tscn",
    "res://levels/level_5.tscn",
]

const TEST_RUNNER_SCENE_RESOURCE_PATH := "res://framework/test/tests.tscn"

const DEBUG_PANEL_RESOURCE_PATH := "res://framework/panels/debug_panel.tscn"
const WELCOME_PANEL_RESOURCE_PATH := "res://framework/panels/welcome_panel.tscn"

const IN_DEBUG_MODE := true
const IN_TEST_MODE := false

const STARTING_LEVEL_RESOURCE_PATH := "res://framework/test/test_data/test_level_long_rise.tscn"
#const STARTING_LEVEL_RESOURCE_PATH := "res://framework/test/test_data/test_level_long_fall.tscn"
#const STARTING_LEVEL_RESOURCE_PATH := "res://framework/test/test_data/test_level_far_distance.tscn"
#const STARTING_LEVEL_RESOURCE_PATH := "res://levels/level_3.tscn"
#const STARTING_LEVEL_RESOURCE_PATH := "res://levels/level_4.tscn"
#const STARTING_LEVEL_RESOURCE_PATH := "res://levels/level_5.tscn"

const PLAYER_RESOURCE_PATH := "res://players/cat_player.tscn"
#const PLAYER_RESOURCE_PATH := "res://framework/test/test_data/test_player.tscn"

const DEBUG_STATE := {
    in_debug_mode = IN_DEBUG_MODE,
    limit_parsing = {
        player_name = "cat",
#        
#        edge = {
#            origin = {
#                surface_side = SurfaceSide.FLOOR,
#            },
#            destination = {
#                surface_side = SurfaceSide.LEFT_WALL,
#            },
#        },
#        
#        movement_calculator = "ClimbOverWallToFloorCalculator",
#        movement_calculator = "FallFromWallCalculator",
        movement_calculator = "FallFromFloorCalculator",
#        movement_calculator = "JumpFromSurfaceToSurfaceCalculator",
#        movement_calculator = "ClimbDownWallToFloorCalculator",
#        movement_calculator = "WalkToAscendWallFromFloorCalculator",
#        
#        # Level: long rise; fall-from-wall
#        edge = {
#            origin = {
#                surface_side = SurfaceSide.LEFT_WALL,
#                surface_start_vertex = Vector2(0, -448),
#                surface_end_vertex = Vector2(0, -384),
#                position = Vector2(0, -448),
#            },
#            destination = {
#                surface_side = SurfaceSide.FLOOR,
#                surface_start_vertex = Vector2(128, 64),
#                surface_end_vertex = Vector2(192, 64),
#                position = Vector2(128, 64),
#            },
#        },
#        
#        # Level: long rise; jump-up-left
#        edge = {
#            origin = {
#                surface_side = SurfaceSide.FLOOR,
#                surface_start_vertex = Vector2(128, 64),
#                surface_end_vertex = Vector2(192, 64),
#                position = Vector2(128, 64),
#            },
#            destination = {
#                surface_side = SurfaceSide.FLOOR,
#                surface_start_vertex = Vector2(-128, -448),
#                surface_end_vertex = Vector2(0, -448),
#                position = Vector2(-128, -448),
#            },
#        },
    },
}

const NAVIGATOR_STATE := {
    forces_player_position_to_match_edge_at_start = true,
    forces_player_velocity_to_match_edge_at_start = true,
    forces_player_position_to_match_edge_in_middle = true,
    forces_player_velocity_to_match_edge_in_middle = true,
}

const PLAYER_ACTIONS := {}

const EDGE_MOVEMENTS := {}

# Dictionary<String, PlayerTypeConfiguration>
var player_types := {}

var debug_panel: DebugPanel
var welcome_panel: WelcomePanel

var space_state: Physics2DDirectSpaceState

var current_level
var current_player_for_clicks
var camera_controller: CameraController

# Keeps track of the current total elapsed time of unpaused gameplay.
var elapsed_play_time_sec: float setget ,_get_elapsed_play_time_sec

# TODO: Verify that all render-frame _process calls in the scene tree happen without interleaving
#       with any _physics_process calls from other nodes in the scene tree.
var _elapsed_latest_play_time_sec: float
var _elapsed_physics_play_time_sec: float
var _elapsed_render_play_time_sec: float

func get_is_paused() -> bool:
    return get_tree().paused

func pause() -> void:
    get_tree().paused = true

func unpause() -> void:
    get_tree().paused = false

func register_player_actions(player_action_classes: Array) -> void:
    # Instantiate the various PlayerActions.
    for player_action_class in player_action_classes:
        PLAYER_ACTIONS[player_action_class.NAME] = player_action_class.new()

func register_edge_movements(edge_movement_classes: Array) -> void:
    # Instantiate the various EdgeMovements.
    for edge_movement_class in edge_movement_classes:
        EDGE_MOVEMENTS[edge_movement_class.NAME] = edge_movement_class.new()

func register_player_params(player_param_classes: Array) -> void:
    var params
    var type: PlayerTypeConfiguration
    for param_class in player_param_classes:
        params = param_class.new(self)
        type = params.get_player_type_configuration()
        self.player_types[type.name] = type

func _ready() -> void:
    _elapsed_physics_play_time_sec = 0.0
    _elapsed_render_play_time_sec = 0.0
    _elapsed_latest_play_time_sec = 0.0

func _process(delta: float) -> void:
    _elapsed_render_play_time_sec += delta
    _elapsed_latest_play_time_sec = _elapsed_render_play_time_sec

func _physics_process(delta: float) -> void:
    _elapsed_physics_play_time_sec += delta
    _elapsed_latest_play_time_sec = _elapsed_physics_play_time_sec

func _get_elapsed_play_time_sec() -> float:
    return _elapsed_latest_play_time_sec

func add_overlay_to_current_scene(node: Node) -> void:
    get_tree().get_current_scene().add_child(node)
