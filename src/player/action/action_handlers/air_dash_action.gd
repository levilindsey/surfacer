class_name AirDashAction
extends PlayerActionHandler


const NAME := "AirDashAction"
const TYPE := SurfaceType.AIR
const USES_RUNTIME_PHYSICS := true
const PRIORITY := 330


func _init().(
        NAME,
        TYPE,
        USES_RUNTIME_PHYSICS,
        PRIORITY) -> void:
    pass


func process(player) -> bool:
    if player.actions.start_dash:
        player.start_dash(player.surface_state.horizontal_facing_sign)
        return true
    else:
        return false
