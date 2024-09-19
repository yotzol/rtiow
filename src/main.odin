package main

main :: proc() {
        switch 4 {
        case 1: bouncing_spheres()
        case 2: checkered_spheres()
        case 3: earth()
        case 4: perlin_spheres()
        }
}

bouncing_spheres :: proc()
{
        camera_config := CameraSettings {
                aspect_ratio         = 16.0 / 9.0,
                image_width          = 400,
                samples_per_pixel    = 100,
                max_depth            = 50,
                field_of_view        = 20,
                look_from            = {13, 2, 3},
                look_at              = { 0, 0, 0},
                vector_up            = { 0, 1, 0},
                defocus_angle        = 0.6,
                focus_dist           = 10,
        }

        init_camera(camera_config)

        world: Hittable = { data = List{} }


        ground_material : Material = Lambertian{
                checker_texture(
                         0.32,
                         solid_color(0.2,0.3,0.1),
                         solid_color(0.9,0.9,0.9),
                ),
        }

        hittable_list_add(&world, sphere_new({0,-1000,0}, 1000, &ground_material))

        materials : [dynamic]^Material
        defer for mat in materials do free(mat)

        for a in -11..<11 {
                for b in -11..<11 {
                        center := Point3{f64(a) + 0.9*random(), 0.2, f64(b) + 0.9*random()}

                        if length(center - {4,0.2,0}) > 0.9 {
                                choose_mat := random()
                                sphere_mat := new(Material)
                                switch {
                                case choose_mat < 0.8:
                                        albedo      : Color    = rand_vec() * rand_vec()
                                        sphere_mat^ = Lambertian{solid_color(albedo.x, albedo.y, albedo.z)}
                                        center2 : Point3 = center + {0,random(0, 0.5),0}
                                        hittable_list_add(&world, sphere_new(center, center2, 0.2, sphere_mat))
                                case choose_mat < 0.95:
                                        albedo      : Color    = rand_vec(0.5,1)
                                        fuzz        : f64      = random()
                                        sphere_mat^ = Metal{albedo, fuzz}
                                        hittable_list_add(&world, sphere_new(center, 0.2, sphere_mat))
                                case:
                                        sphere_mat^ = Dielectric{1.5}
                                        hittable_list_add(&world, sphere_new(center, 0.2, sphere_mat))
                                }
                                append(&materials, sphere_mat)
                        }
                }
        }

        material_1 : Material = Dielectric{1.5}
        material_2 : Material = Lambertian{solid_color(0.4,0.2,0.1)}
        material_3 : Material = Metal{{0.7,0.6,0.7}, 0}

        hittable_list_add(&world, sphere_new({ 0,1,0}, 1, &material_1))
        hittable_list_add(&world, sphere_new({-4,1,0}, 1, &material_2))
        hittable_list_add(&world, sphere_new({ 4,1,0}, 1, &material_3))
        
        node_list : Hittable = {
                data = List{},
        }

        hittable_list_add(&node_list, bvh_node_new(&world.data.(List), 0, len(world.data.(List).objects))) 
        render(&node_list.data.(List))
}

checkered_spheres :: proc() {
        world: Hittable = { data = List{} }
        checker := checker_texture(0.32, solid_color(.2,.3,.1), solid_color(.9,.9,.9))
        mat := new(Material)
        defer free(mat)
        mat^ = Lambertian{checker}
        hittable_list_add(&world, sphere_new({0,-10,0}, 10, mat))
        hittable_list_add(&world, sphere_new({0, 10,0}, 10, mat))

        camera_config := CameraSettings {
                aspect_ratio         = 16.0 / 9.0,
                image_width          = 400,
                samples_per_pixel    = 100,
                max_depth            = 50,
                field_of_view        = 20,
                look_from            = {13, 2, 3},
                look_at              = { 0, 0, 0},
                vector_up            = { 0, 1, 0},
                defocus_angle        = 0,
        }

        init_camera(camera_config)
        render(&world.data.(List))
}

earth :: proc() {
        world: Hittable = { data = List{} }

        earth_texture := image_new("./assets/earth.jpg")
        earth_surface : Material = Lambertian{earth_texture}
        globe         := sphere_new({0,0,0}, 2, &earth_surface)
        defer free(earth_texture)
        hittable_list_add(&world, globe)

        camera_config := CameraSettings {
                aspect_ratio         = 16.0 / 9.0,
                image_width          = 400,
                samples_per_pixel    = 100,
                max_depth            = 50,
                field_of_view        = 20,
                look_from            = { 0, 0,12},
                look_at              = { 0, 0, 0},
                vector_up            = { 0, 1, 0},
                defocus_angle        = 0,
        }

        init_camera(camera_config)
        render(&world.data.(List))
}

perlin_spheres :: proc() {
        world: Hittable = { data = List{} }

        pertext : Texture = Noise{perlin_new(), 4}
        mat : Material = Lambertian{&pertext}
        hittable_list_add(&world, sphere_new({0,-1000,0}, 1000, &mat))
        hittable_list_add(&world, sphere_new({0,    2,0},    2, &mat))

        camera_config := CameraSettings {
                aspect_ratio         = 16.0 / 9.0,
                image_width          = 400,
                samples_per_pixel    = 100,
                max_depth            = 50,
                field_of_view        = 20,
                look_from            = {13, 2, 3},
                look_at              = { 0, 0, 0},
                vector_up            = { 0, 1, 0},
                defocus_angle        = 0,
        }

        init_camera(camera_config)
        render(&world.data.(List))
}
