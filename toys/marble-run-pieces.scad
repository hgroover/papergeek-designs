// Marble run piece generator
// Works with:
// https://www.thingiverse.com/thing:4079409
// https://www.thingiverse.com/thing:3460633

$fn = 120;
// Length of the interface that fits inside another piece
interface_length = 6;
// Radius of the receptacle part
inside_radius = 12;
// Wall thickness
wall_thickness = 2.3;
// Distance between shoulder and top of inward reduction
// in units of wall thickness
inside_reduction_distance = 1.2;
// Radial tolerance means how much we subtract from 
// inside radius to fit inside another piece
radial_tolerance = 0.35;
// Inside radius to fit snugly over 3/4" 250lb. PVC
pvc_receptacle_inside_radius = 13.7;
// Show profiles
debug = 0;

// Cross-section polygon for adapter of specified height
// Although a polygon is implicitly in the X,Y plane,
// rotate_extrude() implicitly uses the polygon from the
// X,Z plane.
module cross_section( adapter_height )
{
    polygon(points=[
        [inside_radius,0],
        [inside_radius, adapter_height - inside_reduction_distance * wall_thickness - wall_thickness], // 45 degrees
        [inside_radius - wall_thickness, adapter_height - inside_reduction_distance * wall_thickness],
        [inside_radius - wall_thickness,adapter_height + interface_length],
        [inside_radius - radial_tolerance,adapter_height + interface_length],
        [inside_radius - radial_tolerance,adapter_height],
        [inside_radius + wall_thickness,adapter_height],
        [inside_radius + wall_thickness,0]]);
}

// Adapter height is from base to top of shoulder;
// i.e. when inserted into the next piece above,
// how much height does it add?
module basic_adapter( adapter_height )
{
    // Minimum height of the base-to-shoulder is
    // interface length + wall thickness (for inside slant)
    // + wall thickness * inside_reduction_distance (for outer shoulder)
    min_height = interface_length + wall_thickness + inside_reduction_distance * wall_thickness;
  if (adapter_height < min_height)
  {
      echo( "Invalid height", adapter_height, "- minimum", min_height );
  }
  else
  // Note that the documentation for rotate_extrude()
  // does actually explain that there's an implicit
  // rotation from rotated around the Y axis to
  // rotated around the Z axis.
  rotate_extrude(convexity=10)
    cross_section( adapter_height );

}

// Gutter from top of start adapter to bottom of end adapter
module gutter_drop( start_adapter_height, end_adapter_height, gutter_length )
{
    // Start elevation for gutter needs to allow space for entire cylinder
    // Note that elevation is for the bottom of each end
    // at the point of entry/exit
    start_elevation = start_adapter_height - (2 *inside_radius + wall_thickness)/*  - wall_thickness - inside_reduction_distance * wall_thickness*/;
    end_elevation = interface_length + wall_thickness;
    // Shallowness factor is the amount we remove from
    // a half-cylinder in units of inside_radius
    shallowness = 0.28;
    // Actual length extends into both adapters and
    // is measured by the hypotenuse of the drop.
    // Start goes to the far wall of the cylinder
    drop_height = start_elevation - end_elevation;
    actual_length = sqrt(gutter_length * gutter_length + drop_height * drop_height) + 3 * (inside_radius + wall_thickness);
    // When we rotate downward, we need to shift by the 
    echo("Gutter:", gutter_length, "Drop:", drop_height, "actual:", actual_length, "Slant:", downward_slant);
    downward_slant = asin(drop_height / gutter_length);
    translate([-(inside_radius + wall_thickness),0,start_elevation]) rotate([90,0,0]) rotate([0,90,0])
    intersection()
    {
      translate([0,20,0]) rotate([downward_slant,0,0]) difference()
      {
        cylinder(h=actual_length, r=inside_radius+wall_thickness);
        translate([0,0,-1]) cylinder(h=actual_length+2, r=inside_radius);
        translate([-inside_radius * 1.5,-inside_radius*shallowness,-1]) cube([inside_radius*3,inside_radius*3,actual_length+2]);
      }
      translate([ 
        0,
        0,
        1 * (inside_radius + wall_thickness)
        ]) rotate([-90,0,0]) rotate([0,0,-90]) hull()
      {
          basic_adapter( start_adapter_height );
          translate([2 * (inside_radius + wall_thickness) + gutter_length, 0, 0]) basic_adapter( end_adapter_height );
      }
   }
}

// Basic drop from two adapters of specified height
module basic_drop( adapter_height, gutter_length )
{
    union()
    {
        // Start adapter
        basic_adapter( adapter_height );
        // End adapter
        translate([2 * (inside_radius + wall_thickness) + gutter_length, 0, 0]) basic_adapter( adapter_height );
        gutter_drop( adapter_height, adapter_height, gutter_length );
    }
}

// Minimum is 11.06
//basic_adapter(10);
//basic_adapter(60);
basic_adapter(120);
//translate([40,0,0]) basic_adapter(20);
//cross_section(70);
//basic_drop( 70, 100 );
if (debug)
{
    cross_section(20);
    translate([0,28,0]) cross_section(11.75);
}