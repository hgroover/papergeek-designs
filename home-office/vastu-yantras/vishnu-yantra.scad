module s(unicode_s, textsize)
{
    linear_extrude(height=1)
    text(unicode_s, size=textsize, halign="center", valign="center", font="Sanskrit 2003:style=Regular");
}

module a_s(us, textsize, angle, flipped)
{
    r = 30.5;
    m90 = abs(angle % 90);
    q = floor(abs(angle / 90));
    a = r * sin(m90);
    b = r * cos(m90);
    xs = (q >= 2) ? -1 : 1;
    ys = (q >= 1 && q <= 2) ? -1 : 1;
    //x = (m90 == 0) ? (q % 2 == 0 ? 0 : r * xs) : r * xs;
    //y = r * ys;
    x = (q % 2 == 0) ? a * xs : b * xs;
    y = (q % 2 == 0) ? b * ys : a * ys;
    echo("angle", angle, "m90", m90, "q", q, "x", x, "y", y, "a", a, "b", b);
    translate([x,y,0])
        rotate([0,0,angle])
        translate([0,flipped ? 0.5 : 0,flipped ? 0 : 0])
        rotate([flipped ? 180 : 0, 0, 0])
        rotate([0, flipped ? 180 : 0, 0])
            s(us, textsize);
}

om_size = 10;
namo_size = 4.2;
keshav_size = 3;

import("vishnu-yantra-base.stl");
translate([0,0,6.4])
{
    translate([0,7,0])
        s("ॐ", om_size);
    translate([0,-1,0])
        s("नमो भगवते", namo_size); 
    translate([0,-8,0])
        s("वासुदेवाय", namo_size); 
    // DXF font handling will not render the ligature correctly in this case
    translate([-16.5,-9,0])
        s("", namo_size);
    translate([15.5,-9,0])
        s("", namo_size);
    translate([15.5,9,0])
        s("", namo_size);
    translate([-16.5,9,0])
        s("", namo_size);
    translate([-0.5,19,0])
        s("", namo_size);
    translate([-0.5,-19,0])
        s("", namo_size);
    a_s("केशव", keshav_size, 0, false);
    a_s("नारायण", keshav_size, -30, false);
    a_s("माधव", keshav_size, -60, false);
    a_s("गोविन्द", keshav_size, -90, false);
    a_s("विष्णु", keshav_size, -120, true);
    a_s("मधुसूदन", keshav_size, -150, true);
    a_s("त्रिविक्रम", keshav_size, -180, true);
    a_s("वामन", keshav_size, -210, true);
    a_s("श्रीधर", keshav_size, -240, true);
    a_s("हृषीकेश", keshav_size, -270, false);
    a_s("पद्मनाभ", keshav_size, -300, false);
    a_s("दामोदर", keshav_size, -330, false);

}