/*[General]*/
new_fountain = 1; // [0:old fountain, 1:new fountain, 2:tubing container, 3:tubing end seal]
// 1 to view pillars separately (with potential gaps)
pillar_view = 0;
// Add a hemisphere cap over fountainhead to avoid water spurting up and hopefully keep it in the basin
fountainhead_cap = true;
// Include Shankarji (to reference size of alcove)
include_shiv_murti = false;
// Add internal support pillars
internal_support_pillars = false;
// Add additional internal removable span supports
internal_span_supports = true;
// Generate supports for cave roof
cave_roof_supports = true;

/*[Hidden]*/
// Global predefined boulder sets: radius, xscale, yscale, zscale, xoff, yoff, zoff
bset = [
[ // 0
                [6,    10, 8, 9,  2, 1.8, 1],
                [8,    9, 10, 11,  -1, -2, -3],
                [11,    13, 12, 11, 2.1, -1, 2]
],
[ // 1
                [10,    12, 14, 9,  2, 1.5, -1],
                [12,    9, 11, 15,  -2, -2.2, 1],
                [8,     13, 12, 11, 1.4, -2, -1]
],
[ // 2
                [7,    10, 7, 8,  2, 1.1, 1],
                [9,    9, 11, 6,  2, -1.8, 2],
                [11,   8, 10, 9, -1.8, 2, -1]
],
// 3: Back of roof transition slab
[
    [8,    8, 8, 8,     -50, 25, -11],
    [8,    8, 8, 8,     50, 25, -11],
    [10,    10, 10, 10,     -52, 8, 12],
    [10,    10, 10, 10,     51, 6, 12],
    [10,    100, 10, 10,    0, 20, 12],
],
// 4: Roof slab
[
    [10,    12, 8, 12,      -14, 39, -6],
    [10,    12, 8, 12,      14, 39, -6],
    [10,    10, 10, 10,     -45, 35, -6],
    [10,    10, 10, 10,     46, 34, -7],
    [10,    10, 10, 10,     -61, 20, -4],
    [10,    10, 10, 10,     -60, -2, 3],
    [10,    10, 10, 10,     62, -1, 4],
    [10,    10, 10, 10,     61, 22, -3],
    [10,    10, 10, 10,     -62, -31, 6],
    [10,    10, 10, 10,     60, -32, 5]
],
// 5: Roof slab left side
[
    [13,    13, 12, 14,     -61, -30, 0],
    [14,    13, 15, 11,     -60, 5, -3]
],
// 6: Roof slab right side
[
    [13,    13, 12, 14,     60, -30, 0],
    [15,    12, 16, 11,     61, 6, -3]
],
// 7
];

// Cord and drain hole cutters
module cord_holes()
{
        z = -4;
        ch = 90;
        cr = 6;
        for (x = [50,-15]) 
            translate([x,85,z])
                rotate([-48,0,0])
                    cylinder(ch, r=cr, $fn=30);
        for (y = [45,-45])
        {
            translate([-85,y,z])
                rotate([-48,0,90])
                    cylinder(ch, r=cr, $fn=30);
            translate([85,y,z])
                rotate([-48,0,-90])
                    cylinder(ch, r=cr, $fn=30);
        }
        for (x = [45,-45])
            translate([x,-85,z])
                rotate([-48,0,180])
                    cylinder(ch, r=cr, $fn=30);
        //translate([50,85,-2]) rotate([-48,0,0]) cylinder(90, r=6, $fn=30);
        //translate([-50,85,-2]) rotate([-48,0,0]) cylinder(90, r=6, $fn=30);
        //translate([-85,45,-2]) rotate([-48,0,90]) cylinder(90, r=6, $fn=30);
        //translate([-85,-45,-2]) rotate([-48,0,90]) cylinder(90, r=6, $fn=30);
        //translate([85,-45,-2]) rotate([-48,0,-90]) cylinder(90, r=6, $fn=30);
        //translate([85,45,-2]) rotate([-48,0,-90]) cylinder(90, r=6, $fn=30);
        //translate([45,-85,-2]) rotate([-48,0,180]) cylinder(90, r=6, $fn=30);
        //translate([-45,-85,-2]) rotate([-48,0,180]) cylinder(90, r=6, $fn=30);
}

// Original conglomeration of Blender-designed parts
module old_fountain_shape()
{
  union()
  {
    difference()
    {
        union()
        {
            import("top-slab.stl");
            import("mountain-fountain7-mountain2_003.stl");
            import("mountain-fountain7-cave.stl");
            //import("lower-tube.stl");
            //  Slightly thicker
            import("mountain-fountain9-lower-tube.stl");
            // Print support for top slab overhang
            // 0.8 is the minimum
            translate([-30,40,50]) cube([0.8,20,140]);
        }
        import("mountain-fountain9-lower-tube-cutter_003.stl");
        import("mountain-fountain9-tube-cutter-chamber.stl");
        // Make additional drainage
        translate([1,41,158]) rotate([-19,0,0]) scale([2.5,0.8,1]) cylinder(40, r=4, $fn=50);
        // Cord cutter and drain holes
        cord_holes();
    }
    //translate([0,0,-5]) import("shankara-murudeshwar.stl", convexity=5);
  }
}

// Build an irregular boulder from sets of terms for
// spheres with radius, x, y and z scale and x, y, z offset
module boulder(termlist)
{
    hull()
    {
        for (asph = termlist)
        {
            // Must be 7 terms: radius, x, y z scale, x y z displacement
            radius = asph[0];
            sx = asph[1];
            sy = asph[2];
            sz = asph[3];
            dx = asph[4];
            dy = asph[5];
            dz = asph[6];
            translate([dx,dy,dz])
                resize([sx,sy,sz])
                    sphere(r=radius, $fn=50);
        }
    }
}

// Back cave structure. Note that hull() will not
// give us a structure with an indentation, so we
// need to join pairs of pillars with hull
phbase = 135;
pil = [
    // Terms are radius, height, x offset, y offset, z offset
    // Pillars go counter-clockwise from right to left
    [   7,  phbase,     59,     12,     -4  ],
    [   8,  phbase,     60,     32,     -2  ],
    [   8,  phbase,     59,     50,     0   ],
    [   10, phbase,     57,     60,     -1   ],
    [   10, phbase,     51,     66,     0   ],
    [   11, phbase,     42,     70,     -1   ],
    [   11, phbase,     29,     72,     0   ],
    [   11, phbase,     8,      73,     0   ],
    [   11, phbase,     -8,     73,     0   ],
    [   11, phbase,     -29,    72,     0   ],
    [   11, phbase,     -42,    70,     -1   ],
    [   10, phbase,     -51,    66,     0   ],
    [   10, phbase,     -57,    60,     -1   ],
    [   8,  phbase,     -60,    50,     0   ],
    [   8,  phbase,     -60,    32,     -2  ],
    [   7,  phbase,     -59,    12,     -4  ]
];

module cave_back()
{
    echo(len(pil), "sets in pil");
    z_base = 50;
    // Add z offset back into height to make tops even
    if (pillar_view)
    {
        for (n=[0:len(pil)-1])
            translate([pil[n][2], pil[n][3], z_base + pil[n][4]])
                cylinder(r=pil[n][0], h=pil[n][1] - pil[n][4]);
    }
    else
    {
        for (n=[0:len(pil)-2])
            hull()
            {
                translate([pil[n][2], pil[n][3], z_base + pil[n][4]])
                    cylinder(r=pil[n][0], h=pil[n][1] - pil[n][4]);
                translate([pil[n+1][2], pil[n+1][3], z_base + pil[n+1][4]])
                    cylinder(r=pil[n+1][0], h=pil[n+1][1] - pil[n+1][4]);
            }
    }
}

// Generate internal span supports under bottom (touching build plate)
module generate_internal_span_supports()
{
    /***
    translate([0,-36,0])
        cube([0.4, 100, 48]);
    translate([20,-36,0])
        cube([0.4, 100, 48]);
    translate([-20,-36,0])
        cube([0.4, 100, 48]);
    translate([40,-20,0])
        cube([0.4, 80, 48]);
    translate([-40,-20,0])
        cube([0.4, 80, 48]);
    ***/
    // Use zigzag pattern
    w=0.8;
    linear_extrude(height=48)
        polygon(points=[
        [-40,60],
        [-40,-20],
        [-20,-36],
        [-20,60],
        [0,60],
        [0,-36],
        [20,-36],
        [20,60],
        [40,60],
        [40,-20],
        [40+w,-20],
        [40+w,60+w],
        [20-w,60+w],
        [20-w,-36+w],
        [0+w,-36+w],
        [0+w,60+w],
        [-20-w,60+w],
        [-20-w,-36+3*w], // sharp bend inside
        [-40+w,-20+w],
        [-40+w,60]
        ]);
}

// Generate branching supports for cave roof
module generate_cave_roof_supports()
{
  // Bridge supports connect to both cave sides
  translate([0,7,83.6])
    rotate([90,0,0])
        linear_extrude(height=0.4)
            polygon(convexity=5, points=[
                [-52,60],
                [-52,106],
                [0,106],
                [52,106],
                [52,60],
                [0,102]
                ]);
  translate([0,14,83.6])
    rotate([90,0,0])
        linear_extrude(height=0.4)
            polygon(convexity=5, points=[
                [-52,58],
                [-52,104],
                [0,104],
                [52,104],
                [52,58],
                [0,100]
                ]);
  translate([0,24,83.6])
    rotate([90,0,0])
        linear_extrude(height=0.4)
            polygon(convexity=5, points=[
                [-52,56],
                [-52,103],
                [0,102],
                [52,102],
                [52,56],
                [0,98]
                ]);
  // Last two also connect to downspout
  translate([0,32,83.6])
    rotate([90,0,0])
        linear_extrude(height=0.4)
            polygon(convexity=5, points=[
                [-52,49],
                [-52,100.5],
                [-8.5,99.9],
                [-6,96.7],
                [0,95.3],
                [6,96.7],
                [8.5,99.8],
                [52,99.8],
                [52,49],
                [0,94]
                ]);
  translate([0,38.5,83.6])
    rotate([90,0,0])
        linear_extrude(height=0.4)
            polygon(convexity=5, points=[
                [-52,48],
                [-52,99.1],
                [-8.5,98.8],
                [-6, 96.5],
                [0,94],
                [6,96.5],
                [8.5,98.7],
                [52,98.7],
                [52,48],
                [0,93]
                ]);
}

// New fountain built up from scratch
module new_fountain_shape()
{
    difference()
    {
        union()
        {
    difference()
    {
        union()
        {
            import("mountain-fountain7-mountain2_003.stl");
            cave_back();
            // Just add some real stone or glass pebbles...
            //translate([-78,42,33]) boulder(bset[1]);
            //translate([-79,28,30]) boulder(bset[0]);
            //translate([-81,6,30]) boulder(bset[2]);
            // vertical to horizontal transition slab
            translate([0,40,170]) boulder(bset[3]);
            // tilted horizontal slab
            translate([0,40,188]) boulder(bset[4]);
            // Left side of top slab
            translate([0,40,188]) boulder(bset[5]);
            // right side of top slab
            translate([0,40,188]) boulder(bset[6]);
            // Top reservoir
            translate([0,46,198])
                resize([120,80,30])
                    sphere(r=10, $fn=80);
            // Rear interface between top reservoir and back
            translate([0,72,180])
                cylinder(r=12,h=18);
            // Dripper
            translate([0,36,188])
                sphere(r=10, $fn=60);
        }
        // Tubing hole
        translate([0,72,-1])
            cylinder(r=8, h=230);
        // Hollow top reservoir
        translate([0,46,202])
            resize([116,76,28])
                sphere(r=10, $fn=80);
        // Channel through dripper
        translate([0,29,170])
            rotate([-33,0,0])
                cylinder(r=3, h=40);
        // Reduce volume
        translate([0,0,-4])
            scale([0.94, 0.94, 0.99])
                hull() import("mountain-fountain7-mountain2_003.stl");
        // Reduce material volume and add LED lighting
        // inserts accessible from bottom
        for (pilidx = [4,5,6,9,10,11])
            translate([pil[pilidx][2], pil[pilidx][3], 42])
                // We have no need to subtract from height because z base is already reduced by 8mm
                cylinder(r=pil[pilidx][0] - 2, h=pil[pilidx][1]);
        hull()
        {
        for (pilidx = [0,1,2])
            translate([pil[pilidx][2], pil[pilidx][3], 42])
                // We have no need to subtract from height because z base is already reduced by 8mm
                cylinder(r=pil[pilidx][0] - 2, h=pil[pilidx][1]);
        }
        hull()
        {
        for (pilidx = [13,14,15])
            translate([pil[pilidx][2], pil[pilidx][3], 42])
                // We have no need to subtract from height because z base is already reduced by 8mm
                cylinder(r=pil[pilidx][0] - 2, h=pil[pilidx][1]);
        }
        // Reduce volume in 
        // vertical to horizontal transition slab
        translate([0,42,170]) 
            scale([0.85, 0.85, 0.85])
                boulder(bset[3]);

    } // inner difference
            // Make foot thicker so there is a continuous starting layer
            foot_thickness = 14;
            foot_height = 6;
            linear_extrude(height=foot_height)
                polygon(points=[
                    [90,90],
                    [-90,90],
                    [-90,-90],
                    [90,-90],
                    [90-foot_thickness,90-foot_thickness],
                    [-90+foot_thickness,90-foot_thickness],
                    [-90+foot_thickness,-90+foot_thickness],
                    [90-foot_thickness,-90+foot_thickness]
                    ], paths=[
                    [0,1,2,3],
                    [4,5,6,7]
                ]);
        } // outer union
        cord_holes();
    } // Outer difference
    difference()
    {
        // Flat surface for end of tubing
        translate([0,72,188])
            cylinder(r=10, h=10, $fn=80);
        // Tubing hole (again)
        translate([0,72,-1])
            cylinder(r=8, h=230);
    }
    // Add cap to contain water entry if desired
    if (fountainhead_cap)
        translate([0,62,199])
            difference()
            {
                sphere(r=26, $fn=80);
                sphere(r=24, $fn=80);
                translate([0,-10,0]) rotate([25,0,0]) cube([60,36,60], center=true);
                translate([0,0,-44]) cube([60,60,60], center=true);
            }
    if (include_shiv_murti) translate([0,-15,-5])
        import("shankara-murudeshwar.stl", convexity=5);
    // Add internal supports for base. These would need
    // additional height to reach bottom of basin.
    if (internal_support_pillars)
    {
        pthick = 1.5;
        #translate([0,-39,0]) cylinder(r=pthick, h=50);
        #translate([20,-36,0]) cylinder(r=pthick, h=50);
        #translate([-20,-36,0]) cylinder(r=pthick, h=50);
        #translate([45,-16,0]) cylinder(r=pthick, h=50);
        #translate([-45,-16,0]) cylinder(r=pthick, h=50);
        #translate([58,20,0]) cylinder(r=pthick, h=50);
        #translate([-58,20,0]) cylinder(r=pthick, h=50);
    }
    if (internal_span_supports)
    {
        generate_internal_span_supports();
    }
    if (cave_roof_supports)
        generate_cave_roof_supports();
}

// Test tubing adapter: 2 = feed tube that we have to be able to fish the tubing through; 3 = sealing adapter that we'll hotglue on the end
module new_tubing_test(test_type)
{
    test_h = 7;
    if (test_type == 2)
    {
        difference()
        {
            cylinder(r=10, h=test_h);
            translate([0,0,-0.5]) cylinder(r=8, h=test_h+1);
        }
    }
    else
    {
        union()
        {
            difference()
            {
                cylinder(r=7.8, h=5, $fn=80);
                translate([0,0,-0.5]) cylinder(r=4.75, h=6, $fn=80);
            }
            difference()
            {
                cylinder(r=10, h=2, $fn=80);
                translate([0,0,-0.5]) cylinder(r=7.7, h=3, $fn=80);
            }
        }
    }
}

if (new_fountain == 1)
    new_fountain_shape();
else if (new_fountain >= 2)
    new_tubing_test(new_fountain);
else
    old_fountain_shape();
