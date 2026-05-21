#!/bin/sh
# Specify names via command line
OPENSCAD="/c/Program Files/OpenSCAD/openscad.exe"

LINE1LEADING=1.6
LINE1SIZE=17.3
LETTERHEIGHT=1.2
HOLE=true
LINE2_TEXT=""
LINE2_TEXT="True North"
LINE2_SIZE=5.5

[ "$1" ] || { echo "No names specified"; exit 1; }

for name in $*
do
	text_name="$(echo ${name} | tr '_' ' ')"
	echo "${name} (${text_name})"
	"${OPENSCAD}" -o gear-card-${name}.stl -D "line1=\"${text_name}\"" -D line1_size=${LINE1SIZE} -D line1_leading=${LINE1LEADING} -D "line2=\"${LINE2_TEXT}\"" -D "line2_size=${LINE2_SIZE}" -D letter_height=1.2 -D punch_hole=${HOLE} --export-format binstl gear-card.scad
done

