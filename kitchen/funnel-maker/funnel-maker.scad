// Funnel maker

// Diameter of jar mouth
jar_diameter = 29.5;

// Width of brim
brim_width = 5.0;

// Length of spout
spout_length = 25.0;

// Ratio of filler top to mouth
top_to_bottom_ratio = 1.8;

// Wall thickness
wall_thickness = 2.0;

// Flip upside down
rotate([0,180,0])
rotate_extrude($fn=200)
//linear_extrude(height=10)
    polygon( points=[
  [jar_diameter/2,0],
  [jar_diameter/2-wall_thickness,0], 
  [jar_diameter/2-wall_thickness, spout_length+wall_thickness], 
  [top_to_bottom_ratio*jar_diameter/2+spout_length-wall_thickness, top_to_bottom_ratio*jar_diameter/2+spout_length],
  [top_to_bottom_ratio*jar_diameter/2+spout_length+brim_width, top_to_bottom_ratio*jar_diameter/2+spout_length],
  [top_to_bottom_ratio*jar_diameter/2+spout_length+brim_width, top_to_bottom_ratio*jar_diameter/2+spout_length-wall_thickness],
  [top_to_bottom_ratio*jar_diameter/2+spout_length, top_to_bottom_ratio*jar_diameter/2+spout_length-wall_thickness],
  [jar_diameter/2, spout_length]
  ] );
  
//    polygon( points=[
//  [0,jar_diameter],
//  [0, jar_diameter-wall_thickness], 
//  [spout_length+wall_thickness, jar_diameter-wall_thickness], 
//  [2*jar_diameter+spout_length, 2*jar_diameter+spout_length-wall_thickness],
//  [2*jar_diameter+spout_length, 2*jar_diameter+spout_length+brim_width],
//  [2*jar_diameter+spout_length-wall_thickness, 2*jar_diameter+spout_length+brim_width],
//  [2*jar_diameter+spout_length-wall_thickness, 2*jar_diameter+spout_length],
//  [spout_length, jar_diameter]
//  ] );
  
