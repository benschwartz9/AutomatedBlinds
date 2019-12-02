import time
from adafruit_crickit import crickit

timeForStartStopRotation = .59
timeForContinuousRotation = .57
numRotations = 4

servo = crickit.continuous_servo_1

def calcTotalWait():
    return timeForStartStopRotation + timeForContinuousRotation * (numRotations - 1)

def turnOn():
    servo._pwm_out.duty_cycle = 65535

def turnOff():
    servo._pwm_out.duty_cycle = 0

def runForward():
    servo.throttle = 1

def runReverse():
    servo.throttle = -1


print("Start")
turnOn()
runReverse()
#runForward()
time.sleep(calcTotalWait())
turnOff()
print("done")

# while count < numRotations:
#     runForward()
#     #runReverse()
#     time.sleep(timeForStartStopRotation + timeForContinuousRotation)
#     count += 1

#crickit.servo_1._pwm_out.duty_cycle = 65535

#servo.throttle = 1

# while count < 1:
#    time.sleep(1)
#    servo._pwn_out.duty_cycle = 0
#    count += 1

#servo.throttle = 0

