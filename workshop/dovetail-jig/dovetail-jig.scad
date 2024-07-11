/* [General] */

// Use decimal inches (US)
us_measurement = 1; // [0:millimeters, 1:decimal inches]

// Tolerance - extra space to add for pins. 0 will leave no room for glue. Reduces pin mask polygon corners inwards by this amount on each side.
tolerance = 0.002;

// Jig thickness
jig_thickness = 0.5;

// Endstop thickness
endstop_thickness = 0.5;

// Endstop height
endstop_height = 1.5;

// Spine (center stop) thickness
spine_thickness = 0.5;

// Spine height
spine_height = 1.5;

// Show boards (debugging aid)
show_boards = 7; // [0:none, 1:material-tails, 2:material-pins, 3:tails+pins, 4:spoiler, 5:spoiler+tails, 6:spoiler+pins, 7:all]

/* [Router] */

// Dovetail bit width
router_bit_dovetail_width = 0.75;

// Dovetail bit angle (degrees)
router_bit_dovetail_angle = 14;

// Template diameter
router_template_diameter = 0.625;

/* [Material] */

// Material (board) thickness
material_thickness = 0.75;

// Material width
material_width = 8.0;

/* [Spoiler] */

// Spoiler board thickness
spoiler_thickness = 0.75;

/* [Hidden] */

inches_to_mm = 25.4;

/*
 Through dovetail jig with stops
 
 This is a jig for cutting through dovetails with a router. A template is needed along with
 spoiler board (MDF typically)
 block clamps to hold the material and spoiler board to the jig
 a straight bit (for cutting pins)
 a dovetail bit (for cutting tails)
 
 There is a much better dovetail jig design which can be adjusted. This is a lazy design meant to be generated for your work parameters, clamped in place, and probably used only 4 times. If you're the type of person who will design and 3d-print something just for a one-off woodworking project, this is probably for you...
 You should still read through this guide as it's written by an experienced woodworker: https://www.instructables.com/3D-Printed-Jig-for-Through-Dovetails-With-Variable/
 
 Using the dovetail jig
 
 The usage is a bit baffling at first but essentially:
   - you will cut two boards of the same width with the router,
     along the end where they are to be joined
   - a board is either cut with the dovetail bit ("tails")
     or with a straight bit using the wedge-shaped
     finger guides ("pins")
   - the endstop should line up with one edge of a board end. Mark the edge where the endstop went (either P for pin or T for tail) because the same edge should be joined.
     
 Recommended material would be PLA-CF or something with similar strength
 
 A 220x220 printer (I am using the Creality K1C) should be able to handle up to 8 inch board widths (204mm). Turn off brims in the slicer settings.
*/

function ucnv(local_units) = (us_measurement == 0) ? local_units
    : local_units * inches_to_mm;

function is_bit_set(n,shift) = (n / pow(2,shift)) % 2;

// ================
// Main entry point
// ================

// Spine and endstop
solid_width = 2 * spoiler_thickness + spine_thickness;
tails_tr = material_width + endstop_thickness;
tails_tr_y = router_template_diameter/2;
fingers_bl_x = material_width;
fingers_bl_y = spoiler_thickness + spine_thickness;
turning_width = router_template_diameter;
// Tail spacing is the greater of dovetail diameter and template diameter, times 2
tail_slot_width = (router_template_diameter > router_bit_dovetail_width) ? router_template_diameter : router_bit_dovetail_width;
tail_spacing = tail_slot_width;
// Single end padding
tail_end_padding = 1.25 * tail_slot_width;
// Available room for tails
tail_avail = material_width - 2 * tail_end_padding;
// Tail / pin count of slots + teeth
tail_count = floor(tail_avail / tail_spacing);
// Tooth count must be such that slots = teeth + 1. Teeth are variable width (for tails) and slots are fixed width.
tail_tooth_count = (tail_count % 2 == 0) ? floor(tail_count / 2) - 1 : floor(tail_count / 2);
tail_slot_count = tail_tooth_count + 1;
tail_tooth_width = (tail_avail - tail_slot_count * tail_slot_width) / tail_tooth_count;
echo("tsc",tail_slot_count,"ttw",tail_tooth_width,"ttc",tail_tooth_count,"tep",tail_end_padding,"tav",tail_avail,"tsw",tail_slot_width);
// Finger values
h1 = router_template_diameter + material_thickness;
w3 = router_bit_dovetail_width / 2;
w4 = tan(router_bit_dovetail_angle) * material_thickness;
w5 = tan(router_bit_dovetail_angle) * router_template_diameter / 2;
w1 = w3 + w5;
w2 = w3 - w4;
w7 = w2 - w5;
pin0_center = fingers_bl_x - tail_end_padding - tail_slot_width / 2;
// Spacing for pins center-to-center
pin_spacing = tail_tooth_width + tail_slot_width;
pin_base_y = fingers_bl_y + spoiler_thickness - router_template_diameter / 2;
union()
{
    // Solid part of the jig
    translate([0,ucnv(router_template_diameter/2),0])
        cube([ucnv(material_width + endstop_thickness), ucnv(solid_width-router_template_diameter), ucnv(jig_thickness)]);
    // endstop covering only center, material and spoiler
    difference()
    {
        translate([ucnv(material_width),ucnv(-material_thickness),ucnv(jig_thickness)])
            cube([ucnv(endstop_thickness), ucnv(solid_width+2*material_thickness), ucnv(endstop_height)]);
        // Cut out material thickness from finger endstop
        translate([ucnv(material_width-endstop_thickness*0.01),ucnv(material_thickness+spine_thickness)*1.01,ucnv(jig_thickness)*0.99])
            cube([ucnv(endstop_thickness*1.04),ucnv(material_thickness+spoiler_thickness)*1.04, ucnv(material_thickness * 1.02)]);
    }
    // Spine
    translate([0,ucnv(spoiler_thickness),ucnv(jig_thickness)])
        cube([ucnv(material_width),ucnv(spine_thickness),ucnv(spine_height)]);
    // Debug visualization
    // 0x01 - tails board
    if (is_bit_set( show_boards, 0 ))
        %translate([0,-ucnv(material_thickness),ucnv(jig_thickness)])
            cube([ucnv(material_width),ucnv(material_thickness),70]);
    // 0x02 - pins board
    if (is_bit_set( show_boards, 1 ))
        %translate([0,ucnv(spoiler_thickness+spine_thickness+material_thickness),ucnv(jig_thickness)])
            cube([ucnv(material_width),ucnv(material_thickness), 70]);
    // 0x04 - spoiler boards
    if (is_bit_set( show_boards, 2 ))
    {
        %translate([-50,0,ucnv(jig_thickness)])
            cube([50+ucnv(material_width),ucnv(spoiler_thickness),100]);
        %translate([-50,ucnv(spoiler_thickness+spine_thickness),ucnv(jig_thickness)])
            cube([50+ucnv(material_width),ucnv(spoiler_thickness),100]);
    }
    // Slot guides for tails
    %translate([ucnv(tails_tr), ucnv(tails_tr_y), -10])
        cube([10,10,40]);
    // Part 1 - end padding
    linear_extrude(height=ucnv(jig_thickness))
        polygon(points=[
                [ucnv(tails_tr+0), ucnv(tails_tr_y)],
                [ucnv(tails_tr+0), ucnv(-material_thickness-turning_width)],
                [ucnv(tails_tr-endstop_thickness-tail_end_padding),ucnv(-material_thickness-turning_width)],
                [ucnv(tails_tr-endstop_thickness-tail_end_padding),ucnv(tails_tr_y)],
                [ucnv(tails_tr-endstop_thickness-tail_end_padding-tail_avail),ucnv(tails_tr_y)],
                [ucnv(tails_tr-endstop_thickness-tail_end_padding-tail_avail),ucnv(-material_thickness-turning_width)],
                [ucnv(tails_tr-endstop_thickness-tail_end_padding-tail_avail-tail_end_padding),ucnv(-material_thickness-turning_width)],
                [ucnv(tails_tr-endstop_thickness-tail_end_padding-tail_avail-tail_end_padding),ucnv(tails_tr_y+0.25)],
                [ucnv(tails_tr+0), ucnv(tails_tr_y+0.25)]
            ]);
    // Part 2 - teeth for tails
    for (i=[1:tail_tooth_count])
        translate([ucnv(tail_avail+tail_end_padding-tail_tooth_width -
    i*tail_slot_width - (i-1)*tail_tooth_width),ucnv(-spoiler_thickness-turning_width),0])
            cube([ucnv(tail_tooth_width), ucnv(material_thickness+turning_width+router_template_diameter/2), ucnv(jig_thickness)]);
    // Finger guides for pins. Template will be flipped but we're forcing it to be symmetrical
    %translate([ucnv(fingers_bl_x), ucnv(fingers_bl_y), -10])
        cube([10,10,40]);
    for (i=[1:tail_slot_count])
    {
        pin_center = pin0_center - (i-1) * pin_spacing;
        linear_extrude(height=ucnv(jig_thickness))
            polygon(points=[
                [ucnv(pin_center+w1-tolerance), ucnv(pin_base_y)],
                [ucnv(pin_center-w1+tolerance), ucnv(pin_base_y)],
                [ucnv(pin_center-w7+tolerance), ucnv(pin_base_y+h1)],
                [ucnv(pin_center+w7-tolerance), ucnv(pin_base_y+h1)]
            ]);
    }
}

// Example
/*
linear_extrude(height=ucnv(jig_thickness))
    polygon(points=[
        [0+ucnv(0.8), 0+ucnv(0.8)],
        [0+ucnv(0.8), 0+ucnv(2.2)],
        [0+ucnv(5.4), 0+ucnv(2.2)],
        [0+ucnv(5.4), 0+ucnv(0.8)]
    ]);
    */