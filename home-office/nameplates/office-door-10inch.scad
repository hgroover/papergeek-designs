// Door nameplate customizer

// Thickness of plate where it fits into holder
thickness = 1.6; // [0.4:0.1:2.0]

// Height of plate from top to bottom
height = 51.0;

// Length of plate
length = 254.0; // [100.0:300.0]

// Margin for lettering
margin = 12.0; // [10.0:0.4:18.0]

// Text to put in raised letters
display_text = "Your Name";

// How much to raise letters above plate
raise_amount = 1.6; // [0.4:0.2:2.0]

union() {
    translate([0,0,thickness/2]) 
      cube([length, height, thickness], center=true);
    translate([0,0,thickness/2 + raise_amount])
      linear_extrude( height=raise_amount, center=true, $fn=40 )
        text( display_text, size = (height - 2 * margin), halign="center", valign="center" );
}
