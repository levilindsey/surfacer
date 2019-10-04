# A start/end position for movement step calculation.
# 
# This is used internally to make edge calculation easier.
# 
# - For the overall origin/destination points of movement, a constraint could be any point along a
#   surface or any point not along a surface.
# - For all other, intermediate points within a movement, a constraint represents the edge of a
#   surface that the movement must pass through in order to not collide with the surface.
# - Early on, each constraint is assigned a horizontal direction that the movement must travel
#   along when passing through the constraint:
#   - For constraints on left-wall surfaces: The direction of movement must be leftward.
#   - For constraints on right-wall surfaces: The direction of movement must be rightward. 
#   - For constraints on floor/ceiling surfaces, we instead look at whether the constraint is on
#     the left or right side of the surface.
#     - For constraints on the left-side: The direction of movement must be leftward.
#     - For constraints on the right-side: The direction of movement must be rightward.
extends Reference
class_name MovementConstraint

# The surface that was collided with.
var surface: Surface

# This point represents the Player's position (i.e., the Player's center), NOT the corner of the
# Surface.
var position: Vector2

var passing_vertically: bool

var should_stay_on_min_side: bool

# The sign of the horizontal movement when passing through this constraint. This is primarily
# calculated according to the surface-side and whether the constraint is on the min or max side of
# the surface.
var horizontal_movement_sign: int = INF

# The sign of horizontal movement from the previous constraint to this constraint. This should
# always agree with the surface-side-based horizontal_movement_sign property, unless this
# constraint is fake and should be skipped.
var horizontal_movement_sign_from_displacement: int = INF

# The time at which movement should pass through this constraint.
var time_passing_through := INF

# The minimum possible x velocity when passing through this constraint.
var min_velocity_x := INF

# The maximum possible x velocity when passing through this constraint.
var max_velocity_x := INF

var actual_velocity_x := INF

# Whether this constraint is the origin for the overall movement.
var is_origin := false

# Whether this constraint is the destination for the overall movement.
var is_destination := false

# Fake constraints will be skipped by the final overall movement. They represent a point along an
# edge of a floor or ceiling surface where the horizontal_movement_sign_from_surface differs from
# the horizontal_movement_sign_from_displacement.
# 
# For example, the right-side of a ceiling surface when the jump movement is from the lower-right
# of the edge; in this case, the goal is to skip the ceiling-edge constraint and moving directly to
# the top-of-the-right-side constraint.
var is_fake := false

func _init(surface: Surface, position: Vector2, passing_vertically: bool, \
        should_stay_on_min_side: bool) -> void:
    self.surface = surface
    self.position = position
    self.passing_vertically = passing_vertically
    self.should_stay_on_min_side = should_stay_on_min_side