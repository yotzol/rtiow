package main

Interval :: struct { min, max: f64 }

EMPTY    :: Interval{+INFINITY, -INFINITY}
UNIVERSE :: Interval{-INFINITY, +INFINITY}

interval_new :: proc{interval_new_from_values, interval_new_from_intervals}

interval_new_from_values :: proc(min, max: f64) -> Interval {
        return {min, max}
}

interval_new_from_intervals :: proc(a, b: Interval) -> Interval {
        return {min(a.min, b.min), max(a.max, b.max)}
}

interval_size :: proc(i: Interval) -> f64 {
        return i.max - i.min
}

interval_contains :: proc(i: Interval, n: f64) -> bool {
        return i.min <= n && n <= i.max
}

interval_surrounds :: proc(i: Interval, n: f64) -> bool {
        return i.min < n && n < i.max
}

clamp :: proc(i: Interval, n: f64) -> f64 {
        switch {
        case n < i.min: return i.min
        case n > i.max: return i.max
        case:           return n
        }
}

expand :: proc(i: Interval, delta: f64) -> Interval {
        padding := delta / 2
        return {i.min-padding, i.max+padding}
}
