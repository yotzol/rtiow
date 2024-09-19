package main


HitRecord :: struct {
        normal: Vec3,
        mat   : ^Material,
        p     : Point3,
        t     : f64,
        u, v  : f64,
        front : bool,
}

Hittable :: struct {
        bbox: Aabb,
        data: union {
                Sphere, BvhNode, List,
        }
}

List :: struct {
        objects: [dynamic]^Hittable,
}

hittable_list_add :: proc(list: ^Hittable, object: ^Hittable) {
        if list_data, ok := &list.data.(List); ok != false {
                append(&list_data.objects, object)
                list.bbox = aabb_new(list.bbox, object.bbox)
        }
        else do panic("Attempting to add to a non-list Hittable")
}

hit :: proc(h: ^Hittable, r: Ray, ray_t: Interval, rec: ^HitRecord) -> bool {
        switch type in h.data {
        case List:    return list_hit    (&h.data.(List), r, ray_t, rec)
        case Sphere:  return sphere_hit  ( h            , r, ray_t, rec)
        case BvhNode: return bvh_node_hit( h            , r, ray_t, rec)
        case: panic("Unknown hittable type")
        }
}

list_hit :: proc(list: ^List, r: Ray, ray_t: Interval, rec: ^HitRecord) -> bool {
        temp_rec       : HitRecord
        hit_anything   := false
        closest_so_far := ray_t.max

        for obj in list.objects {
                if hit(obj, r, Interval{ray_t.min, closest_so_far}, &temp_rec) {
                        hit_anything   = true
                        closest_so_far = temp_rec.t
                        rec^           = temp_rec
                }
        }

        return hit_anything
}

set_face_normal :: proc(rec: ^HitRecord, r: Ray, outward_normal: Vec3) {
        rec.front  = dot(r.dir, outward_normal) < 0
        rec.normal = outward_normal if rec.front else -outward_normal
}
