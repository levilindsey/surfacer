extends PlayerActionHandler
class_name AirJumpAction

const NAME := 'AirJumpAction'
const TYPE := PlayerActionType.AIR
const PRIORITY := 320

func _init().(NAME, TYPE, PRIORITY) -> void:
    pass

func process(player: Player) -> bool:
    if player.actions.just_pressed_jump and \
            player.jump_count < player.movement_params.max_jump_chain:
        player.jump_count += 1
        player.is_ascending_from_jump = true
        player.velocity.y = player.movement_params.jump_boost

        return true
    else:
        return false