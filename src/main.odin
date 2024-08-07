package main

import "core:fmt"
import "core:os"


main :: proc()
{
        img_w :: 256
        img_h :: 256

        fmt.println("P3")
        fmt.println(img_w, img_h)
        fmt.println("255")

        for j in 0..<img_h {
                fmt.eprintf("\rScanlines remaining: %d ", img_h-j)
                for i in 0..<img_w {
                        pixel_color := Color {
                                f64(i) / (img_w-1),
                                f64(j) / (img_h-1),
                                0,
                        }

                        write_color(os.stdout, &pixel_color)
                }
        }

        fmt.eprintln("\rScanlines remaining: 0")
        fmt.eprintln("Done.")
}
