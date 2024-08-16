package main


Material :: union {
        Lambertian,
        Metal,
        Dielectric,
}

Lambertian :: struct { albedo: Color }
Metal      :: struct { albedo: Color, fuzz: f64 }
Dielectric :: struct { refraction_index: f64 }

scatter :: proc(m: ^Material, r_in, scattered: ^Ray, rec: ^HitRecord, attenuation: ^Color) -> bool {
        switch type in m {
        case Lambertian:
                m := m.(Lambertian)

                scatter_dir := rec.normal + rand_unit_vec()
                if near_zero(scatter_dir) do scatter_dir = rec.normal

                scattered^   = {rec.p, scatter_dir, r_in.tm}
                attenuation^ = m.albedo
                return true
        case Metal:
                m := m.(Metal)

                reflected   := reflect(r_in.dir, rec.normal)
                reflected    = unit_vec(reflected + (m.fuzz*rand_unit_vec()))
                scattered^   = {rec.p, reflected, r_in.tm}
                attenuation^ = m.albedo
                return true
        case Dielectric:
                m := m.(Dielectric)

                attenuation^ = {1,1,1}
                ri := 1/m.refraction_index if rec.front else m.refraction_index

                unit_dir  := unit_vec(r_in.dir)
                cos_theta := min(dot(-unit_dir, rec.normal), 1)
                sin_theta := sqrt(1 - cos_theta*cos_theta)

                cannot_refract := ri * sin_theta > 1

                dir : Vec3
                if cannot_refract || reflectance(cos_theta, ri) > random() {
                        dir = reflect(unit_dir, rec.normal)
                } else {
                        dir = refract(unit_dir, rec.normal, ri)
                }
                scattered^ = {rec.p, dir, r_in.tm}
                return true
        }
        return false
}

reflectance :: proc(cosine, refraction_index: f64) -> f64 {
        r0 := (1-refraction_index) / (1+refraction_index)
        r0 *= r0
        return r0 + (1-r0)*pow(1-cosine,5)
}
