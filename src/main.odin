package main

import "core:fmt"
import "core:os"


main :: proc()
{
        aspect_ratio : f64 = 16.0 / 9.0
        image_width  : int = 400

        init_camera(aspect_ratio, image_width)

        world: HittableList
        append(&world, Sphere{{0,     0,-1}, 0.5})
        append(&world, Sphere{{0,-100.5,-1}, 100})

        render(&world)

        fmt.eprintln("\rScanlines remaining: 0")
        fmt.eprintln("Done.")
}

