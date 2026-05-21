// Line 1
line1 = "Alachua Learning Academy";
// Line 1 text height
line1_size = 4.5; // [2.0:0.1:20.0]
// Line 1 vertical spacing (leading)
line1_leading = 1.6; // [0.8:0.1:10.0]
// Optional second line
line2 = "Maker Class 2025-2026";
// Second line height
line2_size = 3.8; // [2.0:0.1:20.0]
// How high to raise lettering
letter_height = 0.8; // [0.2:0.1:5.0]
// Optional hole in bottom right corner
punch_hole = false;

difference() {
  union() {
    // Ensure a small vertical overlap
    translate([142, -40, 0.01])
      import("Planetary_Gear_Business_Card_Blank.stl");
    //translate([-142, 40, -0.01]) { // Adjust the X, Y, and Z coordinates
        linear_extrude(height=letter_height ) {
            text(line1, size = line1_size, halign="left", valign="top");
            translate([0,-line1_size*line1_leading,0]) text(line2, size = line2_size, halign="left", valign="top");
        }
  }
  if (punch_hole) {
      translate([0,-35,-5])
        cylinder(h=6,r=2.5, $fn=40);
  }
}