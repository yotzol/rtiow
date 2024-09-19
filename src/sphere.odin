package main

Sphere :: struct {
        center1     : Point3,
        center_vec  : Vec3,
        radius      : f64,
        mat         : ^Material,
        is_moving   : bool,
}

sphere_new :: proc{sphere_new_stationary, sphere_new_moving}

sphere_new_stationary :: proc(center: Point3, radius: f64, mat: ^Material) -> ^Hittable {
        obj := new(Hittable)
        rvec : Vec3 = {radius, radius, radius}
        sphere := Sphere {
                center1   = center,
                radius    = radius,
                mat       = mat,
                is_moving = false,
        }

        obj.bbox = aabb_new(center-rvec, center+rvec)
        obj.data = sphere
        return obj
}

sphere_new_moving :: proc(center1, center2: Point3, radius: f64, mat: ^Material) -> ^Hittable {
        obj := new(Hittable)
        rvec : Vec3 = {radius, radius, radius}
        box1 : Aabb = aabb_new(center1-rvec, center1+rvec)
        box2 : Aabb = aabb_new(center2-rvec, center2+rvec)

        sphere := Sphere {
                center1    = center1,
                center_vec = center2-center1,
                radius     = radius,
                mat        = mat,
                is_moving  = true,
        }

        obj.bbox = aabb_new(box1, box2)
        obj.data = sphere
        return obj
}

sphere_get_center :: proc(sphere: Sphere, time:f64) -> Point3 {
        return sphere.center1 + time*sphere.center_vec
}

sphere_hit :: proc(s: ^Hittable, r: Ray, ray_t: Interval, rec: ^HitRecord) -> bool {
        s := s.data.(Sphere)

        center : Point3 = sphere_get_center(s, r.tm) if s.is_moving else s.center1
        oc := center - r.orig
        a  := length_squared(r.dir)
        h  := dot(r.dir, oc)
        c  := length_squared(oc) - s.radius*s.radius
        d  := h*h - a*c

        if d < 0 do return false

        sqrtd := sqrt(d)

        root := (h - sqrtd) / a
        if !interval_surrounds(ray_t, root) {
                root = (h + sqrtd) / a
                if !interval_surrounds(ray_t, root) {
                        return false
                }
        }

        rec.t           = root
        rec.p           = ray_at(r, rec.t)
        rec.mat         = s.mat
        outward_normal := (rec.p - center) / s.radius

        set_face_normal(rec, r, outward_normal)
        return true
}
