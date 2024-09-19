package main

import "core:slice"


BvhNode :: struct{
        l, r: ^Hittable,
}

box_compare :: proc(a, b: ^Hittable, axis_index: int) -> slice.Ordering {
        a, b  := a, b
        min_a := axis_interval(a.bbox, axis_index).min 
        min_b := axis_interval(b.bbox, axis_index).min 

        switch{
        case min_a < min_b: return .Less
        case min_a > min_b: return .Greater
        case:               return .Equal
        }
}

box_x_compare :: proc(a, b: ^Hittable) -> slice.Ordering { return box_compare(a, b, 0) }
box_y_compare :: proc(a, b: ^Hittable) -> slice.Ordering { return box_compare(a, b, 1) }
box_z_compare :: proc(a, b: ^Hittable) -> slice.Ordering { return box_compare(a, b, 2) }

bvh_node_new :: proc(objects: ^List, start, end: int) -> ^Hittable {
        result := new(Hittable)
        node   : BvhNode
        result^ = Hittable{data = node}

        result.bbox = AABB_EMPTY
        for obj in objects.objects[start:end] {
                result.bbox = aabb_new(result.bbox, obj.bbox)
        }

        comparator : proc(a, b: ^Hittable) -> slice.Ordering

        axis := longest_axis(result.bbox)
        switch axis {
        case axis == 1: comparator = box_y_compare
        case axis == 2: comparator = box_z_compare
        case:           comparator = box_x_compare
        }

        object_span := end - start
        switch object_span {
        case 1:
                node.l = objects.objects[start]
                node.r = node.l
        case 2:
                if comparator(objects.objects[start], objects.objects[start+1]) == .Less {
                        node.l = objects.objects[start]
                        node.r = objects.objects[start+1]
                }
                else {
                        node.l = objects.objects[start+1]
                        node.r = objects.objects[start]
                }
        case:
                mid   := start + object_span/2
                node.l = bvh_node_new(objects, start, mid)
                node.r = bvh_node_new(objects, mid, end)
        }

        result.data = node
        return result
}

bvh_node_hit :: proc(node: ^Hittable, r: Ray, ray_t: Interval, rec: ^HitRecord) -> bool {
        if !aabb_hit(node.bbox, r, ray_t) do return false 
        bvh := node.data.(BvhNode) 
        hit_l, hit_r := false, false
        if bvh.l != nil do hit_l = hit(node.data.(BvhNode).l, r, ray_t                                     , rec)
        if bvh.r != nil do hit_r = hit(node.data.(BvhNode).r, r, {ray_t.min, rec.t if hit_l else ray_t.max}, rec)

        return hit_l || hit_r
}

longest_axis :: proc(bbox: Aabb) -> int {
        x_size := interval_size(bbox.x)
        y_size := interval_size(bbox.y)
        z_size := interval_size(bbox.z)

        if x_size > y_size do return 0 if x_size > z_size else 2
        else               do return 1 if y_size > z_size else 2
}
