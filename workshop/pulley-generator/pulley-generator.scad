use <thread_profile.scad>
use <azimuthal_profile.scad>

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

module Pulley(pdiameter, rdiameter, shaft_diameter)
{
    difference()
    {
        cylinder(h=rdiameter + pulley_add_width_mm, r=pdiameter/2, $fn=120);
        //rotate([90,0,0]) linear_extrude( height=10, center = true, convexity = 10)
                //circle(d=rdiameter, $fn=120);
        // Torus cuts only about 1/3 into the pulley
        translate([0,0,(rdiameter + pulley_add_width_mm) /2]) rotate_extrude( convexity=10, $fn=120 ) 
                translate([-pdiameter * 1.04 /2,0]) 
                    circle(d=rdiameter, $fn=120);
        // Add 0.3mm tolerance in radius to hole
        translate([0,0,rdiameter * -0.1/2])
        cylinder(h=rdiameter + pulley_add_width_mm + 1, r=shaft_diameter/2 + 0.3, $fn=200);
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
    union()
    {
        cylinder(h=6, r=shaft_diameter/2 * 1.8, $fn=6);
        // 8mm of threaded shaft for the nut already added in parameters
        translate([0,0,5.9])
            cylinder(h=shaft_length+0.1, r=shaft_diameter/2, $fn=200);
    }
}

module Spacer(shaft_diameter, rdiameter)
{
    pulley_width = rdiameter + pulley_add_width_mm;
    spacer_height = pulley_width + 2 * pulley_plate_spacing_mm;
    difference()
    {
        cylinder(h=spacer_height, r=shaft_diameter/2, $fn=200);
        translate([0,0,-0.2]) cylinder(h=spacer_height+0.4, r=shaft_diameter/2 - spacer_wall_thickness_mm, $fn=200);
    }
}

// Make a solid nut - for now we'll do the threading in FreeCAD
module Nut(shaft_diameter)
{
    cylinder(h=8, r=shaft_diameter/2 * 1.9, $fn=6);
}

function ScaleUnits(n) = (units == "metric") ? n : n / 2.54;

// This should be the actual outer shaft diameter (outer diameter of spacer). Inner hole will have tolerance gap added but shaft will have tolerance gap subtracted
shaft_diameter_mm = ScaleUnits(pulley_diameter) * shaft_diameter_factor;
inner_shaft_diameter_mm = shaft_diameter_mm - 2 * spacer_wall_thickness_mm - 0.6;
echo("Outer shaft diameter (mm):", shaft_diameter_mm, "Inner (mm)", inner_shaft_diameter_mm);
if (show_pulley) Pulley( ScaleUnits(pulley_diameter), ScaleUnits(rope_diameter), shaft_diameter_mm);
if (show_spacers) translate([0,ScaleUnits(pulley_diameter),0])
    Spacer( shaft_diameter_mm, ScaleUnits(rope_diameter) );
if (show_shaft) translate([ScaleUnits(pulley_diameter),0,0]) Shaft(inner_shaft_diameter_mm, 8 + 2 * outer_plate_thickness_mm + (compound-1) * inner_plate_thickness_mm + compound * (ScaleUnits(rope_diameter) + pulley_add_width_mm + 2 * pulley_plate_spacing_mm) );
if (show_outer_frame) Plate( ScaleUnits(pulley_diameter), outer_plate_thickness_mm, inner_shaft_diameter_mm );
if (show_inner_frame) translate([-ScaleUnits(pulley_diameter)*2,ScaleUnits(pulley_diameter),0]) Plate( ScaleUnits(pulley_diameter), inner_plate_thickness_mm, inner_shaft_diameter_mm );
if (show_nut) translate([0,ScaleUnits(pulley_diameter*1.5),0]) Nut(shaft_diameter_mm - 4.0);
    