#!/usr/bin/python
# From https://www.raspberrypi.org/forums/viewtopic.php?t=198815 (3rd snippet)
# May require sudo apt-get install python-gpiozero
# Rotation is from the observer's perspective, facing the front of the
# printer. The encoder stem is facing away, so with the three pins on the top,
# A is leftmost, GND is center and B is rightmost.
# Printing from a nearly full spool at 0.2mm/layer with SAMPLE_RATE = 10 yields output like:
#[1] 1/3 N=4 net -2
#[3] 0/1 N=1 net -1
#[7] 0/4 N=4 net -4
#[9] 0/1 N=1 net -1
#[11] 0/1 N=1 net -1
#[12] 1/0 N=1 net 1
#[14] 0/2 N=2 net -2
#[16] 0/1 N=1 net -1
#[19] 0/3 N=3 net -3


from gpiozero import Button
import Queue
from time import sleep

# Configuration
A_PIN = 19      # gpio19
B_PIN = 26      # gpio26
CW_SIGN = 1     # Clockwise rotation yields a net value with this sign. Normal print rotation will be CCW
SAMPLE_RATE = 2 # Sample rate in seconds
# end configuration

eventq = Queue.Queue()

pin_a = Button(A_PIN)                   # Rotary encoder pin A connected to GPIO19
pin_b = Button(B_PIN)                   # Rotary encoder pin B connected to GPIO26
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

serial = 0
while True:
    sleep(SAMPLE_RATE)
    cw_sum = 0
    ccw_sum = 0
    net_sum = 0
    m_count = 0
    while not eventq.empty():
      message = None
      try:
        message = eventq.get(block=False)
      except:
        message = None
      if message != None:
        m_count = m_count + 1
        if message == CW_SIGN:
          cw_sum = cw_sum + 1
        else:
          ccw_sum = ccw_sum + 1
        net_sum = net_sum + message
    serial = serial + 1
    if m_count > 0:
      print('[{0}] {1}/{2} N={3} net {4}'.format(serial, cw_sum, ccw_sum, m_count, net_sum))
