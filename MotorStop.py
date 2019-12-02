import time
from adafruit_crickit import crickit

servo = crickit.continuous_servo_1
#servo.throttle = 1
print("Stop")
count = 0

servo.throttle = -1
crickit.servo_1._pwm_out.duty_cycle = 0

#while count < 4:
#    time.sleep(1)
#    servo._pwn_out.duty_cycle = 0
#    count += 1

#servo.throttle = 0

print("done")