package main


HitRecord :: struct {
        normal: Vec3,
        mat   : ^Material,
        p     : Point3,
        t     : f64,
        front : bool,
}

Sphere :: struct {
        center    : Point3,
        radius    : f64,
        mat       : ^Material,
}

Hittable :: Sphere

HittableList :: #soa[dynamic]Hittable


hit_list :: proc(list: ^HittableList, r: Ray, ray_t: Interval, rec: ^HitRecord) -> bool {
        temp_rec       : HitRecord
        hit_anything   := false
        closest_so_far := ray_t.max

        for &obj in list {
                if hit_obj(&obj, r, {ray_t.min, closest_so_far}, &temp_rec) {
                        hit_anything   = true
                        closest_so_far = temp_rec.t
                        rec^ = temp_rec
                }
        }

        return hit_anything
}

hit_obj :: proc(h: ^Hittable, r: Ray, ray_t: Interval, rec: ^HitRecord) -> bool {
        obj := h
        oc  := obj.center - r.orig
        a   := length_squared(r.dir)
        h   := dot(r.dir, oc)
        c   := length_squared(oc) - obj.radius*obj.radius
        d   := h*h - a*c

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
        outward_normal := (rec.p - obj.center) / obj.radius
        rec.mat         = obj.mat

        set_face_normal(rec, r, outward_normal)
        return true
}

set_face_normal :: proc(rec: ^HitRecord, r: Ray, outward_normal: Vec3) {
        rec.front  = dot(r.dir, outward_normal) < 0
        rec.normal = outward_normal if rec.front else -outward_normal
}
