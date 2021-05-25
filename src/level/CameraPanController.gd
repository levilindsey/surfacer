class_name CameraPanController
extends Node2D

const _PAN_THROTTLE_INTERVAL_SEC := 0.05
const _TWEEN_DURATION := 0.1

var _last_pointer_position := Vector2.INF
var _throttled_set_new_drag_position: FuncRef = Gs.time.throttle(
        funcref(self, "_update_camera_from_pointer"),
        _PAN_THROTTLE_INTERVAL_SEC)

var _tween: ScaffolderTween

var _offset := Vector2.ZERO
var _zoom_multiplier := 1.0

func _init() -> void:
    _tween = ScaffolderTween.new()
    add_child(_tween)

func _unhandled_input(event: InputEvent) -> void:
    if !Gs.is_user_interaction_enabled:
        return
    
    var is_control_pressed := \
            Gs.level_input.is_key_pressed(KEY_CONTROL) or \
            Gs.level_input.is_key_pressed(KEY_META)
    
    if is_control_pressed:
        _stop_drag()
    
    # Touch-up: Position selection.
    if event is InputEventScreenTouch and \
            !event.pressed:
        _stop_drag()
    
    var pointer_drag_position := Vector2.INF
    
    # Touch-down: Position pre-selection.
    if event is InputEventScreenTouch and \
            event.pressed:
        pointer_drag_position = Gs.utils.get_level_touch_position(event)
    
    # Touch-move: Position pre-selection.
    if event is InputEventScreenDrag:
        pointer_drag_position = Gs.utils.get_level_touch_position(event)
    
    if pointer_drag_position != Vector2.INF:
        _update_drag(pointer_drag_position)

# FIXME: ------------------------------------------
# - Move these flags out to Surfacer.
var keeps_camera_anchored_on_player := true
var max_zoom_multiplier_from_pointer := 1.5
var max_pan_distance_from_pointer := 1024.0
var duration_to_max_pan_and_zoom_from_pointer_at_max_control := 1.0
var screen_size_ratio_distance_from_edge_to_start_pan_from_pointer := 0.25
func _validate() -> void:
    assert(max_zoom_multiplier_from_pointer >= 1.0)
    assert(max_pan_distance_from_pointer >= 0.0)
    assert(screen_size_ratio_distance_from_edge_to_start_pan_from_pointer <= \
            0.5 and \
            screen_size_ratio_distance_from_edge_to_start_pan_from_pointer > \
            0.0)

func _stop_drag() -> void:
    _last_pointer_position = Vector2.INF
    Gs.time.cancel_pending_throttle(_throttled_set_new_drag_position)
    if keeps_camera_anchored_on_player:
        _update_camera(Vector2.ZERO, 1.0)

func _update_drag(pointer_position: Vector2) -> void:
    _last_pointer_position = pointer_position
    _throttled_set_new_drag_position.call_func()

func _update_camera_from_pointer() -> void:
    assert(_last_pointer_position != Vector2.INF)
    
    # Calculate the camera bounds and the region that controls pan and zoom.
    var pointer_max_control_bounds := Gs.camera_controller.get_bounds()
    var camera_center := \
            pointer_max_control_bounds.position + \
            pointer_max_control_bounds.size / 2.0
    var min_control_bounds_size := \
            pointer_max_control_bounds.size * \
            (1 - \
            screen_size_ratio_distance_from_edge_to_start_pan_from_pointer * 2)
    var min_control_bounds_position := \
            pointer_max_control_bounds.position + \
            pointer_max_control_bounds.size * \
            screen_size_ratio_distance_from_edge_to_start_pan_from_pointer
    var pointer_min_control_bounds := Rect2(
            min_control_bounds_position,
            min_control_bounds_size)
    
    # FIXME: -------------------------------
    print(">>>>pointer_max_control_bounds.position = %s" % pointer_max_control_bounds.position)
    print(">>>>pointer_max_control_bounds.end = %s" % pointer_max_control_bounds.end)
    print(">>>>_last_pointer_position = %s" % _last_pointer_position)
    
    # Calculate drag control weights according to the pointer position.
    var pan_zoom_control_weight_x: float
    if _last_pointer_position.x < camera_center.x:
        # FIXME: -------------- Add these asserts back in?
#        assert(_last_pointer_position.x >= \
#                pointer_max_control_bounds.position.x - 2)
        _last_pointer_position.x = max(
                _last_pointer_position.x,
                pointer_max_control_bounds.position.x)
        if _last_pointer_position.x < pointer_min_control_bounds.position.x:
            # Dragging left.
            pan_zoom_control_weight_x = \
                    -1 * \
                    (pointer_min_control_bounds.position.x - \
                            _last_pointer_position.x) / \
                    (pointer_min_control_bounds.position.x - \
                            pointer_max_control_bounds.position.x)
    else:
#        assert(_last_pointer_position.x <= \
#                pointer_max_control_bounds.end.x + 2)
        _last_pointer_position.x = min(
                _last_pointer_position.x,
                pointer_max_control_bounds.end.x)
        if _last_pointer_position.x > pointer_min_control_bounds.end.x:
            # Dragging right.
            pan_zoom_control_weight_x = \
                    (_last_pointer_position.x - \
                            pointer_min_control_bounds.end.x) / \
                    (pointer_max_control_bounds.end.x - \
                            pointer_min_control_bounds.end.x)
    var pan_zoom_control_weight_y: float
    if _last_pointer_position.y < camera_center.y:
#        assert(_last_pointer_position.y >= \
#                pointer_max_control_bounds.position.y - 2)
        _last_pointer_position.y = max(
                _last_pointer_position.y,
                pointer_max_control_bounds.position.y)
        if _last_pointer_position.y < pointer_min_control_bounds.position.y:
            # Dragging up.
            pan_zoom_control_weight_y = \
                    -1 * \
                    (pointer_min_control_bounds.position.y - \
                            _last_pointer_position.y) / \
                    (pointer_min_control_bounds.position.y - \
                            pointer_max_control_bounds.position.y)
    else:
#        assert(_last_pointer_position.y <= \
#                pointer_max_control_bounds.end.y + 2)
        _last_pointer_position.y = min(
                _last_pointer_position.y,
                pointer_max_control_bounds.end.y)
        if _last_pointer_position.y > pointer_min_control_bounds.end.y:
            # Dragging down.
            pan_zoom_control_weight_y = \
                    (_last_pointer_position.y - \
                            pointer_min_control_bounds.end.y) / \
                    (pointer_max_control_bounds.end.y - \
                            pointer_min_control_bounds.end.y)
    
    # Calcute the pan and zoom deltas for the current frame and drag weight.
    var per_frame_ratio := \
            _PAN_THROTTLE_INTERVAL_SEC / \
            duration_to_max_pan_and_zoom_from_pointer_at_max_control
    var max_pan_distance_per_frame := \
            max_pan_distance_from_pointer * per_frame_ratio
    var max_zoom_delta_per_frame := \
            max_zoom_multiplier_from_pointer * per_frame_ratio
    var delta_offset_x := \
            pan_zoom_control_weight_x * max_pan_distance_per_frame
    var delta_offset_y := \
            pan_zoom_control_weight_y * max_pan_distance_per_frame
    var delta_zoom := \
            max(abs(pan_zoom_control_weight_x),
                abs(pan_zoom_control_weight_y)) * \
            max_zoom_delta_per_frame
    
    # FIXME: LEFT OFF HERE: ------------------------------------------
    # - Relax pan/zoom back when still pressing, but dragged back to center?
    # - Ease-out the delta according to how close we are to the max offset?
    
    var next_offset: Vector2
    var next_zoom_multiplier: float
    if keeps_camera_anchored_on_player:
        next_offset = _offset + Vector2(delta_offset_x, delta_offset_y)
        next_zoom_multiplier = _zoom_multiplier + delta_zoom
    else:
        next_offset = _offset + Vector2(delta_offset_x, delta_offset_y)
        next_zoom_multiplier = 1.0
    
    # Don't let the pan and zoom exceed their max bounds.
    next_offset.x = clamp(
            next_offset.x,
            -max_pan_distance_from_pointer,
            max_pan_distance_from_pointer)
    next_offset.y = clamp(
            next_offset.y,
            -max_pan_distance_from_pointer,
            max_pan_distance_from_pointer)
    next_zoom_multiplier = clamp(
            next_zoom_multiplier,
            1.0,
            max_zoom_multiplier_from_pointer)
    
    _update_camera(next_offset, next_zoom_multiplier)

func _update_camera(
        pan: Vector2,
        zoom: float) -> void:
    _tween.stop_all()
    _tween.interpolate_method(
            self,
            "_update_pan",
            _offset,
            pan,
            _TWEEN_DURATION,
            "linear",
            0.0,
            TimeType.PLAY_PHYSICS)
    _tween.interpolate_method(
            self,
            "_update_zoom",
            _zoom_multiplier,
            zoom,
            _TWEEN_DURATION,
            "linear",
            0.0,
            TimeType.PLAY_PHYSICS)
    _tween.start()

func _update_pan(offset: Vector2) -> void:
    var delta := offset - self._offset
    self._offset = offset
    Gs.camera_controller.offset += delta

func _update_zoom(zoom_multiplier: float) -> void:
    var delta := zoom_multiplier - self._zoom_multiplier
    self._zoom_multiplier = zoom_multiplier
    Gs.camera_controller.zoom_factor += delta
