// Photo frame generator

/* [Size] */
picture_size = "wallet"; // [wallet:Wallet size 2.5x3.5 inches, wallet_windows:Windows wallet size 2.5x3.25 inches, contact:Contact sheet 1x1.5 inches, 4x6:4x6 inches]
margin = 12; // Total frame margin in mm
picture_overlap = 3; // How much of the picture's nominal dimensions are overlapped (obscured) by the frame, in mm?
tab_thickness = 1.5; // Thickness of tabs in mm
back_thickness = 1.0; // Thickness of back in mm
top_thickness = 1.5; // Thickness of top in mm
tab_extension = 0.5; // Distance tab extends past top
back_cutout = "round"; // [round:Circular opening, none:Solid back, sri:Sri yantra]

/* [Output] */
print_top = true;
print_back = true;

/* [Hidden] */

// Generate back opening
module back_opening(back_width, back_height)
{
    if (back_cutout == "round")
    {
        translate([back_width/2, back_height/2, -0.1])
            cylinder(r=back_width/3, h=2*back_thickness, $fn=50);
    }
}

// Back prints flat and has tabs
// Top prints flat and fits inside tabs
module frame_back(width,height)
{
    back_width = width + 2 * (margin + tab_thickness);
    back_height = height + 2 * (margin + tab_thickness);
    difference()
    {
        union()
        {
            cube([back_width, back_height, back_thickness]);
            // Tabs
            // Bottom
            translate([5,0,back_thickness])
                cube([back_width - 10, tab_thickness, top_thickness + tab_extension]);
            // Right side
            translate([back_width - tab_thickness, 5, back_thickness])
                cube([tab_thickness, back_height - 10, top_thickness + tab_extension]);
            // Left side
            translate([0, 5, back_thickness])
                cube([tab_thickness, back_height - 10, top_thickness + tab_extension]);
            // Top
            translate([5, back_height - tab_thickness, back_thickness])
                cube([back_width - 10, tab_thickness, top_thickness + tab_extension]);
        }
        // Top and side hole
        translate([back_width / 2, back_height - tab_thickness - 3, -0.1])
            cylinder(r=1.5, h=10, $fn=50);
        translate([back_width - tab_thickness - 3, back_height / 2, -0.1])
            cylinder(r=1.5, h=10, $fn=50);
        back_opening(back_width, back_height);
    }
}

module frame_top(width,height)
{
    top_width = width + 2 * margin;
    top_height = height + 2 * margin;
    difference()
    {
        cube([top_width, top_height, top_thickness]);
        translate([margin + picture_overlap, margin + picture_overlap, -0.1])
            cube([width - 2 * picture_overlap, height - 2 * picture_overlap, top_thickness * 2]);
        // Top and side hole
        translate([top_width / 2, top_height - 3, -0.1])
            cylinder(r=1.5, h=10, $fn=50);
        translate([top_width - 3, top_height / 2, -0.1])
            cylinder(r=1.5, h=10, $fn=50);
    }
    // Conch is 108x45 but scale it down a bit more
    vscale = margin / 60;
    translate([-1,6,top_thickness])
    scale([vscale, vscale, 1])
    rotate([0,0,-30])
    linear_extrude(height=1, convexity=6)
        import( file = "conch.dxf", layer = "conch2" );
    vscale_om = margin / 25;
    translate([0,(height + margin)/2 + 11,top_thickness])
        scale([vscale_om, vscale_om, 0.5])
            rotate([0,0,-90])
                import( file = "om.stl" );
    translate([(width + margin)/2,0,top_thickness])
        scale([vscale_om, vscale_om, 0.5])
            rotate([0,0,0])
                import( file = "om.stl" );
    vscale_lotus = margin / 20;
    translate([1,height + margin,top_thickness])
        scale([vscale_lotus, vscale_lotus, 1])
            rotate([0,0,0])
                import( file = "lotus.stl" );
    vscale_disc = margin / 60;
    translate([width + margin + 2, height + margin + 2, top_thickness])
        scale([vscale_disc, vscale_disc, 1])
            rotate([0,0,0])
                 import( file = "disc.stl" );
    /*
    // Lotus is 60x60
    vscale2 = margin / 60;
    translate([24,10,top_thickness])
        scale([vscale2, vscale2, 1])
            rotate([0,0,180])
                linear_extrude(height=1, convexity=10)
                    import( file="lotus.dxf", layer="lotus1" );
    */
    /*
    // Disc is 170x170 but for some reason the union makes it far bigger
    vscale3 = margin / 600;
    translate([24,0,top_thickness])
        scale([vscale3, vscale3, 1])
            rotate([0,0,0])
                linear_extrude(height=1, convexity=16)
                    import( file="disc.dxf", layer="disc1" );
    */
    vscale4 = margin / 60;
    translate([44,12,top_thickness])
        scale([vscale4, vscale4, 1])
            rotate([0,0,180])
                linear_extrude(height=1, convexity=6)
                    import( file="club.dxf", layer="club1" );
    /*
    vscale5 = margin / 2;
    translate([0,20,top_thickness])
        scale([vscale5, vscale5, 1])
            rotate([0,0,0])
                linear_extrude(height=1, convexity=12)
                    import( file="club.dxf", layer="om2" );
    */
}

module frame_set(width_in, height_in)
{
    w = width_in * 25.4;
    h = height_in * 25.4;
    
    if (print_back) frame_back(w, h);
    if (print_top) translate([-w - 3 * margin, 0, 0]) frame_top(w, h);
}

// Main selection
if (picture_size == "wallet")
{
    frame_set(2.5, 3.5);
}

if (picture_size == "wallet_windows")
{
    frame_set(2.5, 3.25);
}

if (picture_size == "contact")
{
    frame_set(1, 1.5);
}
