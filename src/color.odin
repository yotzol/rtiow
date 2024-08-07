package main

import "core:os"
import "core:fmt"


Color :: Vec3

write_color :: proc(out: os.Handle, color: ^Color) {
        r_byte := u8(255.999 * color.r)
        g_byte := u8(255.999 * color.g)
        b_byte := u8(255.999 * color.b)

        fmt.fprintln(out, r_byte, g_byte, b_byte)
}
