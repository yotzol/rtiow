//+private file
package main

import "core:fmt"
import "core:os"


init_camera :: proc() { }

// defaults
aspect_ratio: f64 = 1
img_w       : int = 100

// auto
img_h       : int
center      : Point3
p00_loc     : Point3
p_du, p_dv  : Vec3


@(private)
init_camera :: proc(ar: f64, w: int) {
        aspect_ratio = ar
        img_w        = w

        img_h  = int(f64(img_w) / aspect_ratio)
        img_h  = img_h if img_h > 1 else 1

        vp_h  :: 2.0
        vp_w  := vp_h * f64(img_w)/f64(img_h)

        focal_length :: 1.0
        center = Point3{0,0,0}

        vp_u  := Vec3{vp_w, 0, 0}
        vp_v  := Vec3{0, -vp_h, 0}

        p_du   = vp_u / f64(img_w)
        p_dv   = vp_v / f64(img_h)

        vp_upper_left := center - {0, 0, focal_length} - vp_u/2 - vp_v/2
        p00_loc        = vp_upper_left + (p_du + p_dv)/2

}

@(private)
render :: proc(world: ^HittableList) {
        fmt.println("P3")
        fmt.println(img_w, img_h)
        fmt.println("255")
        for j in 0..<img_h {
                fmt.eprintf("\rScanlines remaining: %d ", img_h-j)
                for i in 0..<img_w {
                        p_center := p00_loc + f64(i)*p_du + f64(j)*p_dv
                        ray_dir  := p_center - center
                        r        := Ray{center, ray_dir}
                        color    := ray_color(r, world) 
                        write_color(os.stdout, &color)
                }
        }
}


ray_color :: proc(r: Ray, world: ^HittableList) -> Color {
        rec: HitRecord
        if hit_list(world, r, {0, INFINITY}, &rec) {
                return (rec.normal + Color{1,1,1}) / 2
        }

        unit_dir := unit_vector(r.dir)
        a        := (unit_dir.y + 1) / 2
        return (1-a)*Color{1,1,1} + a*Color{0.5,0.7,1.0}
}
