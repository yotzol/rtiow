package main

import "vendor:stb/image"

Image :: struct {
        depth, w, h : i32,
        data : [^]byte,
}

image_new :: proc(path: cstring) -> ^Texture {
        tex := new(Texture)

        img : Image
        img.data = image.load(path, &img.w, &img.h, &img.depth, 3)

        tex^ = img
        return tex
}

image_get_pixel :: proc(img: ^Image, i, j: i32) -> Color {
        offset := (j * img.w + i) * 3
        
        color_scale :: 1.0 / 255.0

        return {
                f64(img.data[offset + 0]) * color_scale,
                f64(img.data[offset + 1]) * color_scale,
                f64(img.data[offset + 2]) * color_scale,
        } 
}
