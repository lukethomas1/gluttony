
class_name Calc


const default_score:float = 10.0
const icon_width_pixels = 128


# Calc mob and player size, based on the mob size or player score
static func calc_scale(size:float):
    var scale_value = 1 + log(size / default_score)
    return Vector2(scale_value, scale_value)


# Calc mob velocity, goes up as player_score gets higher
static func calc_mob_velocity(player_score:float):
    var multiplier = 1 + log(player_score / default_score)
    var horizontal_velocity = randf_range(150.0, 250.0) * multiplier
    return Vector2(horizontal_velocity, 0.0)


static func calc_growth_amount(_player_score, _mob_size):
    return 0.5