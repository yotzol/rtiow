package main

import "vendor:stb/image"


Texture :: union {
        SolidColor,
        CheckerTexture,
        Image,
        Noise,
}

SolidColor :: struct {
        albedo: Color,
}

CheckerTexture :: struct {
        inv_scale : f64,
        even, odd : ^Texture,
}

Noise :: struct {
        noise: Perlin,
        scale: f64,
}

texture_value :: proc(t: ^Texture, u, v: f64, p: Point3) -> Color {
        switch type in t^ {
        case SolidColor    : return t.(SolidColor).albedo
        case CheckerTexture:
                c := t.(CheckerTexture)
                x_int := int(floor(c.inv_scale * p.x))
                y_int := int(floor(c.inv_scale * p.y))
                z_int := int(floor(c.inv_scale * p.z))
                is_even := (x_int + y_int + z_int) % 2 == 0
                if is_even do return texture_value(c.even, u, v, p)
                else       do return texture_value(c.odd , u, v, p)
        case Image:
                img := t.(Image)
                if img.w <= 0 do return {0,1,1}

                u := clamp({0,1}, u)
                v := 1 - clamp({0,1}, v)
                i := i32(u * f64(img.w))
                j := i32(v * f64(img.h))

                return image_get_pixel(&img, i, j)
        case Noise:
                noise := t.(Noise)
                return {.5,.5,.5} * (1 + sin(noise.scale*p.z + 10 * perlin_turb(&noise.noise, p, 7)))
        }
        panic("Unknown Texture type")
}

solid_color :: proc(r, g, b: f64) -> ^Texture {
        tex := new(Texture)
        tex^ = SolidColor{{r, g, b}}
        return tex
}

checker_texture :: proc(scale: f64, even, odd: ^Texture) -> ^Texture {
        tex := new(Texture)
        tex^ = CheckerTexture{
                inv_scale = 1.0 / scale,
                even      = even,
                odd       = odd,
        }
        return tex
}
