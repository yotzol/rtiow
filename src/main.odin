package main

import "core:fmt"

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
                        r := f64(i) / (img_w-1)
                        g := f64(j) / (img_h-1)
                        b := 0.0

                        ir := u8(255.999 * r)
                        ig := u8(255.999 * g)
                        ib := u8(255.999 * b)

                        fmt.println(ir, ig, ib)
                }
        }

        fmt.eprintln("\rScanlines remaining: 0")
        fmt.eprintln("Done.")
}
