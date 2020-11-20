/* [Parts] */
render_strut = 0;
render_end = 0;
render_body = 1;
render_arch_test = 0;
render_span_test = 0;

/* [Battery] */

battery_holder_type = "45x30x140"; // [45x30x140:5000mAh battery, none:no holder]

/* [Advanced] */
// M3x30mm screws hold struts together. Radius is for a slide-through hole. Length is the actual length of enclosed shaft, which must be at least 5mm less than the actual screw (so there is room for the nut)
screw_radius = 1.8;
// Screw block crosses the inside mating piece and also extends outside the outer piece. It lends strength to sidewalls which may otherwise suffer layer separation under stress
screw_block_radius = 6;
screw_length = 21;
screw_mask_length = screw_length + 0.2;
// Z offset for screw holes. Should merge screw block with structure without cutting into structure with screw shaft hole. Most be at least 2 * screw_radius above arch_wall
screw_z = 9; 

// Leg height is measured from top of motor mount
leg_height = 90;
leg_radius = 10;
leg_wall = 2;

// Outermost arch base and height values
arch_base = 20;
arch_height = 30;

// Thickness of arch wall
arch_wall = 3.3;

// Body main platform thickness
body_platform_thickness = 8;

// Coefficient applied to arch_wall for mating pieces
arch_mating_coefficient = 1.0;

// Strut parameters
strut_length = 150;
strut_leg_end_distance = 40;

// Span from one prop shaft to the opposite determines body width (the central body is a regular octagon)
airframe_span = 600;

// Length of end from joining strut to center of prop shaft. Should be close to 60 but may be adjusted to keep body width to a multiple of 10 or some other neat value.
end_length = 60;

// Length of mating section protrusion and overlap, and tolerance
section_mating = 30;
section_mating_overlap = 30;
// This should fit but may require sanding to make smooth
section_mating_tolerance = 0.28;
// Generate supports for mating sections
section_mating_supports = 1;

// Steps determine resolution and must be an 
// even integer
arch_steps = 32;

/* [Hidden] */

// Parametric arch uses the basic formula of y=Ax^2
// but A is derived from Vy (vertex y) and Zx (base crossing x)
// A = 1 / (Zx / sqrt(Vy)) ^ 2
module arch_section(walls, length, tolerance)
{
    abase = arch_base - 2 * (walls * arch_wall + tolerance);
    // Subtract apex from height with height / base
    // proportion, and subtract base as-is
    aheight = arch_height - walls * arch_wall * arch_height / arch_base - walls * arch_wall - tolerance;
    Zx = abase / 2;
    Zx_term1 = Zx / sqrt(aheight);
    A = 1 / (Zx_term1 * Zx_term1);
    //echo("Base=", abase, "Height=", aheight, "A=", A);
    translate([0,-tolerance - walls * arch_wall,0])
    linear_extrude(height = length, convexity=5)
      arch_poly(abase, aheight, A);
}

// Create inverted arch cross-section polygon
module arch_poly(base,height,A)
{
    bf = base / arch_steps;
    polygon(points=[
    for (n= [-arch_steps/2:arch_steps/2])
        [bf*n, A*bf*bf*n*n - height]
    ]);
}

// New screw_mount() without 45 degree rotation
module new_screw_mount(is_mask, y_offset)
{
    L = (is_mask ? screw_mask_length : screw_length);
    R = (is_mask ? screw_radius : screw_block_radius);
    //rotate([0,0,-45]) 
        //rotate([-180,0,0]) 
            translate([-L/2,-screw_z, y_offset])
                        rotate([0,90,0])
                            cylinder(r=R, h=L, $fn=50);
}

// New strut leg without 45 degree rotation
module new_strut_leg(is_mask, y_offset)
{
    translate([0,0,strut_length - strut_leg_end_distance])
        rotate([90,0,0])
                if (is_mask)
                    translate([0,0,3 * leg_wall]) cylinder(r=leg_radius - 2 * leg_wall, h=leg_height/2);
                else
                difference()
                {
                    cylinder(r=leg_radius, h=leg_height, $fn=50);
                    translate([0,0,-leg_wall])
                        cylinder(r=leg_radius - leg_wall, h=leg_height - 3 * leg_wall, $fn=50);
                    // Make some LED holes also
                    translate([0,0,50])
                        cylinder(r=leg_radius - 2 * leg_wall, h=leg_height, $fn=32);
                    translate([-leg_radius * 1.5,0,leg_height-10])
                        rotate([0,90,0])
                            cylinder(r=3, h=3*leg_radius);
                    translate([0,leg_radius * 1.5,leg_height-10])
                        rotate([90,0,0])
                            cylinder(r=3, h=3*leg_radius);
                }
}

module new_end_unit()
{
    translate([0,0,strut_length])
        difference()
        {
            union()
            {
                difference()
                {
                    union()
                    {
                        arch_section(0,end_length-12,0);
                        new_screw_mount(false,10);
                    }
                    translate([0,0,-1]) arch_section(1, end_length - 12 + 1 - arch_wall, 0);
                    new_screw_mount(true, 10);
                }
                // Motor mount - center of motor (prop shaft)
                // is at end_length from end of strut
                translate([0,-arch_wall * 1.25,end_length])
                rotate([-90,0,0])
                difference()
                {
                    cylinder(r=15, h=arch_wall * 1.25, $fn=50);
                    translate([0,0,-0.2])
                        cylinder(r=4.5, h=arch_wall * 1.5, $fn=50);
                    // Motor holes are spaced 19 and 16mm apart.
                    // Looking down from the top, the longer
                    // (19mm) axis will be at the bottom left
                    // where the mount meets the end piece.
                    a = 9.5 * sin(45);
                    b = 9.5 * cos(45);
                    c = 8 * sin(45);
                    d = 8 * cos(45);
                    translate([-a,-b,-0.2])
                        cylinder(r=1.7, h=arch_wall * 1.5, $fn=50);
                    translate([a,b,-0.2])
                        cylinder(r=1.7, h=arch_wall * 1.5, $fn=50);
                    translate([-d,c,-0.2])
                        cylinder(r=1.7, h=arch_wall * 1.5, $fn=50);
                    translate([d,-c,-0.2])
                        cylinder(r=1.7, h=arch_wall * 1.5, $fn=50);
                }
                // Curved motor mount side supports
                translate([0,-10, end_length])
                rotate([-90,0,0]) difference()
                {
                    cylinder(r=15, h=10, $fn=50);
                    translate([0,0,-0.1]) cylinder(r=13, h=12, $fn=50);
                    translate([0,0,-1]) rotate([-20,0,0]) cube([40,40,10], center=true);
                }
            }
            // Cut end hole
            translate([0,-20,end_length-12-6])
                cylinder(r=3.0, h=10, $fn=50);
            // Cut wire exit hole
            translate([0,-2,end_length-12-12])
              rotate([20,0])
                cube([10,10,8], center=true);
        }
}

// Totally parametric strut unit
module new_strut()
{
    difference()
    {
        union()
        {
            difference()
            {
                union()
                {
                    arch_section(0, strut_length, 0);
                    new_screw_mount(false,10);
                    new_strut_leg(false,strut_length - 36);
                }
                translate([0,0,-1]) arch_section(1, strut_length + 2, 0);
                new_screw_mount(true,10);
                new_strut_leg(true,strut_length - 36);
            }
            translate([0,0,strut_length - section_mating_overlap]) mating(false);
            intersection()
            {
                new_screw_mount(false,strut_length + 10);
                translate([0,0,strut_length - section_mating_overlap]) mating(true);
            }
        }
        new_screw_mount(true,strut_length + 10);
    }
}

// Add a single body mating section
module body_mating(body_width, quadrant)
{
    hw = body_width / 2;
    xd = (quadrant % 2 == 0) ? 0 : ((quadrant == 3) ? -hw : hw);
    yd = (quadrant % 2 == 1) ? 0 : ((quadrant == 2) ? -hw : hw);
    zr = (quadrant % 2 == 1) ? (quadrant == 3 ? -270 : -90) : ((quadrant == 0) ? 0 : -180);
    rotate([0,0,-45])
    translate([xd,yd])
        rotate([0,0,zr])
    difference()
    {
        union()
        {
            translate([0,-section_mating_overlap,0])
                rotate([-90,0,0])
                    mating(false);
            intersection()
            {
                translate([0,19,0])
                    new_screw_mount(false, 9);
                translate([0,-section_mating_overlap,0])
                    rotate([-90,0,0])
                        mating(true);
            }
        }
        translate([0,19,0])
            new_screw_mount(true, 9);
    }
}

function airframe_body_width() = (
    airframe_span - 2 * (strut_length + end_length)
);

// Supported corner cube for power distro opening mask
module pd_corner(cutout, corner, board_thickness, xsign, ysign)
{
    translate([
        xsign * (cutout - corner) / 2, 
        ysign * (cutout - corner) / 2,
        body_platform_thickness/2 + board_thickness
    ])
        cube([corner,corner,body_platform_thickness], center=true);
    // Support for overhang. These will require "support thin features" in Cura.
    for (xoff = [corner, corner*2/3, corner/3])
        for (yoff = [corner, corner*2/3, corner/3])
            translate([
        xsign * (cutout/2 - xoff), 
        ysign * (cutout/2 - yoff),
        0
    ])
       cylinder(r1=1.1, r2=0.2, h=board_thickness);
}

// Screw hole for power distribution board mounting
module pd_corner_hole(holes, hole_r, xsign, ysign)
{
    translate([xsign * holes/2,ysign * holes/2, -1])
        cylinder(r=hole_r, h=12, $fn=50);
    // Nut trap depth should be deep enough
    // for entire nut. M3 nylon insert nuts
    // are around 4.3mm in thickness (thicker
    // than regular ones)
    translate([xsign * holes/2, ysign * holes/2, body_platform_thickness - 4.3])
        cylinder(r=3.2, h=5, $fn=6);
}

// Mask for power distro board opening
module power_distro_mask(body_width)
{
    hw = body_width / 2;
        // Add power distro board 50.5
        // with 8x8 corner insets
    cutout = 50.5;
    board = 50;
    holes = 46;
    corner = 8;
    hole_r = 1.8;
    board_thickness = 2;
        difference()
        {
            translate([0,0,-0.1])
                cube([cutout, cutout, 20], center=true);
            pd_corner(cutout, corner, board_thickness, -1, 1);
            pd_corner(cutout, corner, board_thickness, 1, 1);
            pd_corner(cutout, corner, board_thickness, 1, -1);
            pd_corner(cutout, corner, board_thickness, -1, -1);
        }
        // Add screw holes for PD board
        pd_corner_hole(holes, hole_r, -1, 1);
        pd_corner_hole(holes, hole_r, 1, 1);
        pd_corner_hole(holes, hole_r, 1, -1);
        pd_corner_hole(holes, hole_r, -1, -1);
}

// Battery holder from width, height, length parameters
module battery_holder_parms(width, height, length)
{
    outside_width = width + 5;
    outside_height = height + 2.5;
    outside_length = length + 2.5; // Only one endwall
    side_cutout_width = (outside_length - 12) / 2;
    // Construct base
    for (y = [-length/2 + 1, 0, length/2 - 1])
        translate([0,y,8/2 + body_platform_thickness])
        cube([outside_width + 8, 4, 8], center=true);
    difference()
    {
        translate([0,0,body_platform_thickness + outside_height/2 + 8])
            cube([outside_width, outside_length, outside_height], center=true);
        #translate([0,-2.51,body_platform_thickness + height/2 + 8 - 2.5])
            cube([width-5, length-2.5, height-2.5], center=true);
        // Cut out sides
        #translate([0,side_cutout_width/2 + 2, body_platform_thickness + height/2])
            cube([outside_width + 5, side_cutout_width, 8 + height], center=true);
        #translate([0,-side_cutout_width/2 - 2, body_platform_thickness + height/2])
            cube([outside_width + 5, side_cutout_width, 8 + height], center=true);
        // Cut out bottom
        #translate([0,side_cutout_width/2 + 2,
        body_platform_thickness + height])
            cube([width, side_cutout_width * 0.8, 8 + height], center=true);
        #translate([0,-side_cutout_width/2 - 2,
        body_platform_thickness + height])
            cube([width, side_cutout_width * 0.8, 8 + height], center=true);
    }
    // Add supports for unsupported spans
}

// Battery holder
module battery_holder(body_width)
{
    if (battery_holder_type == "45x30x140")
       battery_holder_parms(45,30,140);
}

// Parametric body. This is an X drone (not +) which means
// the front left and front right arms are at a 45 degree
// angle to the direction of travel. +Y is direction
// of travel
module new_body()
{
    // Determine body width
    body_width = airframe_body_width();
    hw = body_width / 2;
    // Side of a regular octagon, derived from width
    g = body_width / (1 + sqrt(2));
    f = (body_width - g) / 2;
    // Honeycomb radius
    hc = 7.5;
    echo("bw=", body_width, "g=", g, "f=", f);
    difference()
    {
    linear_extrude(convexity=4, height=body_platform_thickness)
        // Points run clockwise and centered around [0,0]
        polygon(points=[
        [g/2,f+g/2],
        [g/2+f,g/2],
        [g/2+f,-g/2],
        [g/2,-f-g/2],
        [-g/2,-f-g/2],
        [-g/2-f,-g/2],
        [-g/2-f,g/2],
        [-g/2,f+g/2]
        ]);
        // Map of hexagonal cells. First column
        // is first row in direction of travel
        hm = [
        [0,0,0,0,0,1,0,0,0,0,0],
        [0,0,0,1,1,1,1,0,0,0,0],
        [0,0,0,1,1,1,1,1,0,0,0],
        [0,1,1,0,0,0,0,1,1,1,0],
        [0,1,1,0,0,0,0,0,1,1,0],
        [1,1,0,0,0,0,0,0,0,0,0],
        [0,1,1,0,0,0,0,0,1,1,0],
        [0,1,1,0,0,0,0,1,1,1,0],
        [0,0,0,1,1,1,1,1,0,0,0],
        [0,0,0,1,1,1,1,0,0,0,0],
        [0,0,0,0,0,1,0,0,0,0,0]
        ];
        for (x=[0:10])
            for (y=[0:10])
            {
                if (hm[x][y])
                    translate([-hw + 15 + x *2 * hc,
                        hw - 14 -y*2*hc - (x%2) * 7.5,-1])
                    cylinder(r=hc,h=10,$fn=6);
            }
        power_distro_mask(body_width);
    }
    // Add mating sections
    for (quadrant=[0:3])
        body_mating(body_width, quadrant);
    // Battery holder
    battery_holder(body_width);
    /*
    Here's the list of items we need to attach:
    [x] Power distro board
    [x] Battery 
    [ ] 4 ESCs
    [ ] Receiver + antenna
    [ ] Flight controller (PixHawk)
    [ ] Power converter
    [ ] Flight converter adapter
    [ ] Telemetry transceiver + antenna
    [ ] FPV camera
    [ ] FPV transceiver + antenna
    [ ] Camera mount
    */
}

// Mating section
module mating(is_mask)
{
    difference()
    {
        arch_section(1, section_mating_overlap, 0);
        if (!is_mask) translate([0,0,-1]) arch_section(2, section_mating_overlap+2, 0);
    }
    translate([0,0,section_mating_overlap]) difference()
    {
        arch_section(1, section_mating, section_mating_tolerance);
        if (!is_mask) translate([0,0,-1]) arch_section(2, section_mating+2, 0);
    }
    if (section_mating_supports)
    {
        for (n=[-6,-4,-2,0,2,4,6])
        translate([n*1.08,0,section_mating+0.5])
        linear_extrude(convexity=3, height=section_mating)
            polygon(points=[
                    [-1,0],
                    [1,0],
                    [0,-arch_wall - section_mating_tolerance]
                    ]);
    }
}

if (render_strut)
{
  rotate([-90,0,0]) 
    new_strut();
}

if (render_end)
{
  rotate([-90,0,0])
    new_end_unit();
}

if (render_body)
{
    body_width = airframe_body_width();
    //rotate([0,0,render_span_test==0 ? 45 : 0])
    new_body();
}

if (render_span_test)
{
    body_width = airframe_body_width();
    #translate([0,-body_width,0]) rotate([-90,0,180])
      new_strut();
    #translate([0,-body_width,0])
        rotate([-90,0,180])
            new_end_unit();
    if (render_end == 0)
        rotate([-90,0,0])
            new_end_unit();
    if (render_strut == 0)
        rotate([-90,0,0])
            new_strut();
    // Airframe span guide
    #translate([0,strut_length + end_length,0])
        rotate([90,0,0])
            cylinder(r=40,h=airframe_span);
}

if (render_arch_test)
{
    if (render_arch_test == 1)
    translate([30,0,0])
    difference()
    {
        arch_section(0,30,0);
        translate([0,0,-0.1]) arch_section(1,31,0);
    }
    if (render_arch_test == 2)
    translate([60,0,0])
    difference()
    {
        echo("inner tolerance:", section_mating_tolerance);
        arch_section(1,30,section_mating_tolerance);
        translate([0,0,-0.1]) arch_section(2,31,0);
    }
}