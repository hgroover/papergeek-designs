// Print-in-place hinges will work best in nylon or other tough material. Use PLA to test

/* [General] */

// Fuselage outer diameter
fuselage_outer_diam = 25.1; // [10.0:0.1:70.0]

// Fin can thickness
fin_can_thickness = 1.4; // [0.4:0.1:3.0]

/* [Fins] */

// Fin count
fin_count = 3; // [2:1:8]

// Fin root chord length
fin_root_chord = 57.15; // [10.0:0.05:100.0]

// Fin root thickness
fin_root_thickness = 1.4; // [0.2:0.1:3.0]

// Fin root tightness
fin_root_tightness = -0.1; // [-0.5:0.1:0.5]

/* [Fin root support] */
fin_root_support_thickness = 2.0;
fin_root_support_height = 5.0;
fin_root_support_taper = 1.0;

/* [Launch lug] */

lug_length = 20.0;

// For 3/16 use 4.8; for 1/8 use 3.2
lug_rod_diameter = 4.8;

// Lug standoff distance from outside of fuselage
lug_standoff = 3;

/* [Hidden] */
debugMode = true;

fin_angle = 360 / fin_count;
sleeve_length = fin_root_chord + 10;
fin_root_total_thickness = 2 * fin_root_support_thickness + fin_root_thickness;
fin_slot_width = fin_root_thickness - fin_root_tightness;

//function inside_margin() = core_radius + segment_gap + extra_inside_margin;

// Sleeve tube
module sleeve_tube() {
    difference() {
        cylinder(h=sleeve_length, r=(fuselage_outer_diam + fin_can_thickness)/2, center = true, $fn=80);
        cylinder(h=sleeve_length+2, r=fuselage_outer_diam/2, center=true, $fn=80);
    }
}

// Fin root support cutter
module fin_support_cutter() {
        translate([0,0,-0.4]) linear_extrude( height = fin_root_chord + 0.41, center = false, $fn=60 )
            polygon( points=[
                [-fin_slot_width/2, fin_can_thickness+0.1],
                [fin_slot_width/2, fin_can_thickness+0.1],
                [fin_slot_width/2, fin_can_thickness+100],
                [-fin_slot_width/2, fin_can_thickness+100]
                       ] );
}

// Fin support crown - stop for vertical alignment
module fin_support_crown() {
    difference() {
        translate([0,0,sleeve_length/2-10])
            rotate_extrude($fn=200) 
                polygon( points=[
                    [fuselage_outer_diam/2,0],
                    [fuselage_outer_diam/2,-2],
                    [fuselage_outer_diam/2+3,0],
                    [fuselage_outer_diam/2,3]
                ] );
        for (n=[0:1:fin_count-1])
            rotate(a=n * fin_angle, v=[0,0,1])
                translate([0,fuselage_outer_diam/2,-sleeve_length/2])
                    fin_support_cutter();
    }
}

// Single fin root support
module fin_root(index) {
    rotate(a=index * fin_angle, v=[0,0,1])
    translate([0,fuselage_outer_diam/2,-sleeve_length/2])
    difference() {
        linear_extrude( height = fin_root_chord, center = false, $fn=60 )
            polygon( points=[
        [-fin_root_total_thickness/2,0], [fin_root_total_thickness/2,0], 
        [fin_root_total_thickness/2-fin_root_support_taper/2, fin_root_support_height], 
        [-fin_root_total_thickness/2+fin_root_support_taper/2, fin_root_support_height]
        ] );
        fin_support_cutter();
    }
}

// Launch lug
module launch_lug() {
    rotate(a=fin_angle/2, v=[0,0,1])
      translate([0,fuselage_outer_diam/2,-sleeve_length/2])
        difference() {
            union() {
              linear_extrude(height = lug_length, center=false)
                polygon( points=[
                        [-lug_rod_diameter/2,0],
                        [lug_rod_diameter/2,0],
                        [lug_rod_diameter/2,lug_rod_diameter],
                        [-lug_rod_diameter/2,lug_rod_diameter]
                        ] );
                translate([0,lug_standoff + (0.0 + lug_rod_diameter)/2,0])
                    cylinder(h=lug_length, r=0.8+(lug_rod_diameter/2), center=false, $fn=60);
            }
            translate([0,lug_standoff + lug_rod_diameter/2,-1]) cylinder(h = lug_length+2, r=lug_rod_diameter/2, $fn=60);
        }
}

echo ("Fin angle", fin_angle);
/*translate([0,0,core_cap_radius]) rotate([90,0,0]) */ {
    union() {
        
        sleeve_tube();
        fin_support_crown();
        launch_lug();
        
        for (n=[0:1:fin_count-1])
            fin_root(n);

    }
}