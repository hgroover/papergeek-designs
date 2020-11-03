#!/usr/bin/python
# From https://www.raspberrypi.org/forums/viewtopic.php?t=198815 (3rd snippet)
# May require sudo apt-get install python-gpiozero
# With the knob stem facing you and three pins on the top, A is rightmost, GND is center,
# and B is leftmost.

from gpiozero import Button
import Queue
from time import sleep

eventq = Queue.Queue()

pin_a = Button(19)                   # Rotary encoder pin A connected to GPIO19
pin_b = Button(26)                   # Rotary encoder pin B connected to GPIO26
#pin_c = Button(13) # Third pin for debugging

def pin_a_rising():                    # Pin A event handler
    if pin_b.is_pressed: eventq.put(-1)# pin A rising while A is active is a clockwise turn

def pin_b_rising():                    # Pin B event handler
    if pin_a.is_pressed: eventq.put(1) # pin B rising while A is active is a clockwise turn

def pin_c_rising():
    eventq.put(0)

pin_a.when_pressed = pin_a_rising      # Register the event handler for pin A
pin_b.when_pressed = pin_b_rising      # Register the event handler for pin B
#pin_c.when_pressed = pin_c_rising

while True:
    #sleep(1)
    message = eventq.get()
    print(message)
