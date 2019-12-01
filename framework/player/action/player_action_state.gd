extends Reference
class_name PlayerActionState

var delta: float

var pressed_jump := false
var just_pressed_jump := false
var just_released_jump := false

var pressed_up := false
var just_pressed_up := false
var just_released_up := false

var pressed_down := false
var just_pressed_down := false
var just_released_down := false

var pressed_left := false
var just_pressed_left := false
var just_released_left := false

var pressed_right := false
var just_pressed_right := false
var just_released_right := false

var start_dash := false

func clear() -> void:
    self.delta = INF
    
    self.pressed_jump = false
    self.just_pressed_jump = false
    self.just_released_jump = false
    
    self.pressed_up = false
    self.just_pressed_up = false
    self.just_released_up = false
    
    self.pressed_down = false
    self.just_pressed_down = false
    self.just_released_down = false
    
    self.pressed_left = false
    self.just_pressed_left = false
    self.just_released_left = false
    
    self.pressed_right = false
    self.just_pressed_right = false
    self.just_released_right = false
    
    self.start_dash = false

func copy(other: PlayerActionState) -> void:
    self.delta = other.delta
    
    self.pressed_jump = other.pressed_jump
    self.just_pressed_jump = other.just_pressed_jump
    self.just_released_jump = other.just_released_jump
    
    self.pressed_up = other.pressed_up
    self.just_pressed_up = other.just_pressed_up
    self.just_released_up = other.just_released_up
    
    self.pressed_down = other.pressed_down
    self.just_pressed_down = other.just_pressed_down
    self.just_released_down = other.just_released_down
    
    self.pressed_left = other.pressed_left
    self.just_pressed_left = other.just_pressed_left
    self.just_released_left = other.just_released_left
    
    self.pressed_right = other.pressed_right
    self.just_pressed_right = other.just_pressed_right
    self.just_released_right = other.just_released_right
    
    self.start_dash = other.start_dash

func log_new_presses_and_releases(player, time_sec: float) -> void:
    _log_new_press_or_release(player.player_name, "jump", just_pressed_jump, just_released_jump, \
            time_sec, player.surface_state.center_position, player.velocity)
    _log_new_press_or_release(player.player_name, "up", just_pressed_up, just_released_up, \
            time_sec, player.surface_state.center_position, player.velocity)
    _log_new_press_or_release(player.player_name, "down", just_pressed_down, just_released_down, \
            time_sec, player.surface_state.center_position, player.velocity)
    _log_new_press_or_release(player.player_name, "left", just_pressed_left, just_released_left, \
            time_sec, player.surface_state.center_position, player.velocity)
    _log_new_press_or_release(player.player_name, "right", just_pressed_right, \
            just_released_right, time_sec, player.surface_state.center_position, player.velocity)
    _log_new_press_or_release(player.player_name, "dash", start_dash, false, time_sec, \
            player.surface_state.center_position, player.velocity)

func _log_new_press_or_release(player_name: String, action_name: String, just_pressed: bool, \
        just_released: bool, time_sec: float, player_position: Vector2, \
        player_velocity: Vector2) -> void:
    if just_pressed:
        print("START %5s:%8s;%8.3f;%29sP;%29sV" % [action_name, player_name, time_sec, \
                player_position, player_velocity])
    if just_released:
        print("STOP  %5s:%8s;%8.3f;%29sP;%29sV" % [action_name, player_name, time_sec, \
                player_position, player_velocity])
