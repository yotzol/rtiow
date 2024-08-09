package main


Vec3   :: [3]f64
Point3 :: Vec3

dot :: proc(u: Vec3, v: Vec3) -> f64 {
        return u.x*v.x + u.y*v.y + u.z*v.z
}

cross :: proc(u: Vec3, v: Vec3) -> Vec3 {
        return {
                u.y*v.z - u.z*v.y,
                u.z*v.x - u.x*v.z,
                u.x*v.y - u.y*v.x,
        }
}

length :: proc(v: Vec3) -> f64 {
        return sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
}

length_squared :: proc(v: Vec3) -> f64 {
        return v.x*v.x + v.y*v.y + v.z*v.z
}

unit_vec :: proc(v: Vec3) -> Vec3 {
        return v / length(v)
}

rand_vec :: proc {rand_vec_default, rand_vec_range}

rand_vec_default :: proc() -> Vec3 {
        return {random(), random(), random()}
}

rand_vec_range :: proc(min, max: f64) -> Vec3 {
        return {random(min,max), random(min,max), random(min,max)}
}

rand_in_unit_sphere :: proc() -> Vec3 {
        for {
                p := rand_vec()
                if length_squared(p) < 1 do return p
        }
}

rand_unit_vec :: proc() -> Vec3 {
        return unit_vec(rand_in_unit_sphere())
}

rand_on_hemisphere :: proc(normal: Vec3) -> Vec3 {
        on_unit_sphere := rand_unit_vec()
        if dot(on_unit_sphere, normal) > 0 do return on_unit_sphere
        else do return -on_unit_sphere
}

near_zero :: proc(v: Vec3) -> bool {
        s :: 1e-8
        return abs(v.x) < s && abs(v.y) < s && abs(v.z) < s

}

reflect :: proc(v, n: Vec3) -> Vec3 {
        return v - 2*dot(v,n)*n
}

refract :: proc(uv, n: Vec3, etai_over_etat: f64) -> Vec3 {
        cos_theta      := min(dot(-uv,n), 1)
        r_out_perp     := etai_over_etat * (uv + cos_theta*n)
        r_out_parallel := -sqrt(abs(1-length_squared(r_out_perp))) * n
        return r_out_perp + r_out_parallel
}
