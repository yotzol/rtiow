//+private file
package main

import "core:fmt"
import "core:os"


init_camera :: proc() { }

@(private)
CameraSettings :: struct {
        aspect_ratio      : f64,
        image_width       : int,
        samples_per_pixel : int,
        max_depth         : int,
}

// defaults
aspect_ratio        : f64 = 1.0
img_w               : int = 100
samples_per_pixel   : int = 10
max_depth           : int = 10

// auto
img_h               : int
center              : Point3
p00_loc             : Point3
p_du, p_dv          : Vec3
pixel_samples_scale : f64


@(private)
init_camera :: proc(config: CameraSettings) {
        // globals
        if config.aspect_ratio      != 0 do aspect_ratio      = config.aspect_ratio
        if config.image_width       != 0 do img_w             = config.image_width
        if config.samples_per_pixel != 0 do samples_per_pixel = config.samples_per_pixel
        if config.max_depth         != 0 do max_depth         = config.max_depth

        // consts
        focal_length :: 1.0
        vp_h         :: 2.0

        center = Point3{0,0,0}

        // auto
        img_h  = int(f64(img_w) / aspect_ratio)
        img_h  = img_h if img_h > 1 else 1

        vp_w  := vp_h * f64(img_w)/f64(img_h)

        vp_u  := Vec3{vp_w,  0, 0}
        vp_v  := Vec3{0, -vp_h, 0}

        p_du   = vp_u / f64(img_w)
        p_dv   = vp_v / f64(img_h)

        vp_upper_left      := center - {0, 0, focal_length} - vp_u/2 - vp_v/2
        p00_loc             = vp_upper_left + (p_du + p_dv)/2
        pixel_samples_scale = 1.0 / f64(samples_per_pixel)
}

@(private)
render :: proc(world: ^HittableList) {
        fmt.println("P3")
        fmt.println(img_w, img_h)
        fmt.println("255")
        for j in 0..<img_h {
                fmt.eprintf("\rScanlines remaining: %d ", img_h-j)
                for i in 0..<img_w {
                        color := Color{0,0,0}
                        for _ in 0..<samples_per_pixel {
                                ray   := get_ray(i, j)
                                color += ray_color(ray, max_depth, world)
                        }
                        color *= pixel_samples_scale
                        write_color(os.stdout, &color)
                }
        }
}

get_ray :: proc(i, j: int) -> Ray {
        offset       := sample_square()
        pixel_sample := p00_loc + (f64(i)+offset.x)*p_du + (f64(j)+offset.y)*p_dv
        ray_orig     := center
        ray_dir      := pixel_sample - ray_orig
        return {ray_orig, ray_dir}
}

sample_square :: proc() -> Vec3 {
        return {random() - 0.5, random() - 0.5, 0}
}

ray_color :: proc(r: Ray, depth: int, world: ^HittableList) -> Color {
        if depth <= 0 do return {0,0,0}

        r := r
        rec: HitRecord

        if hit_list(world, r, {0.001, INFINITY}, &rec) {
                scattered: Ray
                attenuation: Color

                if scatter(rec.mat, &r, &scattered, &rec, &attenuation) {
                        return attenuation * ray_color(scattered, depth-1, world)
                }
                return {0,0,0}
        }

        unit_dir := unit_vec(r.dir)
        a        := (unit_dir.y + 1) / 2
        return (1-a)*Color{1,1,1} + a*Color{0.5,0.7,1.0}
}
