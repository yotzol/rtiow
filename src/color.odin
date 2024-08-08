package main

import "core:os"
import "core:fmt"


Color :: Vec3

@(private="file")
INTENSITY :: Interval{0.000, 0.999}

write_color :: proc(out: os.Handle, color: ^Color) {
        r_byte := u8(256 * clamp(INTENSITY, color.r))
        g_byte := u8(256 * clamp(INTENSITY, color.g))
        b_byte := u8(256 * clamp(INTENSITY, color.b))

        fmt.fprintln(out, r_byte, g_byte, b_byte)
}
