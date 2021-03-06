class_name WallFallAction
extends PlayerActionHandler


const NAME := "WallFallAction"
const TYPE := SurfaceType.WALL
const USES_RUNTIME_PHYSICS := true
const PRIORITY := 130


func _init().(
        NAME,
        TYPE,
        USES_RUNTIME_PHYSICS,
        PRIORITY) -> void:
    pass


func process(player) -> bool:
    if !player.processed_action(WallJumpAction.NAME) and \
            player.surface_state.is_pressing_away_from_wall:
        player.release_wall()
        # Cancel any velocity toward the wall.
        player.velocity.x = \
                -player.surface_state.toward_wall_sign * \
                player.movement_params.wall_fall_horizontal_boost
        return true
    else:
        return false
