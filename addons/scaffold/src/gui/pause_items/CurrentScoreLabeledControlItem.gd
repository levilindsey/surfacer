extends TextLabeledControlItem
class_name CurrentScoreLabeledControlItem

const LABEL := "Current score:"
const DESCRIPTION := ""

func _init(__ = null).( \
        LABEL, \
        DESCRIPTION \
        ) -> void:
    pass

func get_text() -> String:
    return str(int(Gs.level.score)) if \
            is_instance_valid(Gs.level) else \
            "—"
