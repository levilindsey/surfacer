extends Reference
class_name MovementTrajectory

# The positions of each frame of movement according to the discrete per-frame movement
# calculations of the instruction test. This is used for annotation debugging.
# 
# - This is rendered by the annotator as the _lighter_ path.
# - This more accurately reflects actual run-time movement.
var frame_discrete_positions_from_test: PoolVector2Array

# The positions of each frame of movement according to the continous per-frame movement
# calculations of the underlying horizontal step calculations.
# 
# - This is rendered by the annotator as the _darker_ path.
# - This less accurately reflects actual run-time movement.
var frame_continuous_positions_from_steps: PoolVector2Array

# The velocities of each frame of movement according to the continous per-frame movement
# calculations of the underlying horizontal step calculations.
var frame_continuous_velocities_from_steps: PoolVector2Array

# The end positions of each MovementCalcStep. These correspond to intermediate-surface constraints
# and the destination position. This is used for annotation debugging.
var constraint_positions: PoolVector2Array

var horizontal_instruction_start_positions: PoolVector2Array

var horizontal_instruction_end_positions: PoolVector2Array

var jump_instruction_end_position := Vector2.INF

var distance_from_continuous_frames: float

func _init(frame_continuous_positions_from_steps: PoolVector2Array, \
            frame_continuous_velocities_from_steps: PoolVector2Array, \
            constraint_positions: Array,
            distance_from_continuous_frames: float) -> void:
    self.frame_continuous_positions_from_steps = frame_continuous_positions_from_steps
    self.frame_continuous_velocities_from_steps = frame_continuous_velocities_from_steps
    self.constraint_positions = PoolVector2Array(constraint_positions)
    self.distance_from_continuous_frames = distance_from_continuous_frames