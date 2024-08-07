package main

import "core:fmt"
import "core:os"


ASPECT_RATIO :: 16.0 / 9.0

main :: proc()
{
        img_w :: 400

        img_h := int(img_w / ASPECT_RATIO)
        img_h  = img_h if img_h > 1 else 1

        // camera
        vp_h  :: 2.0
        vp_w  := vp_h * f64(img_w)/f64(img_h)

        focal_length := 1.0
        cam_center   := Point3{0,0,0}

        // horizontal and vertical viewport vecs
        vp_u  := Vec3{vp_w, 0, 0}
        vp_v  := Vec3{0, -vp_h, 0}

        // delta vectors from pixel to pixel
        p_du  := vp_u / f64(img_w)
        p_dv  := vp_v / f64(img_h)

        vp_upper_left := cam_center - {0, 0, focal_length} - vp_u/2 - vp_v/2
        p00_loc       := vp_upper_left + (p_du + p_dv)/2

        // render
        fmt.println("P3")
        fmt.println(img_w, img_h)
        fmt.println("255")

        world: HittableList
        append(&world, Sphere{{0,0,-1}, 0.5})
        append(&world, Sphere{{0,-100.5,-1}, 100})

        for j in 0..<img_h {
                fmt.eprintf("\rScanlines remaining: %d ", img_h-j)
                for i in 0..<img_w {
                        p_center := p00_loc + f64(i)*p_du + f64(j)*p_dv
                        ray_dir  := p_center - cam_center
                        r        := Ray{cam_center, ray_dir}
                        color    := ray_color(r, &world) 
                        write_color(os.stdout, &color)
                }
        }

        fmt.eprintln("\rScanlines remaining: 0")
        fmt.eprintln("Done.")
}

ray_color :: proc(r: Ray, world: ^HittableList) -> Color {
        rec: HitRecord
        if hit_list(world, r, 0, INFINITY, &rec) {
                return (rec.normal + Color{1,1,1}) / 2
        }

        unit_dir := unit_vector(r.dir)
        a        := (unit_dir.y + 1) / 2
        return (1-a)*Color{1,1,1} + a*Color{0.5,0.7,1.0}
}

