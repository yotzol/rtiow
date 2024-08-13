package main

import "core:fmt"
import "core:os"


main :: proc()
{
        R := cos(PI/4)

        camera_config := CameraSettings {
                aspect_ratio         = 16.0 / 9.0,
                image_width          = 1200,
                samples_per_pixel    = 500,
                max_depth            = 50,
                field_of_view        = 20,
                look_from            = {13,2, 3},
                look_at              = { 0,0, 0},
                vector_up            = { 0,1, 0},
                defocus_angle        = 0.6,
                focus_dist           = 10,
        }

        init_camera(camera_config)

        world: HittableList

        ground_material : Material = Lambertian{{0.5,0.5,0.5}}
        append(&world, Sphere{{0,-1000,0}, 1000, &ground_material})

        materials : [dynamic]^Material
        defer for mat in materials do free(mat)

        for a in -11..<11 {
                for b in -11..<11 {
                        center := Point3{f64(a) + 0.9*random(), 0.2, f64(b) + 0.9*random()}

                        if length(center - {4,0.2,0}) > 0.9 {
                                choose_mat := random()
                                sphere_mat := new(Material)
                                switch {
                                case choose_mat < 0.8:
                                        albedo      : Color    = rand_vec() * rand_vec()
                                        sphere_mat^ = Lambertian{albedo}
                                        append(&world, Sphere{center, 0.2, sphere_mat})
                                case choose_mat < 0.95:
                                        albedo      : Color    = rand_vec(0.5,1)
                                        fuzz        : f64      = random()
                                        sphere_mat^ = Metal{albedo, fuzz}
                                        append(&world, Sphere{center, 0.2, sphere_mat})
                                case:
                                        sphere_mat^ = Dielectric{1.5}
                                        append(&world, Sphere{center, 0.2, sphere_mat})
                                }
                                append(&materials, sphere_mat)
                        }
                }
        }

        material_1 : Material = Dielectric{1.5}
        material_2 : Material = Lambertian{{0.4,0.2,0.1}}
        material_3 : Material = Metal{{0.7,0.6,0.7}, 0}

        append(&world, Sphere{{ 0,1,0}, 1, &material_1})
        append(&world, Sphere{{-4,1,0}, 1, &material_2})
        append(&world, Sphere{{ 4,1,0}, 1, &material_3})

        render(&world)
}

