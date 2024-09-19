package main

Quad :: struct {
        q      : Point3,
        u, v, w: Vec3,
        mat    : ^Material,
        normal : Vec3,
        d      : f64,
}

quad_new :: proc(q: Point3, u, v: Vec3, mat: ^Material) -> ^Hittable {
        h    := new(Hittable)
        quad := Quad{
                q=q,
                u=u,
                v=v,
                mat=mat
        }

        n := cross(u, v)

        quad.normal = unit_vec(n)
        quad.d      = dot(quad.normal, q)
        quad.w      = n / dot(n,n)

        h.data = quad
        quad_set_bb(h)
        return h
}

quad_hit :: proc(h: ^Hittable, r: Ray, ray_t: Interval, rec: ^HitRecord) -> bool {
        quad := h.data.(Quad)

        // doesn't hit if the ray is parallel to the plane
        denom := dot(quad.normal, r.dir)
        if abs(denom) < 1e-8 do return false

        // doesn't hit if hit point is outside ray interval
        t := (quad.d - dot(quad.normal, r.orig)) / denom
        if !interval_contains(ray_t, t) do return false

        // check if hit point is inside the quad
        intersection := ray_at(r, t)
        planar_hitpt_vec := intersection - quad.q
        alpha := dot(quad.w, cross(planar_hitpt_vec, quad.v))
        beta  := dot(quad.w, cross(quad.u, planar_hitpt_vec))

        if !is_interior(alpha, beta, rec) do return false

        rec.t = t
        rec.p = intersection
        rec.mat = quad.mat
        set_face_normal(rec, r, quad.normal)

        return true
}

quad_set_bb :: proc(h: ^Hittable) {
        quad := h.data.(Quad)

        bbox_diag_1 := aabb_new(quad.q, quad.q + quad.u + quad.v)
        bbox_diag_2 := aabb_new(quad.q + quad.u, quad.q + quad.v)

        h.bbox = aabb_new(bbox_diag_1, bbox_diag_2)
}

is_interior :: proc(a, b: f64, rec: ^HitRecord) -> bool {
        unit_interval :: Interval{0,1}

        if !interval_contains(unit_interval, a) do return false
        if !interval_contains(unit_interval, b) do return false

        rec.u = a
        rec.v = b
        return true
}
