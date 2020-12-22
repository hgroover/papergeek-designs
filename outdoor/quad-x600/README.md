XKE600 quadcopter notes

Updated 22 December 2020.

Intro
=====

This project is a 3D-printed "X" configuration quadcopter. An "X" configuration is one of the most common
configurations for ready-to-fly UAVs (drones) and basically has arms at 90 degree angles to each other
with powered propellers at the end of all 4.

The X stands for the configuration ("X") and 600 refers to the span in millimeters from the center of
one propeller to the center of the opposite propeller.

Design
======

All design is in OpenSCAD with some of the accessories done in FreeCAD. Both are available for all
supported platforms (Linux, Windows and Mac). The basic airframe design philosophy is a compromise
between light weight, avoidance of sharp protuberances, reduced drag, relative robustness for rough
landings, and customization, including payloads such as an under-frame camera gimbal.

This was designed to be printed in PLA or PETG (with some parts in TPU), and held together using M3 
screws. Supporting both US and metric sizes was just not worth the trouble as M3 screw sets are 
readily available in the US through online retailers, and some M3 sizes are even available in the
parts drawers at home improvement chains like Lowe's and Home Depot.

The inverted parabolic arch design is meant to provide strength while relatively easy to print,
with hollow sections large enough for 18 gauge wires with 3.5mm bullet connectors (as are commonly
used on brushless motors and ESCs).

We've tried to adhere to a basic tenet of airframe design, which is to design for flying rather
than for crashing. The wall thickness of the parabolic sections was arrived at by iterative testing
by printing out a strut plus end section, then performing the "hammer test." The hammer test is
quite simple: use the strut, with an unusable motor attached to the end piece, as a hammer, with
the standoff (leg) on the strut striking concrete. If it didn't shatter immediately or suffer layer
separation, it was deemed adequate.

The strut legs are parameterized and can be made longer. They are not shock-absorbing, obviously,
but merely provide enough ground clearance for a small payload package such as a camera gimbal.

The central body has a large honeycomb pattern for weight reduction which should incidentally
allow some leeway for passing wiring components from top to bottom. It is basically an open
platform with a shell which does not cover it completely but should provide some protection
of the flight controller.

The unusual arrangement of spacers (which should be printed in TPU) which keep the GPS board
pressed against the inside of the shell serves two purposes:
1. Using TPU helps dampen motor vibration so the flight controller remains in a fixed position
   with vibrations reduced somewhat.
2. The GPS is kept separate from the ESCs with translucency for LEDs on the GPS board itself
   and also separate from metallic parts which may have become magnetized in contact with
   magnetic tools.

 The shell pillars are held in place by screws from the bottom with slot-type nut traps. While
 this makes assembly and disassembly somewhat awkward, it's not too onerous and connections on
 the flight controller are still accessible albeit tweezers may be needed. This modular design
 also is meant to make it somewhat easier to add slight variations in flight controller and
 GPS module size without requiring a reprint of the entire body.
 
 The GPS module is meant to be removed from whatever shell it may have come in. Hotglue may
 be useful for keeping the GPS module in place during assembly but may not be required.
 
Comparison with other 3D-printed designs
========================================
 
 I found one other OpenSCAD-based project on Thingiverse which was appealling but didn't
 entirely suit my needs, so set out to design this. I had purchased a "carbon friber"
 X525 kit from someone in Shenzhen via ebay a few years ago, with black fiberglass parts
 for the center open frame, square aluminum tubing struts, and the need for a number of
 3D-printed parts. Once I put everything together it flew quite nicely but accessorization
 required more 3D printing, and I also prefer the X configuration over +.
 
Hardware needed
===============
 
 All of the screws listed are M3, and all nuts should be M3 nuts with nylon inserts. Anything
 subject to vibration should use nylon insert nuts as they are less prone to loosening. Alternatively
 there may be anti-loosening compounds that work but I would still not trust them to repeated 
 vibration over time. Nylon insert nuts have a higher profile than regular hex nuts, and all the
 nut traps in this design should be able to accommodate them.
 
 M3x30
 M3x12
 M3x10
 M3x8
 
Flight components
=================
 
 Many of these are still being evaluated. My original kit came with 1000kv motors, although 920kv
 may be more appropriate.
 
 5000mAh 3S lipo battery (XT60 connectors seem to be the most popular nowadays)
 Power distribution board
 4x 30A ESC (electronic speed controller)
 Radio unit and receiver with at least 6 channels (I have a Turnigy 9X but there are better ones 
 available for a similar price as of this writing, and for around USD $150 there are radios which
 support telemetry)
 Flight controller (I have a Pixhawk 1).
 Power adapter for flight controller and radio receiver
 Telemetry for base station and UAV, with antenna (optional - I have a 915mhz unit which operates
 at 5V rather than the 3.3V used by my flight controller, so it needs a $10 TTL level shifter
 board)
 GPS module (I have the discontinued 3DR uBlox-based module with a small rechargeable battery backup)
 4x 1000kv brushless motors - the current design accommodates the 16x19 motor mount with screws going
 up directly through the printed end units - the X-shaped metal mount that usually comes with the motor
 is not needed.
 2x CW and 2x CCW propellers. Currently using Gemfan 1045 (10 inch with 4.5 pitch). Note that the propeller
 span is determined by design although longer struts could accommodate larger props. Also the pitch and
 prop size need to be matched to the battery, ESC and motor combination, otherwise you could have poor
 responsiveness and/or flight times.
 Optional FPV
 Optional GoPro or similar camera
 Arm switch and buzzer for flight controller
 
Printing parts
==============
 
Most of the parts are already rendered and saved as STL files. You'll need these parts from assembly.scad

 4x end assembly			end-assembly.stl
 4x strut					strut-assembly.stl
 4x upper spacers (TPU) 	spacer-upper.stl
 4x lower spacers (TPU) 	spacer-lower.stl
 1x pixhawk 				pixhawk.stl
 1x pixhawk top				pixhawk-top.stl
 1x shell (recommended light color filament for maximum translucency)
							shell.stl
 1x battery holder			battery-holder-5000.stl
 1x GPS holder				gps.stl
 
Note that the body can be customized with your FAA certificate number and identifying information.
These items can be entered in the Identifying info section of the OpenSCAD customizer.

Some accessory parts are in xke600-accessories.FCStd
 1x battery retainer		battery-retainer.stl
 
Print settings should generally be 50% infill, support touching print bed (required for body, struts and shell).
Brims recommended, particularly for PETG or using glass bed.

Slicing was done with Cura 4.8.

 