package main


Vec3   :: [3]f64
Point3 :: Vec3

dot :: proc(u: ^Vec3, v: ^Vec3) -> f64 {
        return u.x*v.x + u.y*v.y + u.z*v.z
}

cross :: proc(u: ^Vec3, v: ^Vec3) -> Vec3 {
        return {
                u.y*v.z - u.z*v.y,
                u.z*v.x - u.x*v.z,
                u.x*v.y - u.y*v.x,
        }
}

length :: proc(v: ^Vec3) -> f64 {
        return sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
}

length_squared :: proc(v: ^Vec3) -> f64 {
        return v.x*v.x + v.y*v.y + v.z*v.z
}

unit_vector :: proc(v: ^Vec3) -> Vec3 {
        return v^ / length(v)
}
