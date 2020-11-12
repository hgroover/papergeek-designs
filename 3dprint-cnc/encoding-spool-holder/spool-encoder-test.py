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
import time
# Work with Python 2 for now. Ideally use monotonic_ns() instead of clock()
#from time import sleep, monotonic_ns
import sys

# Configuration
A_PIN = 19      # gpio19
B_PIN = 26      # gpio26
FEED_SIGN = 1   # Normal print rotation (feeding filament) will have this sign, 1=CW, -1=CCW
SAMPLE_RATE = 6.0 # Sample rate in seconds
# end configuration

# Original test queued pairs of [value, time.clock()] but showed that values were
# reliably sequential
eventq = Queue.Queue()

pin_a = Button(A_PIN)                   # Rotary encoder pin A connected to GPIO19
pin_b = Button(B_PIN)                   # Rotary encoder pin B connected to GPIO26
#pin_c = Button(13) # Third pin for debugging

# Testing for if pin_b.is_pressed leads to false multiples
# There will be many repeated events which we need to tabulate, e.g.
# 1 2 1 2 1 2 1 -1 2 1 2 1 2 1 2 -2 1 -1 2 (ccw, cw, cw, cw, ccw) 
def pin_a_rising():                    # Pin A event handler
    #if pin_b.is_pressed: eventq.put(-1)# pin A rising while B is active is a counter-clockwise turn
    #eventq.put([-1,time.clock()])
    eventq.put(-1)

def pin_a_falling():
    #eventq.put([-2,time.clock()])
    eventq.put(-2)

def pin_b_rising():                    # Pin B event handler
    #if pin_a.is_pressed: eventq.put(1) # pin B rising while A is active is a clockwise turn
    #eventq.put([1,time.clock()])
    eventq.put(1)

def pin_b_falling():
    #eventq.put([2,time.clock()])
    eventq.put(2)

def pin_c_rising():
    eventq.put(0)

pin_a.when_pressed = pin_a_rising      # Register the event handler for pin A
pin_b.when_pressed = pin_b_rising      # Register the event handler for pin B
#pin_c.when_pressed = pin_c_rising
pin_a.when_released = pin_a_falling
pin_b.when_released = pin_b_falling

serial = 0
a_hi = False
b_hi = False
# Maintain running average of net feed motion per second
feed_motion = [0,0,0,0,0,0,0,0,0,0]
while True:
    time.sleep(SAMPLE_RATE)
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
        # A (CCW) uses -1 rising, -2 falling
        # B (CW) uses 1 rising, 2 falling
        if message == -1:
           if b_hi:
              ccw_sum = ccw_sum + 1
           a_hi = True
        elif message == 1:
           if a_hi:
              cw_sum = cw_sum + 1
           b_hi = True
        elif message == -2:
           a_hi = False
        elif message == 2:
           b_hi = False
        #print('[{0}] {1} {2}'.format(serial, message[0], message[1]))
        #print('{0} {1}'.format(serial, message))
        m_count = m_count + 1
        #if message == CW_SIGN:
        #  cw_sum = cw_sum + 1
        #else:
        #  ccw_sum = ccw_sum + 1
        #net_sum = net_sum + message
    serial = serial + 1
    if FEED_SIGN > 0: # CCW is normal direction for feeding
      net_sum = ccw_sum - cw_sum
    else: # CW is normal direction for feeding
      net_sum = cw_sum - ccw_sum
    #if m_count > 0:
    #  print('{0} {1}/{2} N={3} net {4}'.format(serial, cw_sum, ccw_sum, m_count, net_sum))
    rate_sum = 0.0
    # Note odd expression to cover [8,7,6,5,4,3,2,1,0]
    for n in range(8,-1,-1):
      feed_motion[n+1] = feed_motion[n]
      rate_sum = rate_sum + feed_motion[n]
    feed_motion[0] = net_sum / SAMPLE_RATE
    moving_avg = (rate_sum + feed_motion[0]) / 10
    print('rate {0} moving_avg {1} sum {3} set {2}'.format(feed_motion[0], moving_avg, feed_motion, rate_sum + feed_motion[0]))
    sys.stdout.flush()
