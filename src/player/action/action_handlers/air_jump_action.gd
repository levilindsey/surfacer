class_name AirJumpAction
extends PlayerActionHandler


const NAME := "AirJumpAction"
const TYPE := SurfaceType.AIR
const USES_RUNTIME_PHYSICS := true
const PRIORITY := 320


func _init().(
        NAME,
        TYPE,
        USES_RUNTIME_PHYSICS,
        PRIORITY) -> void:
    pass


func process(player) -> bool:
    if player.actions.just_pressed_jump and \
            player.jump_count < player.movement_params.max_jump_chain:
        player.jump_count += 1
        player.just_triggered_jump = true
        player.is_rising_from_jump = true
        player.velocity.y = player.movement_params.jump_boost

        return true
    else:
        return false
