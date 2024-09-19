package main

import "core:math"
import "core:math/rand"
import "base:intrinsics"


INFINITY :: math.INF_F64
PI       : f64 : math.PI

to_rad   :: math.to_radians_f64
sqrt     :: math.sqrt_f64
random   :: proc{rand.float64, rand.float64_range}
rand_int :: proc{rand_int_default, rand_int_range}
abs      :: proc(n: $T) -> T where intrinsics.type_is_numeric(T) {return n if n>0 else -n}
max      :: math.max
min      :: math.min
pow      :: math.pow
tan      :: math.tan
cos      :: math.cos
sin      :: math.sin

rand_int_range :: proc(start, end: int) -> int {
        return int(random(f64(start), f64(end+1)))
}

rand_int_default :: proc() -> int {
        return int(random())
}
