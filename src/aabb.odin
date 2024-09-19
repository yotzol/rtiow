package main


Aabb :: struct {
        x,y,z: Interval
}

AABB_EMPTY    :: Aabb{EMPTY   , EMPTY   , EMPTY   }
AABB_UNIVERSE :: Aabb{UNIVERSE, UNIVERSE, UNIVERSE}

aabb_new :: proc{aabb_new_from_intervals, aabb_new_from_points, aabb_new_from_boxes}

aabb_new_from_intervals :: proc(x,y,z: Interval) -> Aabb {
        return {x,y,z}
}

aabb_new_from_points :: proc(a,b: Point3) -> Aabb {
        x : Interval = {a.x,b.x} if a.x <= b.x else {b.x,a.x}
        y : Interval = {a.y,b.y} if a.y <= b.y else {b.y,a.y}
        z : Interval = {a.z,b.z} if a.z <= b.z else {b.z,a.z}
        return {x,y,z}
}

aabb_new_from_boxes :: proc(box0, box1: Aabb) -> Aabb {
        return {
                interval_new(box0.x, box1.x),
                interval_new(box0.y, box1.y),
                interval_new(box0.z, box1.z),
        }
}

axis_interval :: proc(aabb: Aabb, n: int) -> Interval {
        switch n {
        case 1: return aabb.y
        case 2: return aabb.z
        case:   return aabb.x
        }
}

aabb_hit :: proc(aabb: Aabb, r: Ray, ray_t: Interval) -> bool {
        ray_orig := r.orig
        ray_dir  := r.dir
        ray_t    := ray_t

        for axis in 0..<3 {
                ax := axis_interval(aabb, axis)
                adinv := 1 / ray_dir[axis]

                t0 := (ax.min - ray_orig[axis]) * adinv
                t1 := (ax.max - ray_orig[axis]) * adinv

                if t0 < t1 {
                        if (t0 > ray_t.min) do ray_t.min = t0
                        if (t1 < ray_t.max) do ray_t.max = t1
                } else {
                        if (t1 > ray_t.min) do ray_t.min = t1
                        if (t0 < ray_t.max) do ray_t.max = t0
                }

                if ray_t.max <= ray_t.min do return false
        }

        return true
}
