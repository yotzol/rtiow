package main

Interval :: struct { min, max: f64 }

EMPTY    :: Interval{+INFINITY, -INFINITY}
UNIVERSE :: Interval{-INFINITY, +INFINITY}

interval_size :: proc(i: Interval) -> f64 {
        return i.max - i.min
}

interval_contains :: proc(i: Interval, n: f64) -> bool {
        return i.min <= n && n <= i.max
}

interval_surrounds :: proc(i: Interval, n: f64) -> bool {
        return i.min < n && n < i.max
}

