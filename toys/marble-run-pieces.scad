// Marble run piece generator
// Works with:
// https://www.thingiverse.com/thing:4079409
// https://www.thingiverse.com/thing:3460633

// Slicer notes: Cura will need the "print thin walls"
// box checked to use generated supports.

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

// Inside or outside of whirlpool. Inside is a cutter so goes slightly above and below
module whirlpool_cross_section( base, inside_cutter )
{
    // Height from outside bottom to outside top
    height = 32;
    // Base = elevation of outside bottom
    top = inside_cutter ? base + height + 1 : base + height;
    bottom = inside_cutter ? base - 1 : base;
    radius = inside_cutter ? 50 : 52;
    bottom_radius = inside_cutter ? inside_radius : inside_radius + wall_thickness;
    // Cornering offset assumes travel from bottom to top
    corner_offset_sign = inside_cutter ? 1 : -1;
    // In FreeCAD we'd do this with Bezier curves...
    // Perform fillet on sharp edges
 //echo("Bottom",bottom,"br",bottom_radius,"top",top,"radius",radius);
    polygon(points=[
        [0,bottom],
        [bottom_radius,bottom],
        [bottom_radius,bottom+10 + wall_thickness * sin(45) * corner_offset_sign],
        [radius,bottom+20 + wall_thickness * sin(45) * corner_offset_sign],
        [radius,top],
        [0,top]
    ]);
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
    // Gutter length is distance from facing outside walls
    // Note that elevation is for the bottom of each end
    // at the point of entry/exit
    top_reduction = 3 * inside_radius + wall_thickness;
    start_elevation = start_adapter_height - top_reduction/*  - wall_thickness - inside_reduction_distance * wall_thickness*/;
    end_elevation = interface_length + wall_thickness;
    // Shallowness factor is the amount we remove from
    // a half-cylinder in units of inside_radius
    shallowness = 0.28;
    // Actual gutter length goes from far inside walls
    actual_gutter_length = gutter_length + 2 * wall_thickness + 4 * inside_radius;
    // Actual length extends into both adapters and
    // is the hypotenuse of the drop.
    // Start goes to the far wall of the cylinder
    drop_height = start_elevation - end_elevation;
    actual_length = sqrt(actual_gutter_length * actual_gutter_length + drop_height * drop_height); // + 4 * inside_radius + 2 * wall_thickness;
    // When we rotate downward, we need to shift by the 
    downward_slant = atan(drop_height / gutter_length);
    echo("Gutter:", gutter_length, "AGL:", actual_gutter_length, "Drop:", drop_height, "actual:", actual_length, "Slant:", downward_slant, "Start:", start_elevation, "tr:", top_reduction, "End:", end_elevation);
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
            translate([gutter_length, 0, 0]) basic_adapter( end_adapter_height, solid_mask = solid_mask );
            // Clip gutter by hull enclosing both start and end adapters
            intersection()
            {
                hull()
                {
                    basic_adapter( start_adapter_height );
                    translate([gutter_length, 0, 0])
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
                    linear_extrude(height=0.4)
                        polygon(points=[
                    [inside_radius+wall_thickness,0],
                    [inside_radius+wall_thickness, start_height],
                    [inside_radius + wall_thickness + gutter_length, end_height],
                    [inside_radius + wall_thickness + gutter_length, 0]
                        ]);
                    translate([0,0,-0.4])
                        linear_extrude(height=0.8)
                            polygon(points=[
                               [inside_radius + wall_thickness,0],
                               [inside_radius + wall_thickness, 2],
                               [inside_radius + wall_thickness + gutter_length, 2],
                               [inside_radius + wall_thickness + gutter_length, 0]
                            ]);
                }
            gutter_drop( adapter_height, adapter_height, gutter_length, solid_mask = true );
            translate([0,0,-0.4]) gutter_drop( adapter_height, adapter_height, gutter_length, solid_mask = true );
            translate([0.8,0,0]) gutter_drop( adapter_height, adapter_height, gutter_length, solid_mask = true );
            translate([-0.8,0,0]) gutter_drop( adapter_height, adapter_height, gutter_length, solid_mask = true );
        }
    }
}

module whirlpool_bowl(whirlpool_base)
{
    difference()
    {
        rotate_extrude(convexity=4)
            whirlpool_cross_section(whirlpool_base, false);
        rotate_extrude(convexity=4)
            whirlpool_cross_section(whirlpool_base, true);
        // Cutaway view for debugging purposes
        //#translate([0,-60,0]) cube([120,120,100]);
    }
}

module whirlpool_exit(whirlpool_base, mask=false)
{
    union()
    {
        translate([0,-(inside_radius + wall_thickness + 5),whirlpool_base+0.1])
        // Square top with bottom of bowl
        rotate([2,0,0])
        // Rotate into vertical drain position
        rotate([0,90,0])
        difference()
        {
        rotate_extrude(convexity=4, angle=88)
            translate([inside_radius + wall_thickness + 5,0,0])
                circle(r=(inside_radius + wall_thickness));
        rotate([0,0,-1])
            rotate_extrude(convexity=4, angle=92)
                translate([inside_radius + wall_thickness + 5,0,0])
                    circle(r=(inside_radius));
        }
        translate([0,-(inside_radius + wall_thickness+4),whirlpool_base-19.15]) rotate([92,0,0]) difference()
        {
            linear_extrude(height=46)
            circle(r=(inside_radius + wall_thickness));
            if (!mask)
            translate([0,0,-0.1]) linear_extrude(height=46.2)
            circle(r=inside_radius);
        }
    }
}

module whirlpool(base_elevation)
{
    union()
    {
        translate([0,64.5,0])
        difference()
        {
            intersection()
            {
                rotate([0,0,-53.8])
                gutter_drop(120, 120, 150);
                cylinder(r=(inside_radius+wall_thickness+40), h=140);
            }
            translate([-0.5*wall_thickness,-64.5 - wall_thickness,0]) hull() union() {
                whirlpool_bowl(base_elevation);
                translate([0,0,30]) whirlpool_bowl(base_elevation);
            }
        }
        whirlpool_bowl(base_elevation);
        difference()
        {
            union()
            {
                whirlpool_exit(base_elevation);
                difference()
                {
                    translate([0,-64.3,0]) basic_adapter(120);
                    whirlpool_exit(base_elevation, mask=true);
                }
            }
            translate([0,-64.3,0]) cylinder(r=inside_radius, h=100);
        }
        // Add support for exit
        translate([0,-49.5,0]) cube([0.4,35,8.5]);
    }
}

// Minimum is 11.06
//basic_adapter(10);
//basic_adapter(20);
whirlpool(42);
//basic_adapter(120);
//translate([40,0,0]) basic_adapter(20);
//cross_section(70);
//basic_drop( 60, 100 );
// Currently only works up until around 75, regardless
// of whether heights are symmetric or asymmetric
//gutter_drop( 75, 75, 100, solid_mask = false );
if (debug)
{
    cross_section(20);
    translate([0,28,0]) cross_section(11.75);
}