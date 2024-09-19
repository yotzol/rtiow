package main

@(private="file")
POINT_COUNT :: 256

Perlin :: struct {
        rand_vec               : [POINT_COUNT]Vec3,
        perm_x, perm_y, perm_z : [POINT_COUNT]int,
}

perlin_new :: proc() -> (perlin: Perlin) {
        for i in 0..<len(perlin.rand_vec) {
                perlin.rand_vec[i] = unit_vec(rand_vec(-1,1))
        }

        generate_perm(perlin.perm_x[:])
        generate_perm(perlin.perm_y[:])
        generate_perm(perlin.perm_z[:])

        return
}

perlin_noise :: proc(perlin: ^Perlin, p: Point3) -> f64 {
        u := p.x - floor(p.x)
        v := p.y - floor(p.y)
        w := p.z - floor(p.z)

        i := int(floor(p.x))
        j := int(floor(p.y))
        k := int(floor(p.z))

        c : [2][2][2]Vec3

        for di in 0..<2 {
                for dj in 0..<2 {
                        for dk in 0..<2 {
                                c[di][dj][dk] = perlin.rand_vec[
                                        perlin.perm_x[(i+di) & 255] ~
                                        perlin.perm_y[(j+dj) & 255] ~
                                        perlin.perm_z[(k+dk) & 255]
                                ]
                        }
                }
        }

        return trilinear_interp(c, u, v, w)
}

perlin_turb :: proc(perlin: ^Perlin, p: Point3, depth: int) -> f64 {
        temp_p := p
        accum  : f64 = 0
        weight : f64 = 1

        for i in 0..<depth {
                accum += weight * perlin_noise(perlin, temp_p)
                weight *= 0.5
                temp_p *= 2
        }

        return abs(accum)
}

@(private="file")
generate_perm :: proc(p: []int) {
        for i in 0..<len(p) {
                p[i] = i
        }
        permute(p, POINT_COUNT)
}

@(private="file")
permute :: proc(p: []int, n: int) {
        for i := n-1; i > 0; i -= 1 {
                target := rand_int(0, i)
                tmp    := p[i]
                p[i] = p[target]
                p[target] = tmp
        }
}

@(private="file")
trilinear_interp :: proc(c: [2][2][2]Vec3, u, v, w: f64) -> f64 {
        uu := u*u*(3-2*u)
        vv := v*v*(3-2*v)
        ww := w*w*(3-2*w)

        accum : f64 = 0

        for i in 0..<2.0 {
                for j in 0..<2.0 {
                        for k in 0..<2.0 {
                                weight_v := Vec3{u-i, v-j, w-k}
                                accum +=
                                        (i*uu + (1-i)*(1-uu)) *
                                        (j*vv + (1-j)*(1-vv)) * 
                                        (k*ww + (1-k)*(1-ww)) *
                                        dot(c[int(i)][int(j)][int(k)], weight_v)
                        }
                }
        }
        return accum
}
