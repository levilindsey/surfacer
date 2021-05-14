class_name NavigationPulseAnnotator
extends Node2D

var navigator: Navigator
var current_path: PlatformGraphPath
var is_slow_motion_enabled := false
var current_path_start_time := -INF
var current_path_elapsed_time := INF
var current_path_pulse_duration := 0.0
var is_pulse_active := false

func _init(navigator: Navigator) -> void:
    self.navigator = navigator

func _physics_process(_delta_sec: float) -> void:
    if navigator.current_path != current_path:
        current_path = navigator.current_path
        if current_path != null:
            current_path_start_time = Gs.time.get_play_time_sec()
            is_pulse_active = true
            current_path_pulse_duration = \
                    current_path.duration * \
                    Surfacer.new_path_pulse_duration_multiplier
        update()
    
    if Surfacer.slow_motion.is_enabled != is_slow_motion_enabled:
        is_slow_motion_enabled = Surfacer.slow_motion.is_enabled
        update()
    
    if is_pulse_active:
        current_path_elapsed_time = \
                Gs.time.get_play_time_sec() - current_path_start_time
        is_pulse_active = \
                current_path_elapsed_time < current_path_pulse_duration
        update()

func _draw() -> void:
    if current_path == null or \
            !is_pulse_active or \
            Gs.level.get_is_intro_choreography_running():
        return
    
    if navigator.player.is_human_player:
        if is_slow_motion_enabled and \
                !Surfacer \
                    .is_human_nav_pulse_shown_with_slow_mo or \
                !is_slow_motion_enabled and \
                !Surfacer \
                    .is_human_nav_pulse_shown_without_slow_mo:
            return
    else:
        if is_slow_motion_enabled and \
                !Surfacer \
                    .is_computer_nav_pulse_shown_with_slow_mo or \
                !is_slow_motion_enabled and \
                !Surfacer \
                    .is_computer_nav_pulse_shown_without_slow_mo:
            return
    
    var progress := current_path_elapsed_time / current_path_pulse_duration
    progress = Gs.utils.ease_by_name(progress, "ease_out")
    
    if progress < 0.0001 or \
            progress > 0.9999:
        return
    
    var half_pulse_time_length: float = \
            Surfacer.new_path_pulse_time_length / 2.0
    var path_duration_with_margin: float = \
            current_path.duration + Surfacer.new_path_pulse_time_length
    var path_segment_time_center := \
            path_duration_with_margin * progress - half_pulse_time_length
    var path_segment_time_start := max(
            path_segment_time_center - half_pulse_time_length,
            0.0)
    var path_segment_time_end := min(
            path_segment_time_center + half_pulse_time_length,
            current_path.duration)
    
    var path_color: Color = \
            Surfacer.ann_defaults \
                    .HUMAN_NAVIGATOR_PULSE_PATH_COLOR if \
            navigator.player.is_human_player else \
            Surfacer.ann_defaults.COMPUTER_NAVIGATOR_PULSE_PATH_COLOR
    var trim_front_end_radius := 0.0
    var trim_back_end_radius := 0.0
    
    Gs.draw_utils.draw_path_duration_segment(
            self,
            current_path,
            path_segment_time_start,
            path_segment_time_end,
            AnnotationElementDefaults.NAVIGATOR_PULSE_STROKE_WIDTH,
            path_color,
            trim_front_end_radius,
            trim_back_end_radius)
