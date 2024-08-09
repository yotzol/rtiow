package main


Material :: union {
        Lambertian,
        Metal,
}

Lambertian :: struct { albedo: Color }
Metal      :: struct { albedo: Color, fuzz: f64 }

scatter :: proc(m: ^Material, r_in, scattered: ^Ray, rec: ^HitRecord, attenuation: ^Color) -> bool {
        switch type in m {
        case Lambertian:
                m := m.(Lambertian)

                scatter_dir := rec.normal + rand_unit_vec()
                if near_zero(scatter_dir) do scatter_dir = rec.normal

                scattered^   = {rec.p, scatter_dir}
                attenuation^ = m.albedo
                return true
        case Metal:
                m := m.(Metal)

                reflected   := reflect(r_in.dir, rec.normal)
                reflected    = unit_vec(reflected + (m.fuzz*rand_unit_vec()))
                scattered^   = {rec.p, reflected}
                attenuation^ = m.albedo
                return true
        }
        return false
}
