union()
{
    difference()
    {
        union()
        {
            import("top-slab.stl");
            import("mountain-fountain7-mountain2_003.stl");
            import("mountain-fountain7-cave.stl");
            import("lower-tube.stl");
            // Print support for top slab overhang
            // 0.8 is the minimum
            translate([-30,40,50]) cube([0.8,20,140]);
        }
        import("mountain-fountain9-lower-tube-cutter_003.stl");
        import("mountain-fountain9-tube-cutter-chamber.stl");
        // Cord cutter
        translate([50,85,-2]) rotate([-48,0,0]) cylinder(90, r=6, $fn=30);
    }
    //translate([0,0,-5]) import("shankara-murudeshwar.stl", convexity=5);
}
