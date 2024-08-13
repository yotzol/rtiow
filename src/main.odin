package main

import "core:fmt"
import "core:os"


main :: proc()
{
        R := cos(PI/4)

        camera_config := CameraSettings {
                aspect_ratio         = 16.0 / 9.0,
                image_width          = 400,
                samples_per_pixel    = 100,
                max_depth            = 50,
                field_of_view        = 20,
                look_from            = {-2,2,1},
                look_at              = {0,0,-1},
                vector_up            = {0,1, 0},
        }

        init_camera(camera_config)

        mat_ground : Material = Lambertian{{0.8,0.8,0.0}}
        mat_center : Material = Lambertian{{0.1,0.2,0.5}}
        mat_left   : Material = Dielectric{1.5}
        mat_bubble : Material = Dielectric{1/1.5}
        mat_right  : Material = Metal{{0.8,0.6,0.2},1.0}

        world: HittableList
        append(&world, Sphere{{ 0,-100.5,  -1}, 100, &mat_ground})
        append(&world, Sphere{{ 0,     0,-1.2}, 0.5, &mat_center})
        append(&world, Sphere{{-1,     0,  -1}, 0.5, &mat_left  })
        append(&world, Sphere{{-1,     0,  -1}, 0.4, &mat_bubble})
        append(&world, Sphere{{ 1,     0,  -1}, 0.5, &mat_right })
        render(&world)

        fmt.eprintln("\rScanlines remaining: 0")
        fmt.eprintln("Done.")
}

