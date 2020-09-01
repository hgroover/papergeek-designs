// Required libraries need to be installed in library directory:
// https://github.com/MisterHW/IoP-satellite/blob/master/OpenSCAD%20bottle%20threads/thread_profile.scad
// (entire directory) https://github.com/openscad/scad-utils
// (entire directory) https://github.com/openscad/list-comprehension-demos
use <thread_profile.scad>

/* [General] */

// US (fractional inches) or Metric (mm)
units = "metric"; // [us, metric]

/* [Type] */
compound = 1;

/* [Size] */

// Diameter of rope. Default is for 1/8" paracord
rope_diameter = 5;

// Pulley diameter
pulley_diameter = 36;

// Shaft diameter as a fraction of pulley diameter
shaft_diameter_factor = 0.45;

// Outer plates need to be slightly thicker
outer_plate_thickness_mm = 6;

// Inner plates also bear some load
inner_plate_thickness_mm = 4;

/* [Fine-tuning] */

// Additional pulley width in mm above rope diameter
pulley_add_width_mm = 1;

// Additional pulley clearance from plates on each side in mm
pulley_plate_spacing_mm = 0.2;

// Spacer wall thickness in mm
spacer_wall_thickness_mm = 3;

/* [Build plate output] */
show_pulley = true;
show_outer_frame = true;
show_inner_frame = true;
show_spacers = true;
show_shaft = true;
show_nut = true;
// Produce non-functional pieces just big enough to check fit
debug_size = false;

module Pulley(pdiameter, rdiameter, shaft_diameter)
{
    pulley_radius = debug_size ? shaft_diameter/2 + 4 : pdiameter / 2;
    echo("Generating pulley r", pulley_radius, "pdiameter", pdiameter, "shaft_diameter", shaft_diameter, "debug", debug_size);
    difference()
    {
        cylinder(h=rdiameter + pulley_add_width_mm, r=pulley_radius, $fn=120);
        //rotate([90,0,0]) linear_extrude( height=10, center = true, convexity = 10)
                //circle(d=rdiameter, $fn=120);
        // Torus cuts only about 1/3 into the pulley
        translate([0,0,(rdiameter + pulley_add_width_mm) /2]) rotate_extrude( convexity=10, $fn=120 ) 
                translate([-pdiameter * 1.04 /2,0]) 
                    circle(d=rdiameter, $fn=120);
        // Add 0.5mm tolerance in radius to hole
        translate([0,0,rdiameter * -0.1/2])
        cylinder(h=rdiameter + pulley_add_width_mm + 1, r=shaft_diameter/2 + 0.5, $fn=200);
    }
}

module Plate(pdiameter, thickness, shaft_hole_diameter)
{
    // shaft_hole_diameter does not have tolerance gap added
    inner_shaft_diameter = shaft_hole_diameter + 0.6;
    translate([0,-pdiameter*1.6,0])
    difference()
    {
        hull()
        {
            translate([-pdiameter*0.8,0,0]) cylinder(h=thickness, r=pdiameter/2, $fn=120);
            cylinder(h=thickness, r=pdiameter*1.4/2, $fn=120);
            translate([pdiameter*0.8,0,0]) cylinder(h=thickness, r=pdiameter/2, $fn=120);
        }
        translate([0,0,thickness*-0.1]) cylinder(h=thickness*1.2, r=inner_shaft_diameter/2, $fn=200);
        translate([-pdiameter*0.9,0,thickness*-0.1]) cylinder(h=thickness*1.2, r=inner_shaft_diameter/2, $fn=200);
        translate([pdiameter*0.9,0,thickness*-0.1]) cylinder(h=thickness*1.2, r=inner_shaft_diameter/2, $fn=200);
    }
}

module Shaft(shaft_diameter, shaft_length)
{
    // shaft_length is just the portion of the shaft between the outside of the outer plates
    threaded_diameter = shaft_diameter - 2.7;
    threaded_length = 12.5; // Shaft length must penetrate at least 5mm of outer plate
    union()
    {
        cylinder(h=6, r=shaft_diameter/2 * 1.8, $fn=6);
        // 8mm of threaded shaft for the nut already added in parameters, and dip 4mm into the plate to start threading
        translate([0,0,5.9])
            cylinder(h=shaft_length+0.1-4, r=shaft_diameter/2, $fn=200);
        translate([0,0,6+shaft_length-4.1])
            cylinder(h=threaded_length, r=threaded_diameter/2, $fn=200);
        translate([0,0,6 + shaft_length - 4 + 0.4])
            straight_thread(
            section_profile = my_thread_profile(),   
            r = threaded_diameter/2,
            pitch = 2, 
            turns = 5, 
            fn=200);
    }
}

module Spacer(outer_shaft_diameter, rdiameter, inner_shaft_diameter)
{
    pulley_width = rdiameter + pulley_add_width_mm;
    spacer_height = pulley_width + 2 * pulley_plate_spacing_mm;
    difference()
    {
        cylinder(h=spacer_height, r=outer_shaft_diameter/2, $fn=200);
        translate([0,0,-0.2]) cylinder(h=spacer_height+0.4, r=inner_shaft_diameter/2 + 0.3, $fn=200);
    }
}

module Nut(shaft_diameter)
{
    // Make the cutter diameter 0.6mm bigger than the threaded part of the shaft
    threaded_diameter = shaft_diameter - 2.7 + 0.6;
    difference()
    {
        cylinder(h=8, r=shaft_diameter/2 * 1.9, $fn=6);
        union()
        {
            translate([0,0,-4])
              cylinder(h=20, r=threaded_diameter / 2, $fn=200);
            translate([0,0,-4])
                straight_thread(
                    section_profile = my_thread_profile2(),   
                    r = threaded_diameter/2,
                    pitch = 2, 
                    turns = 8, 
                    fn=200);
        }
    }
}

function ScaleUnits(n) = (units == "metric") ? n : n / 2.54;

// This seems to be a set of points for a side profile
function demo_thread_profile() = [
    [0,0], // always 0,0 - origin?
    [1.5,1],
    [1.5,1],
    [0,3],
    [-1,3],
    [-1,0]    
];

// Total vertical size MUST be less than pitch, otherwise we'll have overlap which will cause CGAL to throw a hissy fit
function my_thread_profile() = [
    [0,0], // always 0,0 - origin?
    [1.35,0.9],
    [0,1.8],
    [-0.2,1.8],
    [-0.2,0]
];

// Expanded profile for cutting inside
function my_thread_profile2() = [
    [0,0], // always 0,0 - origin?
    [1.4,0.9],
    [0,1.8],
    [-0.2,1.8],
    [-0.2,0]
];

// This should be the actual outer shaft diameter (outer diameter of spacer). Inner hole will have tolerance gap added but shaft will have tolerance gap subtracted
shaft_diameter_mm = ScaleUnits(pulley_diameter) * shaft_diameter_factor;
inner_shaft_diameter_mm = shaft_diameter_mm - 2 * spacer_wall_thickness_mm - 0.6;
echo("Outer shaft diameter (mm):", shaft_diameter_mm, "Inner (mm)", inner_shaft_diameter_mm);
if (show_pulley) Pulley( ScaleUnits(pulley_diameter), ScaleUnits(rope_diameter), shaft_diameter_mm);
if (show_spacers) translate([0,ScaleUnits(pulley_diameter),0])
    Spacer( shaft_diameter_mm, ScaleUnits(rope_diameter), inner_shaft_diameter_mm );
if (show_shaft) translate([ScaleUnits(pulley_diameter),0,0]) Shaft(inner_shaft_diameter_mm, 2 * outer_plate_thickness_mm + (compound-1) * inner_plate_thickness_mm + compound * (ScaleUnits(rope_diameter) + pulley_add_width_mm + 2 * pulley_plate_spacing_mm) );
if (show_outer_frame) Plate( ScaleUnits(pulley_diameter), outer_plate_thickness_mm, inner_shaft_diameter_mm );
if (show_inner_frame) translate([-ScaleUnits(pulley_diameter)*2,ScaleUnits(pulley_diameter),0]) Plate( ScaleUnits(pulley_diameter), inner_plate_thickness_mm, inner_shaft_diameter_mm );
if (show_nut) translate([0,ScaleUnits(pulley_diameter*1.5),0]) Nut(inner_shaft_diameter_mm);
    