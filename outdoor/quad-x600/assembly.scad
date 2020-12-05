/* [Parts] */
// Render a single strut
render_strut = 0;
// Render end assembly which attaches to strut
render_end = 0;
// Render central body with selected battery holder type
render_body = 1;
// Render battery holder
render_battery_holder = 0;
// Render shell and attachment tower
render_shell = 0;
// Render attachment tower
render_pixhawk = 0;
// Render GPS traveller
render_gps = 0;
// Render spacers used with attachment tower
render_spacers = 0;
render_arch_test = 0;
render_span_test = 0;

/* [Battery] */

// Size of battery holder
battery_holder_type = "45x30x140"; // [45x30x140:5000mAh battery]

/* [Advanced] */
// M3x30mm screws hold struts together. Radius is for a slide-through hole.
screw_radius = 1.8; 
// Screw block crosses the inside mating piece and also extends outside the outer piece. It lends strength to sidewalls which may otherwise suffer layer separation under stress. The lower end of the screw block gets flattened to make room for wires
screw_block_radius = 6; 
// Length is the actual length of enclosed shaft, which must be at least 5mm less than the actual screw (so there is room for the nut)
screw_length = 21; 
screw_mask_length = screw_length + 0.2;

// Z offset from flat top of strut for screw holes. Should merge screw block with structure without cutting into structure with screw shaft hole. Most be at least 2 * screw_radius above arch_wall
screw_z = 9; 

// Radius of nut trap, measured at largest (point-to-point) diameter of nut. Default is M3 nut with nylon insert
nut_trap_radius = 3.65;
// Depth of nut trap. Generally 2.5mm is enough but nylon insert nuts are deeper. More depth may be needed to keep the nut completely flush.
nut_trap_depth = 3.6; 

// Strut leg height is measured from top of motor mount
leg_height = 90;
// Strut leg radius
leg_radius = 10;
// Strut leg wall thickness
leg_wall = 2;

// Outermost arch base
arch_base = 20;
// Outermost arch height
arch_height = 30;

// Thickness of arch wall
arch_wall = 3.3;

// Body main platform thickness
body_platform_thickness = 8;

// Coefficient applied to arch_wall for mating pieces
arch_mating_coefficient = 1.0;

// Strut parameters
// Length added to structure by strut (does not include mating insertion)
strut_length = 150; 
// Distance of leg from outside end of strut
strut_leg_end_distance = 40; 

// Span from one prop shaft to the opposite determines body width (the central body is a regular octagon)
airframe_span = 600;

// Length of end from joining strut to center of prop shaft. Should be close to 60 but may be adjusted to keep body width to a multiple of 10 or some other neat value.
end_length = 60;

// Length of mating section protrusion
section_mating = 30; 
// Length of mating section overlap
section_mating_overlap = 30; 
// Mating section tolerance. Should fit but may require sanding to make smooth.
section_mating_tolerance = 0.28; 

// Generate supports for mating sections
section_mating_supports = 1; 

// Steps determine resolution and must be an even integer
arch_steps = 32;

/* [Hidden] */
model_ver = 3;

/*
********** Version history **********
Version  Changes
1        First print
2        Fixed dimensional problems in first body print
3        Addressing issues in second print
*************************************
*/
/* 
********** Slicing notes: *******
No supports - uses intrinsic supports
Infill 50%, PLA, brim needed on glass.
Print thin walls needed for Cura!
******* end slicing notes *******
*/

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

// Flattening object - if 0 (default), none, 1=z offset (strut protrusion), 2=y offset (body), 3=none (end unit or strut receptacle)
module screw_mount_flattener(flattener_type, y_offset, L, R)
{
    if (flattener_type == 2)
            translate([0, -screw_z, y_offset + screw_block_radius + screw_radius])
                cube([L*1.5, R*4, screw_block_radius*2], center=true);
    if (flattener_type == 1)
        translate([0, -screw_z - R, y_offset + screw_block_radius])
            cube([L*1.5, screw_block_radius * 2, R*4], center=true);
}

// New screw_mount() without 45 degree rotation
module new_screw_mount(is_mask, y_offset, flatten)
{
    L = (is_mask ? screw_mask_length : screw_length);
    R = (is_mask ? screw_radius : screw_block_radius);
    // Flatten part of screw block to make room for wires
    difference()
    {
    //rotate([0,0,-45]) 
        //rotate([-180,0,0]) 
            translate([-L/2,-screw_z, y_offset])
                        rotate([0,90,0])
                            cylinder(r=R, h=L, $fn=50);
        if (!is_mask)
            screw_mount_flattener(flatten, y_offset, L, R);
    }
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
                        new_screw_mount(false,10,3);
                    }
                    translate([0,0,-1]) arch_section(1, end_length - 12 + 1 - arch_wall, 0);
                    new_screw_mount(true, 10, 3);
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
            // Receptacle end of strut which joins body
            difference()
            {
                union()
                {
                    arch_section(0, strut_length, 0);
                    new_screw_mount(false,10,3);
                    new_strut_leg(false,strut_length - 36);
                }
                translate([0,0,-1]) arch_section(1, strut_length + 2, 0);
                new_screw_mount(true,10,3);
                new_strut_leg(true,strut_length - 36);
            }
            // Protrusion end of strut
            translate([0,0,strut_length - section_mating_overlap]) mating(false);
            intersection()
            {
                new_screw_mount(false,strut_length + 10, 1);
                translate([0,0,strut_length - section_mating_overlap]) mating(true);
            }
        }
        new_screw_mount(true,strut_length + 10, 1);
    }
}

// Add a single body mating section with space for ESC
module body_mating(body_width, quadrant, is_mask)
{
    hw = body_width / 2;
    xd = (quadrant % 2 == 0) ? 0 : ((quadrant == 3) ? -hw : hw);
    yd = (quadrant % 2 == 1) ? 0 : ((quadrant == 2) ? -hw : hw);
    zr = (quadrant % 2 == 1) ? (quadrant == 3 ? -270 : -90) : ((quadrant == 0) ? 0 : -180);
    rotate([0,0,-45])
    translate([xd,yd])
        rotate([0,0,zr])
    union()
    {
      if (!is_mask) difference()
      {
        union()
        {
            translate([0,-section_mating_overlap,0])
                rotate([-90,0,0])
                    mating(false);
            intersection()
            {
                translate([0,19,0])
                    new_screw_mount(false, 9, 2);
                translate([0,-section_mating_overlap,0])
                    rotate([-90,0,0])
                        mating(true);
            }
        }
        translate([0,19,0])
            new_screw_mount(true, 9, 2);
        // Remove inner part
        translate([0,-section_mating_overlap,0])
          rotate([-90,0,0])
            arch_section(0, section_mating_overlap, 0);
      }
      if (!is_mask) difference()
      {
          union()
          {
              // Add back in larger adapter for ESC
              /***
              translate([0,-4,0])
                rotate([-90,0,0])
                    arch_section(1, 4, 0);
              translate([0,-8,0])
                rotate([-90,0,0])
                    arch_section(0, 4, 0);
              ***/
              translate([0,-section_mating_overlap, 0])
                rotate([-90,0,0])
                    arch_section(-2,section_mating_overlap,0);
          }
          // Cut out inside
          translate([0,-section_mating_overlap-1,0])
            rotate([-90,0,0])
                arch_section(2,section_mating_overlap+2,0);
          translate([0,-section_mating_overlap-1,0])
            rotate([-90,0,0])
                arch_section(-1.33,section_mating_overlap-1,0);
          // Remove the bottom of the -2 arch sticking out of the bottom
          translate([0,0,-8])
            cube([100,100,16], center=true);
          // Drill transverse hole for zipties to keep ESC in place
          translate([-20,-20,20])
            rotate([0,90,0])
              cylinder(r=4, h=40, $fn=50);
      }
      if (is_mask)
          difference()
          {
            translate([0,-section_mating_overlap-15,0])
                rotate([-90,0,0])
                    arch_section(0,section_mating_overlap+15-1,0);
            cube([100,100,4], center=true);
          }
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
    cutout = 50.5 + 0.5;
    board = 50;
    holes = 45;
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
        // Add screw holes for PD board. With board_thickness == 8, M3x8 screws work once nuts are all in
        pd_corner_hole(holes, hole_r, -1, 1);
        pd_corner_hole(holes, hole_r, 1, 1);
        pd_corner_hole(holes, hole_r, 1, -1);
        pd_corner_hole(holes, hole_r, -1, -1);
}

// Battery holder from width, height, length parameters (size of battery to be accommodated)
module battery_holder_parms(width, height, length)
{
    // Mount holes are 120x60 OC (Y is the long axis)
    mount_spacing_y = 120;
    mount_spacing_x = 60;
    // Offset above surface to allow PD board wires to exit
    surface_offset = 12;
    // Outside dimensions do not include base with surface
    // offset - they only encapsulate the wall thicknesses.
    outside_width = width + 8;
    outside_height = height + 2.5;
    outside_length = length + 2.5; // Only one endwall
    side_cutout_width = (length - 4 * 6) / 4;
    side_cutout_height = height - 6 - 6;
    echo("bh(",width,height,length,") oh=", outside_height, "ow=", outside_width, "ol=", outside_length);
    difference()
    {
        union()
        {
        // Construct base
        for (y = [-length/2 + 0.75, 0, length/2 - 0.75])
            translate([0,y,surface_offset/2])
            cube([outside_width + surface_offset, 4, surface_offset], center=true);
            // Source material for holder needs to be suspended below platform with room for wires to come out (10-12 AWG main battery wires)
            translate([0,0,outside_height/2 + surface_offset])
                cube([outside_width, outside_length, outside_height], center=true);
            // Sidebars connecting supports are formed by reducing side cutouts
            // Add screw bulkheads for attachment
            translate([mount_spacing_x/2 - 1.5, mount_spacing_y/2, surface_offset/2])
                cube([12,15,surface_offset], center=true);
            translate([mount_spacing_x/2 - 1.5, -mount_spacing_y/2, surface_offset/2])
                cube([12,15,surface_offset], center=true);
            translate([-mount_spacing_x/2 + 1.5, mount_spacing_y/2, surface_offset/2])
                cube([12,15,surface_offset], center=true);
            translate([-mount_spacing_x/2 + 1.5, -mount_spacing_y/2, surface_offset/2])
                cube([12,15,surface_offset], center=true);
        }
        // Cut out main space for battery
        translate([0,-2.75,height/2 + surface_offset -0.01])
            cube([width, length, height+0.02], center=true);
        // Reduce screw bulkheads
        translate([mount_spacing_x/2 + 1, mount_spacing_y/2 - 2.5, surface_offset/2 + 3])
            cube([12,15,surface_offset], center=true);
        translate([mount_spacing_x/2 + 1, -mount_spacing_y/2 + 2.5, surface_offset/2 + 3])
            cube([12,15,surface_offset], center=true);
        translate([-mount_spacing_x/2 - 1, mount_spacing_y/2 - 2.5, surface_offset/2 + 3])
            cube([12,15,surface_offset], center=true);
        translate([-mount_spacing_x/2 - 1, -mount_spacing_y/2 + 2.5, surface_offset/2 + 3])
            cube([12,15,surface_offset], center=true);
        // Cut out sides
        for (y=[0, 1, 2, 3])
        {
            translate([0,side_cutout_width/2 - length/2 + 4 + y * (side_cutout_width + 6), side_cutout_height/2 + surface_offset + 6])
                cube([outside_width + 5, side_cutout_width, side_cutout_height], center=true);
            // Cut out bottom
            translate([0,side_cutout_width/2 - length/2 + 4 + y * (side_cutout_width + 6),
        height])
                cube([width, side_cutout_width, surface_offset + height], center=true);
        }
        // Drill holes for support attachment
        #translate([mount_spacing_x/2, mount_spacing_y/2, -0.1])
            cylinder(r=screw_radius, h=surface_offset + 1, $fn=48);
        #translate([mount_spacing_x/2, -mount_spacing_y/2, -0.1])
            cylinder(r=screw_radius, h=surface_offset + 1, $fn=48);
        #translate([-mount_spacing_x/2, mount_spacing_y/2, -0.1])
            cylinder(r=screw_radius, h=surface_offset + 1, $fn=48);
        #translate([-mount_spacing_x/2, -mount_spacing_y/2, -0.1])
            cylinder(r=screw_radius, h=surface_offset + 1, $fn=48);
    }
    // Add supports for unsupported spans
    /**********
    translate([width/2 + 1, side_cutout_width/2 + 2, (height + 12) / 2])
        cube([0.2, side_cutout_width - 0.4,  body_platform_thickness + height + 3.8], center=true);
    translate([-width/2 - 1, side_cutout_width/2 + 2, (height + 12) / 2])
        cube([0.2, side_cutout_width - 0.4,  body_platform_thickness + height + 3.8], center=true);
    translate([width/2 + 1, -side_cutout_width/2 - 2, (height + 12) / 2])
        cube([0.2, side_cutout_width - 0.4,  body_platform_thickness + height + 3.8], center=true);
    translate([-width/2 - 1, -side_cutout_width/2 - 2, (height + 12) / 2])
        cube([0.2, side_cutout_width - 0.4,  body_platform_thickness + height + 3.8], center=true);
    #translate([0,0, (height + 10.4 - 2.5 + body_platform_thickness) / 2])
        cube([width - 0.4, 0.2, body_platform_thickness + height + 10.4 - 2.5], center=true);
    #translate([0,-side_cutout_width - 4, (height +10.4 - 2.5 + body_platform_thickness) / 2])
        cube([width - 0.4, 0.2, body_platform_thickness + height + 10.4 - 2.5], center=true);
    ********/
}

// Battery holder
module battery_holder(body_width)
{
    if (battery_holder_type == "45x30x140")
       battery_holder_parms(45,30,140);
}

// Nut trap mask. Normal orientation is nut on "top" (printed bottom) and screw on bottom
module nut_trap(xoff, yoff, flipped)
{
    translate([xoff, yoff, -0.1 + (flipped ? body_platform_thickness + 0.2 : 0)])
        #rotate([flipped ? 180 : 0, 0, 0]) union()
        {
            cylinder(r=nut_trap_radius, h=nut_trap_depth, $fn=6);
            translate([0,0,nut_trap_depth-0.1])
                cylinder(r=screw_radius, h=body_platform_thickness * 1.2, $fn=50);
        }
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
        union()
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
            // Add mating sections
            for (quadrant=[0:3])
                body_mating(body_width, quadrant, false);
        }
        // Map of hexagonal cells. First column
        // is first row in direction of travel
        hm = [
        [0,0,0,0,0,1,0,0,0,0,0],
        [0,0,0,1,1,1,1,0,0,0,0],
        [0,0,0,0,1,1,1,0,0,0,0],
        [0,0,1,0,0,0,0,1,0,0,0],
        [0,1,1,0,0,0,0,0,1,1,0],
        [1,1,0,0,0,0,0,0,1,1,0],
        [0,1,1,0,0,0,0,0,1,1,0],
        [0,0,1,0,0,0,0,1,0,0,0],
        [0,0,0,0,1,1,1,0,0,0,0],
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
        // Subtract mating section masks
        for (quadrant=[0:3])
            body_mating(body_width, quadrant, true);
        // Subtract mounting holes with nut traps
        noff = 2 * nut_trap_radius;
        noff2 = 1.2 * nut_trap_radius;
        nut_trap(-hw + noff, -g/2 + noff2, false);
        nut_trap(-hw + noff, g/2 - noff2, false);
        nut_trap(hw - noff, -g/2 + noff2, false);
        nut_trap(hw - noff, g/2 - noff2, false);
        // Add a few mount holes in the back
        nut_trap(g/2 - noff2, -hw + noff, false);
        nut_trap(-g/2 + noff2, -hw + noff, false);
        nut_trap(25, -hw + 2 * noff, false);
        nut_trap(-25, -hw + 2 * noff, false);
        nut_trap(40, -hw + 2.5 * noff, false);
        nut_trap(-40, -hw + 2.5 * noff, false);
        // Front has usual mount holes with some extras
        nut_trap(g/2 - noff2, hw - noff, false);
        nut_trap(-g/2 + noff2, hw - noff, false);
        nut_trap(15, hw - noff, false);
        nut_trap(-15, hw - noff, false);
        nut_trap(25, hw - 2 * noff, false);
        nut_trap(-25, hw - 2 * noff, false);
        nut_trap(40, hw - 2.5 * noff, false);
        nut_trap(-40, hw - 2.5 * noff, false);
        // Add mounting holes for Pixhawk standoff pillars
        nut_trap(-33, 22, true);
        nut_trap(-33, -22, true);
        nut_trap(33, 22, true);
        nut_trap(33, -22, true);
        // Add mounting holes for battery holder
        nut_trap(30, 60, false);
        nut_trap(30, -60, false);
        nut_trap(-30, 60, false);
        nut_trap(-30, -60, false);
        // Add mounting holes for other components on sides
        nut_trap(hw-15, -g/2 + 15, true);
        nut_trap(hw-15, g/2 - 15, true);
        nut_trap(hw-57, 0, true);
        nut_trap(-hw+15, -g/2 + 15, true);
        nut_trap(-hw+15, g/2 - 15, true);
        nut_trap(-hw+57, 0, true);
        // More mounting holes on trailing edge
        nut_trap(-15, -hw+12, true);
        nut_trap(15, -hw+12, true);
    }
    // Battery holder is now separate
    //battery_holder(body_width);
    // Version stamp
    translate([0,hw-6,body_platform_thickness])
        linear_extrude(1) text(str("v", model_ver), size=8, font="Liberation Mono:style=Regular", halign="center", valign="center");
    /*
    Here's the list of items we need to attach:
    Bottom (here in new_body):
    [x] Power distro board
    [x] Battery 
    [x] Battery span supports
    [x] 4 ESCs
    Top:
    [ ] Receiver + antenna
    [ ] Flight controller (PixHawk)
    [ ] Power converter
    [ ] Flight converter adapter
    [ ] Telemetry transceiver + antenna
    [ ] FPV camera
    [ ] FPV transceiver + antenna
    [ ] Camera mount
    Shell:
    [ ] GPS receiver / compass
    
    Defects found in first print (v1):
    [x] Battery holder opening did not come out
        as specified: supposed to be 45x30, actual 39.75 x 26.something
    [x] PD board opening about 0.5mm too small
    [x] PD board holes too close
    [x] Wire clearances in inserts are too tight (need to fit 3x18ga plus LEDs, and wires need to have bullet plugs)
    [x] ESC arches are not tall enough to manage insertion angle
    
    Defects in second print (v2):
    [ ] ESC pocket creates weak spot where strut mount protrusions have no structural connection
    [ ] Corner pillars on battery holder are too thin. Print had layer separation but still too thin
    [x] Battery holder wall supports are too thin (no longer exist - use support everywhere)
    [x] Unbundle battery holder
    
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
        linear_extrude(convexity=3, height=section_mating-0.5)
            polygon(points=[
                    [-1,0],
                    [1,0],
                    [0,-arch_wall - section_mating_tolerance]
                    ]);
    }
}

module top_shell_pillar(z_trans, x_off, y_off, base_radius, y_scale, z_scale)
{
    ztrans2 = (z_trans < 0) ? z_trans : -z_trans;
    echo("z_trans", z_trans, "ztrans2", ztrans2);
    #translate([x_off, y_off, ztrans2])
        cylinder(r=6, h=abs(z_trans), $fn=6);
    intersection()
    {
        scale([1,y_scale,z_scale])
            sphere(r=base_radius, $fn=50);
        translate([x_off, y_off, 0])
            cylinder(r=6, h=abs(z_trans), $fn=6);
    }
}

module top_shell(flipped)
{
    // flipped true iff we are also rendering body and want to show it relative to "bottom" (actually top) of the body platform
    base_radius = 45;
    y_scale = 1.8;
    z_scale = 0.6;
    y_rot = flipped ? 180 : 0;
    z_trans = flipped ? -50 : 50;
    translate([0,0,z_trans])
    rotate([0,y_rot,0])
    union()
    {
      difference()
      {
        scale([1,y_scale,z_scale])
            sphere(r=base_radius, $fn=50);
        scale([1,y_scale,z_scale])
            sphere(r=base_radius - 1.8, $fn=50);
        translate([0,0,-base_radius*0.6])
            cube([4*base_radius, 4*base_radius, 2*base_radius*0.6], center=true);
      }
      top_shell_pillar(z_trans, -33, 22, base_radius, y_scale, z_scale);
      top_shell_pillar(z_trans, -33, -22, base_radius, y_scale, z_scale);
      top_shell_pillar(z_trans, 33, 22, base_radius, y_scale, z_scale);
      top_shell_pillar(z_trans, 33, -22, base_radius, y_scale, z_scale);
  }
}

module tower_pixhawk(flipped)
{
}

module tower_gps(flipped)
{
}

// Main entry point
// ================

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
    translate([0,render_span_test==0 ? 0 : -body_width/2,0])
    rotate([0,0,render_span_test==0 ? 0 : 45])
        new_body();
}

if (render_battery_holder)
{
    battery_holder(airframe_body_width());
}

if (render_shell)
{
    top_shell(render_body);
}

if (render_pixhawk)
{
    tower_pixhawk(render_body);
}

if (render_gps)
{
    tower_gps(render_body);
}

// May not be needed
//if (render_spacers)
//{
//}

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