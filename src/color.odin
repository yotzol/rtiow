package main

import "core:os"
import "core:fmt"


Color :: Vec3

@(private="file")
INTENSITY :: Interval{0.000, 0.999}

write_color :: proc(out: os.Handle, color: ^Color) {
        r := linear_to_gamma(color.r)
        g := linear_to_gamma(color.g)
        b := linear_to_gamma(color.b)
        
        r_byte := u8(256 * clamp(INTENSITY, r))
        g_byte := u8(256 * clamp(INTENSITY, g))
        b_byte := u8(256 * clamp(INTENSITY, b))

        fmt.fprintln(out, r_byte, g_byte, b_byte)
}

linear_to_gamma :: proc(linear_component: f64) -> f64 {
        return sqrt(linear_component) if linear_component > 0 else 0
}
