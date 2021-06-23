// Bookmark generator
// Generate monogrammed bookmarks that incidentally help clean the print bed

/*[General]*/
// Layer thickness in mm
layer_thickness = 0.2; 
// Total layers to use for model
layer_count = 3;
// Monogram - leave blank for none
monogram = ""; 
// Width in mm. See notes on length for filling bed area.
bookmark_width = 30; 
// Length in mm. May need adjustment if multiple instances (in the slicer) don't pack neatly to fill your bed area.
bookmark_length = 100; 

/*[Plating]*/
// Number of copies to stack end to end lengthwise
plate_count_across = 1;
// Number of copies to stack side to side
plate_count_down = 1;
// Space between instances in mm
plate_spacing = 1; 

/*[Advanced]*/
// Additional movement for monogram along length
monogram_x_move = 0; 
// Additional movement for monogram along width
monogram_y_move = 0; 
// Use Help / Font list in OpenSCAD to see the exact text for available fonts and styles on your computer
// Some unicode Sanskrit glyphs a, aa, i, ii, u, uu, ma, maM, ku: अ आ इ ई उ ऊ म मं कु
monogram_font = "Liberation Mono:style=Regular"; 

module bookmark()
{
  difference()
  {
    cube([bookmark_length, bookmark_width, layer_thickness * layer_count]);
    if (monogram != "")
    {
        mg_size = bookmark_width - 8;
        // X translation should be half of character width
        translate([mg_size * 0.6 + monogram_x_move,
            bookmark_width/2 + monogram_y_move,
            (layer_count-1) * layer_thickness])
          rotate([0,0,90])
          linear_extrude(layer_thickness*2) 
            text(monogram, size=mg_size, font=monogram_font, halign="center", valign="center");
    }
  }
}

for (x=[1:plate_count_across])
    for (y=[1:plate_count_down])
        translate([(bookmark_length + plate_spacing) * (x-1),
                    (bookmark_width + plate_spacing) * (y-1),
                    0])
            bookmark();
