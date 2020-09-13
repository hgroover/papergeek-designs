// Marble run piece generator
// Works with:
// https://www.thingiverse.com/thing:4079409
// https://www.thingiverse.com/thing:3460633

// $fn = 120 produces nice curves but ridiculously large
// gcode and correspondingly long print times.
$fn = 60;
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
// Generate supports
generate_support = 1;
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
module basic_adapter( adapter_height, solid_mask = false )
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
      if (solid_mask)
          hull()
            rotate_extrude(convexity=10)
                cross_section( adapter_height );
      else
          // Note that the documentation for rotate_extrude()
          // does actually explain that there's an implicit
          // rotation from rotated around the Y axis to
          // rotated around the Z axis.
          rotate_extrude(convexity=10)
            cross_section( adapter_height );

}

// Gutter from top of start adapter to bottom of end adapter
module gutter_drop( start_adapter_height, end_adapter_height, gutter_length, solid_mask = false )
{
    // Start elevation for gutter needs to allow space for entire cylinder
    // Note that elevation is for the bottom of each end
    // at the point of entry/exit
    top_reduction = 3 * inside_radius + wall_thickness;
    start_elevation = start_adapter_height - top_reduction/*  - wall_thickness - inside_reduction_distance * wall_thickness*/;
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
    // Hollow out end adapter from gutter intrusion,
    // and cut holes in walls
    difference()
    {
        // Create start and end adapters
        union()
        {
            // Start adapter
            basic_adapter( start_adapter_height, solid_mask = solid_mask );
            // End adapter
            translate([2 * (inside_radius + wall_thickness) + gutter_length, 0, 0]) basic_adapter( end_adapter_height, solid_mask = solid_mask );
            // Clip gutter by hull enclosing both start and end adapters
            intersection()
            {
                hull()
                {
                    basic_adapter( start_adapter_height );
                    translate([2 * (inside_radius + wall_thickness) + gutter_length, 0, 0])
                        basic_adapter( end_adapter_height );
                }

                // Basic hollow cylinder for the gutter,
                // first rotated into downward slant,
                // then translated to butt against rear wall
                // of start adapter
                translate([-1*(inside_radius + wall_thickness),0,start_adapter_height-3 * wall_thickness - interface_length]) rotate([0,90+downward_slant,0]) difference()
                {
                    cylinder(h=actual_length, r=inside_radius + wall_thickness);
                    if (!solid_mask) translate([0,0,-1]) cylinder(h=actual_length+2, r=inside_radius);
                    // Cut away top half
                    if (!solid_mask) translate([inside_radius * -3 + inside_radius * shallowness, inside_radius * -1.5, -1])
                      cube([inside_radius * 3, inside_radius * 3, actual_length + 2]);
                }
            }
        }
        // Cut out inside of end adapter (which has a gutter intrusion)
        if (!solid_mask) translate([2 * (inside_radius + wall_thickness) + gutter_length, 0, 0])
          cylinder(h=end_adapter_height/2, r=inside_radius);
        // Cut holes in walls, clipped by inside half
        // of each adapter
        if (!solid_mask) intersection()
        {
            translate([-1*(inside_radius + wall_thickness),
                    0,
                    start_adapter_height - 3 * wall_thickness - interface_length])
                rotate([0,90+downward_slant,0])
                    cylinder(h=actual_length, r=inside_radius);
            translate([0,-1.5*inside_radius,0]) cube([gutter_length + 2 * (inside_radius + wall_thickness),3*inside_radius,start_adapter_height + end_adapter_height]);
        }
    }
}

// Basic drop from two adapters of specified height
module basic_drop( adapter_height, gutter_length )
{
    gutter_drop( adapter_height, adapter_height, gutter_length );
    if (generate_support > 0)
    {
        start_height = adapter_height - 1.8 * inside_radius;
        end_height = interface_length + inside_radius;
        difference()
        {
            rotate([90,0,0]) 
                union()
                {
                    linear_extrude(height=0.5)
                        polygon(points=[
                    [inside_radius+wall_thickness,0],
                    [inside_radius+wall_thickness, start_height],
                    [inside_radius + wall_thickness + gutter_length, end_height],
                    [inside_radius + wall_thickness + gutter_length, 0]
                        ]);
                    translate([0,0,-0.4])
                        linear_extrude(height=1.8)
                            polygon(points=[
                               [inside_radius + wall_thickness,0],
                               [inside_radius + wall_thickness, 4],
                               [inside_radius + wall_thickness + gutter_length, 4],
                               [inside_radius + wall_thickness + gutter_length, 0]
                            ]);
                }
            gutter_drop( adapter_height, adapter_height, gutter_length, solid_mask = true );
            //translate([0,0,-0.2]) gutter_drop( adapter_height, adapter_height, gutter_length, solid_mask = true );
            translate([0.5,0,0]) gutter_drop( adapter_height, adapter_height, gutter_length, solid_mask = true );
            translate([-0.5,0,0]) gutter_drop( adapter_height, adapter_height, gutter_length, solid_mask = true );
        }
    }
}

// Minimum is 11.06
//basic_adapter(10);
//basic_adapter(60);
//basic_adapter(120);
//translate([40,0,0]) basic_adapter(20);
//cross_section(70);
basic_drop( 60, 100 );
// Currently only works up until around 75, regardless
// of whether heights are symmetric or asymmetric
//gutter_drop( 75, 75, 100, solid_mask = false );
if (debug)
{
    cross_section(20);
    translate([0,28,0]) cross_section(11.75);
}