// Barb adaptor v1.0 - Adapted from barb generator v1.7 15Aug2020
// Use customizer keyword in Thingiverse object to enable customize button
// See https://customizer.makerbot.com/docs

/* [Inputs] */

//  Measurement system for inputs - US in inches, Metric in mm
input_units = "US"; // [US,Metric]

// Input tubing inside diameter, e.g. 0.5 for 1/2 inch (US); 0.625 for 5/8 (0.620 may be better), 0.75 for 3/4, etc; note that input is always on the bottom of the print
input_size = 0.25;

// Strength factor - use more than 1 for thicker walls to handle higher pressure and stronger clamping. Range: 0.9-1.5. Reduce only for I.D. greater than 0.5 inches
input_strength = 1.1;

// Input barb count - may be 3 for larger barbs, more for smaller
input_barb_count = 3;

/* [Straw] */

// Length of straw inside jar - 0 for none. Measured from inside bottom of lid pad
straw_length = 0;

// Measurement system for straw
straw_units = "Metric"; // [US,Metric]

// Angled cut on bottom of straw in degrees. 90 for flat
straw_cut_angle = 90;


make_adapter( input_units == "US" ? input_size * 25.4 : input_size, straw_units == "US" ? straw_length * 25.4 : straw_length );

module make_adapter( input_diameter, straw_length_mm )
{
    input_total_height = (input_barb_count - 1) * 0.9 * input_diameter + input_diameter;

difference() {
  union() {
    junction_height = 4;
    junction_diameter_ratio = 1.1;
    max_dia = input_diameter;
    r1a = max_dia * junction_diameter_ratio / 2;
    r1b = input_diameter / 2;
      input_barb( input_diameter );
    //echo("ith=", input_total_height, " id=", input_diameter, " ibc=", input_barb_count);
    // Add a fillet collar from the top barb to the knob
    translate([0,0,input_total_height]) union() {
      cylinder( h = input_diameter, r1 = input_diameter * 1.16 / 2, r2 = 20 / 2, $fn=100 );
      translate([0,0,input_diameter+9]) import("plunger-knob-4fit.stl");
      if (straw_length_mm > 0) translate([0,0,input_diameter+9+10]) cylinder( h=straw_length_mm, r = input_diameter / 2, $fn=100 );
    }
  }
  // Hollow out center through straw
  translate([0,0,-5]) cylinder( h=straw_length_mm+input_total_height+input_diameter*2+20, r=input_diameter * 0.5 / 2, $fn=100 );
}
} // end module make_adapter


module barbnotch( inside_diameter )
{
  // Generate a single barb notch
  cylinder( h = inside_diameter * 1.0, r1 = inside_diameter * 0.85 / 2, r2 = inside_diameter * 1.16 / 2, $fa = 0.5, $fs = 0.5, $fn = 100 );
}

module solidbarbstack( inside_diameter, count, reinforcement = 0 )
{
    // Generate a stack of barbs for specified count
    // The height of each barb is [inside_diameter]
    // and the total height of the stack is
    // (count - 1) * (inside_diameter * 0.9) + inside_diameter
    union() {
      barbnotch( inside_diameter );
		for (i=[2:count]) 
		{
			translate([0,0,(i-1) * inside_diameter * 0.9]) barbnotch( inside_diameter );
		}
		/***
		if (count > 1) translate([0,0,1 * inside_diameter * 0.9]) barbnotch( inside_diameter );
		if (count > 2) translate([0,0,2 * inside_diameter * 0.9]) barbnotch( inside_diameter );
		***/
        if (reinforcement > 0) translate([0,0,(count-1)*inside_diameter * 0.9 + inside_diameter * 0.5]) cylinder( h = inside_diameter * 0.5, r1 = inside_diameter * 0.85 / 2, r2 = inside_diameter * (1.16 + reinforcement) / 2, $fa = 0.5, $fs = 0.5, $fn = 100 );
    }
}

module barb( inside_diameter, count, strength_factor, reinforcement = 0 )
{
  // Generate specified number of barbs
  // with a single hollow center removal
  if (count > 0)
    difference() {
        solidbarbstack( inside_diameter, count, reinforcement );
    translate([0,0,-0.3]) cylinder( h = inside_diameter * (count + 1), r = inside_diameter * (0.75 - (strength_factor - 1.0)) / 2, $fa = 0.5, $fs = 0.5, $fn=100 );
  }
  else
      difference() {
        cylinder( h = inside_diameter * output_smooth_length, r = 
inside_diameter / 2, $fn=60 );
    translate([0,0,-0.3]) cylinder( h = inside_diameter * output_smooth_length + 0.6, r = inside_diameter * (0.75 - (strength_factor - 1.0)) / 2, $fa = 0.5, $fs = 0.5, $fn=100 );
          //echo( "difference h=", (2*inside_diameter), "r=", inside_diameter/2, "; ir=", inside_diameter * (0.75 - (strength_factor - 1.0)) / 2 );
    }
}

module input_barb( input_diameter, reinforcement = 0 )
{
  barb( input_diameter, input_barb_count, input_strength, reinforcement );
}

module junction( input_diameter, output_diameter, jheight )
{
  junction_diameter_ratio = (inline_junction_type == "none") ? 1.1 : 1.6;
  lower_junction_diameter_ratio = (inline_junction_type == "none") ? 1.1 : 1.4;
  max_dia = max( input_diameter, output_diameter );
  r1a = max_dia * lower_junction_diameter_ratio / 2;
  r2a = max_dia * junction_diameter_ratio / 2;
  r1b = input_diameter / 2;
  r2b = output_diameter / 2;
  input_total_height = (input_barb_count - 1) * 0.9 * input_diameter + input_diameter;
  {
  //echo( "Junction jheight=", jheight, "; input_dia=", input_diameter, "; output_dia=", output_diameter, "; max_dia=", max_dia, r1a, r2a, r1b, r2b );
  translate( [0,0,input_total_height] ) difference() {
	cylinder( r1 = r1a, r2 = r2a, h = 5, $fa = 0.5, $fs = 0.5 );
	cylinder( r1 = r1b, r2 = r2b, h = (jheight + 1), $fa = 0.5, $fs = 0.5 );
  }
  }
}

