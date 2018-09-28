corner_radius = 50;
speaker_size = 228; // 9 in.
front_baffle_width = speaker_size + 2 * corner_radius + 10; // 10mm extra margin
depth = 250; // arbitrary
rear_width = speaker_size * 0.68; // arbitrary

wall_ellipse_aspect_ratio = 2.5;
wall_ellipse_unscaled_radius = 100;
wall_ellipse_y_offset = wall_ellipse_unscaled_radius * 1.5;
wall_ellipse_angle_deg = 10;
right_wall_front_baffle_width_offset = 20; // FIXME seems to work - why?

base_height = 8;
main_volume_height = 800;

outer_cutout_x_thickness = 20;
outer_cutout_y_offset = 0;
outer_cutout_x_offset_from_wall = 2;
outer_cutout_y_offset_from_baffle = 2;

// Calculate so that we end up with 2mm thickness.
outer_cutout_scaling_factor_from_wall_size = (front_baffle_width - outer_cutout_x_offset_from_wall) / front_baffle_width;

middle_cutout_thickness = 3;
middle_cutout_offset_from_outer_cutout = 24;
middle_cutout_x_offset = 14;
middle_cutout_y_offset = 14;
middle_cutout_inner_x_offset = 18;
middle_cutout_inner_y_offset = 15;
middle_cutout_outer_wall_scale_factor = outer_cutout_scaling_factor_from_wall_size - 0.105;
middle_cutout_inner_wall_scale_factor = middle_cutout_outer_wall_scale_factor - 0.02;

inner_cutout_offset_from_outer_cutout = 20;
inner_cutout_outside_scale_factor = middle_cutout_inner_wall_scale_factor - 0.015;
inner_cutout_inner_wall_offset = 32;
inner_cutout_inner_wall_scale_factor = 0.77;

main_volume_cutout_offset = 34.4;
main_volume_cutout_scale_factor = 0.754;

module wall_ellipse() {
    scale([1, wall_ellipse_aspect_ratio, 1]) {
        circle(wall_ellipse_unscaled_radius);
    } 
}

module left_wall() {
    translate([0, wall_ellipse_y_offset, 0]) {
        rotate([0, 0, -wall_ellipse_angle_deg])
        wall_ellipse();
    }
}

module right_wall() {
    translate([front_baffle_width + right_wall_front_baffle_width_offset, 0, 0]) {
        rotate([0, 0, 2 * wall_ellipse_angle_deg])
        left_wall();
    }
}

module front_baffle() {
    hull() {
        circle(corner_radius);
        translate([front_baffle_width, 0, 0]) {
            circle(corner_radius);
        }
    }    
}

module base_cross_section() {
    hull() {
        left_wall();
        right_wall();
        front_baffle();
    }
}

module base() {
    linear_extrude(base_height) {
        base_cross_section();
    }
}

module left_wall_cutout_ellipse_slice() {
    rotate([0,0,-wall_ellipse_angle_deg])
    difference() {
        wall_ellipse();
        translate([outer_cutout_x_thickness,0,0])
        wall_ellipse();
    }
}

module left_wall_cutout_ellipse_thin_slice() {
    rotate([0,0,-wall_ellipse_angle_deg])
    difference() {
        wall_ellipse();
        translate([middle_cutout_thickness,0,0])
        wall_ellipse();
    }
}

module left_wall_cutouts() {
    difference() {
        union() {
            left_wall_cutout_ellipse_slice();
            translate([middle_cutout_offset_from_outer_cutout,0,0])
            left_wall_cutout_ellipse_thin_slice();
            translate([inner_cutout_offset_from_outer_cutout,0,0])
            left_wall_cutout_ellipse_slice();    
        }
        // FIXME this slice off of the end where the cutouts join together, which I don't want, is still WIP
        translate(50, 220, 0)
        square(100);
    }
}

module outer_cutout() {
    difference() {
        translate([outer_cutout_x_offset_from_wall, outer_cutout_y_offset_from_baffle, 0])
        scale([outer_cutout_scaling_factor_from_wall_size, outer_cutout_scaling_factor_from_wall_size])
        base_cross_section();
        translate([12, 12, 0])
        scale([0.9, 0.9])
        base_cross_section();
    }
}

module middle_cutout() {
    difference() {
        translate([middle_cutout_x_offset, middle_cutout_y_offset, 0])
        scale([middle_cutout_outer_wall_scale_factor, middle_cutout_outer_wall_scale_factor])
        base_cross_section();
        translate([middle_cutout_inner_x_offset, middle_cutout_inner_x_offset, 0])
        scale([middle_cutout_inner_wall_scale_factor, middle_cutout_inner_wall_scale_factor])
        base_cross_section();
    }
}

module inner_cutout() {
    difference() {
        translate([inner_cutout_offset_from_outer_cutout, inner_cutout_offset_from_outer_cutout, 0])
        scale([inner_cutout_outside_scale_factor, inner_cutout_outside_scale_factor])
        base_cross_section();
        translate([inner_cutout_inner_wall_offset, inner_cutout_inner_wall_offset, 0])
        scale([inner_cutout_inner_wall_scale_factor, inner_cutout_inner_wall_scale_factor])
        base_cross_section();
    }
}

module main_volume_cutout() {
    translate([main_volume_cutout_offset, main_volume_cutout_offset, 0])
    scale([main_volume_cutout_scale_factor, main_volume_cutout_scale_factor])
    base_cross_section();
}

module main_volume_cross_section() {
    difference() {
        base_cross_section();
        outer_cutout();
        middle_cutout();
        inner_cutout();
        main_volume_cutout();
    }
}
// FIXME trying 3 concentrically sized cutouts instead      
//        translate([0, 150, 0])
//        left_wall_cutouts();
//    }    
//}

module main_volume() {
    translate([0,0,base_height])
    linear_extrude(main_volume_height)
    main_volume_cross_section();
}

base();
main_volume();
