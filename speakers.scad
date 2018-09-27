corner_radius = 50;
speaker_size = 178; // 7 in.
front_baffle_width = speaker_size + 2 * corner_radius + 10; // 10mm extra margin
depth = 250; // arbitrary
rear_width = speaker_size * 0.68; // arbitrary

module wall_ellipse() {
    scale([1, 2, 1]) {
        circle(100);
    } 
}

module left_wall() {
    translate([0, 150, 0]) {
        rotate([0, 0, -10])
        wall_ellipse();
    }
}

module right_wall() {
    translate([front_baffle_width + 20, 0, 0]) {
        rotate([0, 0, 20])
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
    linear_extrude(8) {
        base_cross_section();
    }
}

module left_wall_cutout_ellipse_slice() {
    rotate([0,0,-10])
    difference() {
        wall_ellipse();
        translate([20,0,0])
        wall_ellipse();
    }
}

module left_wall_cutout_ellipse_thin_slice() {
    rotate([0,0,-10])
    difference() {
        wall_ellipse();
        translate([3,0,0])
        wall_ellipse();
    }
}

module left_wall_cutouts() {
    difference() {
        union() {
            left_wall_cutout_ellipse_slice();
            translate([26,0,0])
            left_wall_cutout_ellipse_thin_slice();
            translate([34,0,0])
            left_wall_cutout_ellipse_slice();    
        }
        // FIXME this slice off of the end where the cutouts join together, which I don't want, is still WIP
        translate(50, 220, 0)
        square(100);
    }
}

translate([500, 0, 0]) {
    left_wall_cutouts();
}

module outer_cutout() {
    difference() {
        translate([4, 4, 0])
        scale([0.96, 0.96])
        base_cross_section();
        translate([12, 12, 0])
        scale([0.9, 0.9])
        base_cross_section();
    }
}

module middle_cutout() {
    difference() {
        translate([16, 16, 0])
        scale([0.87, 0.87])
        base_cross_section();
        translate([21, 21, 0])
        scale([0.84, 0.84])
        base_cross_section();
    }
}

module inner_cutout() {
    difference() {
        translate([24, 24, 0])
        scale([0.82, 0.82])
        base_cross_section();
        translate([32, 32, 0])
        scale([0.77, 0.77])
        base_cross_section();
    }
}

module main_volume_cutout() {
    translate([37, 37, 0])
    scale([0.74, 0.74])
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
    translate([0,0,8])
    linear_extrude(1000)
    main_volume_cross_section();
}

base();
main_volume();
