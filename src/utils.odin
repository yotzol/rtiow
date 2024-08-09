package main

import "core:math"
import "core:math/rand"


INFINITY :: math.INF_F64
PI       :: math.PI

to_rad   :: math.to_radians_f64
sqrt     :: math.sqrt_f64
random   :: proc{rand.float64, rand.float64_range}
abs      :: proc(n: f64) -> f64 {return n if n>0 else -n}
max      :: math.max
min      :: math.min
pow      :: math.pow
