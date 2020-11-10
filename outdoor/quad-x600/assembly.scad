// M3x30mm screws hold struts together. Radius is for a slide-through hole. Length is the actual length of enclosed shaft, which must be at least 5mm less than the actual screw (so there is room for the nut)
screw_radius = 1.8;
screw_block_radius = 3;
screw_length = 21;
screw_mask_length = screw_length + 0.2;
// Z offset for screw holes. Should merge screw block with structure without cutting into structure with screw shaft hole
screw_z = 6; 

// Leg height is measured from top of motor mount
leg_height = 90;
leg_radius = 10;
leg_wall = 2;

// Outside screw mount with specified Y offset
module screw_mount(is_mask, y_offset)
{
    L = (is_mask ? screw_mask_length : screw_length);
    R = (is_mask ? screw_radius : screw_block_radius);
    rotate([0,0,-45]) 
        rotate([-180,0,0]) 
            translate([-L/2,y_offset,screw_z])
                        rotate([0,90,0])
                            cylinder(r=R, h=L, $fn=50);
}

// Strut leg at specified Y offset, or connecting hole mask
module strut_leg(is_mask, y_offset)
{
    rotate([0,0,-45])
        rotate([-180,0,0])
            translate([0,200,0])
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
                    #translate([0,leg_radius * 1.5,leg_height-10])
                        rotate([90,0,0])
                            cylinder(r=3, h=3*leg_radius);
                }
}

module end_unit()
{
    rotate([180,0,0])
    rotate([0,0,45])
    difference()
    {
        union()
        {
            import("oc-end-motormount.stl");
            difference()
            {
                union()
                {
                    import("oc-end.stl");
                    screw_mount(false, 244);
                }
                import("oc-end-hollow-cutter.stl");
                screw_mount(true,244);
            }
        }
        import("oc-end-opening-cutter.stl");
    }
}

module strut_unit()
{
    rotate([180,0,0])
        rotate([0,0,45])
    difference()
    {
        union()
        {
            union()
            {
                difference()
                {
                    union()
                    {
                        import("oc-strut.stl");
                        screw_mount(false,100);
                        strut_leg(false,200);
                    }
                    import("oc-strut-hollow-cutter.stl");
                    screw_mount(true,100);
                    strut_leg(true,200);
                }
                import("oc-strut-endmate.stl");
            }
            intersection()
            {
              screw_mount(false,244);
              import("oc-strut-endmate-mask.stl");
            }
        }
        screw_mount(true,244);
    }
}

module body_unit()
{
    rotate([180,0,0])
        rotate([0,0,45])
            union()
            {
    import("oc-body-base.stl");
                difference()
                {
                    union()
                    {
                        import("oc-body-mating-bl.stl");
                        intersection()
                        {
                            screw_mount(false,100);
                            scale([0.95,0.95,0.95])
                                hull()
                                    import("oc-body-mating-bl.stl");
                        }
                    }
                    screw_mount(true,100);
                }
    import("oc-body-mating-br.stl");
    import("oc-body-mating-fl.stl");
    import("oc-body-mating-fr.stl");
            }
}

end_unit();
//strut_unit();
//body_unit();
