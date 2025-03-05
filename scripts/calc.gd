
class_name Calc


const icon_width_pixels = 80

const default_score:float = 25.0
const mob_spawn_timer_ms:float = 0.25
const bomb_spawn_frequency:int = 100
const floater_spawn_frequency:int = 25


const mob_velocity_avg:int = 250
const mob_velocity_variance:int = 50
const mob_velocity_max:int = mob_velocity_avg + mob_velocity_variance
const mob_velocity_min:int = mob_velocity_avg - mob_velocity_variance


# Calc mob and player size, based on the mob size or player score
static func calc_scale(size:float):
    var scale_value = max(0.99 + log(size / default_score), 0.3)
    return Vector2(scale_value, scale_value)


# Calc mob velocity, goes up as player_score gets higher
static func calc_mob_velocity(player_score:float):
    var multiplier = 1 + log(player_score / default_score)
    var horizontal_velocity = randf_range(mob_velocity_min, mob_velocity_max) * multiplier
    return Vector2(horizontal_velocity, 0.0)


static func calc_growth_amount(_player_score, _mob_size):
    return 1


static func calc_floater_growth_amount():
    return 2