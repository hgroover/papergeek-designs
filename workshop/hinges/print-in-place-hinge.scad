// Print-in-place hinges will work best in nylon or other tough material. Use PLA to test

/* [General] */

// Print in place tolerance
pip_tolerance = 0.25; // [0.15:0.05:0.4]

/* [Hinge plates] */

// Thickness of hinge plates
thick = 2; // [2.0:0.1:5.0]

// Width of hinge plates
width = 30; // [20:5:100]

// Height of hinge plates and hinge barrel
height = 60; // [40:200]

/* [Hinge segments] */

// Must be odd as one side will enclose the other
count = 5; // [5:2:60]

// Gap between segment and unconnected hinge plate
plate_gap = 0.6; // [0.6:0.1:2.0]

// Gap between segments
segment_gap = 0.3; // [0.2:0.1:0.8]

/* [Screw holes] */

// Number of screwholes
screwhole_count = 3;

// Screwhole top diameter
screwhole_top = 5.0; // [2.5:0.125:8.0]

// Screwhole bottom reduction for countersink
screwhole_bottom_reduce = 1.0; // [0:0.1:1.5]

// Hex nut trap radius (0 to disable, 4.6 for US #6)
hex_nut_trap_radius = 0; // [0.0:0.1:20.0]

// Hex nut trap depth (2.8 for US #6, ignored if hex radius =  0)
hex_nut_trap_depth = 0; // [0.0:0.1:6.0]

/* [Hidden] */
debugMode = true;

core_radius = thick * 1.5;
core_cap_radius = core_radius + thick + segment_gap;
segment_height = (height - (count + 1) * segment_gap) / count;
inside_margin = core_radius + segment_gap;
bottom_margin = height/(screwhole_count + 1);
vertical_spacing = bottom_margin;

// Hinge segment
module hinge_segment(index) {
    translate([0,0,segment_gap + index * (segment_height + segment_gap)]) {
        difference() {
            cylinder(h=segment_height, r=core_radius + segment_gap + thick, $fn=100);
            translate([0,0,-1]) cylinder(h=segment_height+2, r=core_radius + segment_gap, $fn=100);
        }
        if (index % 2 == 0) {
            translate([0,-(core_radius+segment_gap+thick),0]) cube([core_radius+segment_gap+thick, thick, segment_height], center=false);
        } else {
            translate([-(core_radius+segment_gap+thick),-(core_radius+segment_gap+thick),0]) cube([core_radius+segment_gap+thick, thick, segment_height], center=false);
        }
    }
}

// Hinge plate without left/right rotation
module hinge_plate_base() {
    intersection() {
      linear_extrude(thick, center=false, $fn=50)
        offset(r=+3) 
            offset(delta=-3)
                square(size=[width+3,height], center=false);
      linear_extrude(thick, center=false, $fn=50)
            square(size=[width, height], center=false);
    }
}

function hole_horizontal_spacing(index) = (index % 2) == 0 ? width/4 : -width/4 + inside_margin;


// Hole object
module hole_object(index, right_shift) {
    // Local vars are automatic since 2015.03
    //echo("index", index, "rs", right_shift, "hs", hole_horizontal_spacing(index));
    height_addition = (hex_nut_trap_radius == 0) ? 0.2 : 2 * hex_nut_trap_depth;
    translate([right_shift*(core_radius+segment_gap+width/2 + hole_horizontal_spacing(index)), -(core_radius+segment_gap-height_addition/2), bottom_margin + vertical_spacing * index])
        rotate([90,0,0])
            cylinder(h=thick+height_addition, r1=screwhole_top/2, r2=(screwhole_top-screwhole_bottom_reduce)/2, $fn=50);
}

// Hex nut trap if enabled
module hex_nut_trap(index, right_shift) {
    if (hex_nut_trap_radius > 0 && hex_nut_trap_depth > 0) {
        difference() {
            translate([right_shift * (core_radius + segment_gap + width/2 + hole_horizontal_spacing(index)), -(core_radius+segment_gap-thick), bottom_margin + vertical_spacing * index])
                rotate([90,0,0])
                    linear_extrude(hex_nut_trap_depth, center=false)
                        circle( r=hex_nut_trap_radius+thick, $fn=6);
            translate([right_shift * (core_radius + segment_gap + width/2 + hole_horizontal_spacing(index)), -(core_radius+segment_gap-thick-0.1), bottom_margin + vertical_spacing * index])
                rotate([90,0,0])
                    linear_extrude(hex_nut_trap_depth+0.2, center=false)
                        circle( r=hex_nut_trap_radius, $fn=6);
        }
    }
}

// Right hinge plate with holes
module hinge_plate_right() {
    difference() {
        union() {
            translate([(width+core_radius+segment_gap+thick), -(core_radius+segment_gap), height+segment_gap])
                rotate([-90,0,180])
                    hinge_plate_base();
            for (n=[0:1:screwhole_count-1])
                hex_nut_trap(n, 1);
        }
        for (n=[0:1:screwhole_count-1])
            hole_object(n, 1);
    }
}

// Left hinge plate with holes
module hinge_plate_left() {
    difference() {
        union() {
            translate([-(width+core_radius+segment_gap+thick), -(core_radius+segment_gap+thick), height+segment_gap])
                rotate([-90,0,0])
                    hinge_plate_base();
            for (n=[0:1:screwhole_count-1])
                hex_nut_trap(n, -1);
        }
        for (n=[0:1:screwhole_count-1])
            hole_object(n, -1);
    }
}

translate([0,0,core_cap_radius]) rotate([90,0,0]) {
    union() {
        
// Generate floating core
union() {
    cylinder(h=height, r=core_radius, $fn=100);
    translate([0,0,-thick])
        cylinder(h=thick, r=core_cap_radius, $fn=50);
    translate([0,0,height])
        cylinder(h=thick, r=core_cap_radius, $fn=50);
}

        // Generate segments with tabs to attach to hinge plates
        for (n=[0:1:count-1])
            hinge_segment(n);

        // Right hinge plate
        hinge_plate_right();

        // Left hinge plate
        hinge_plate_left();

    }
}