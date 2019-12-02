#!/usr/bin/python3
import socket
from Crypto.PublicKey import RSA
from Crypto import Random
import time
from adafruit_crickit import crickit
import select
from datetime import datetime

time.sleep(3)

#Motor Stuff
timeForStartStopRotation = .59
timeForContinuousRotation = .57
numRotations = 6
servo = crickit.continuous_servo_1
currentWait = 0
isOpen = False
isQuit = False

#Time Stuff
with open("TimeStore", "r") as file:
    times = file.read().split()
    timeOpen = [int(times[0]), int(times[1])]
    timeClose = [int(times[2]), int(times[3])]

print(f"Open time: {timeOpen[0]}:{timeOpen[1]}")
print(f"Close time: {timeClose[0]}:{timeClose[1]}")

#Generate private key and public key
random_generator = Random.new().read
private_key = RSA.generate(1024, random_generator)
public_key = private_key.publickey()

#Declartion
mysocket = socket.socket()
host = "192.168.113.1"#socket.gethostbyname(socket.getfqdn())
port = 9876

encrypt_str = "encrypted_message="


print("host = " + host)




#Functions
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

def customDecode(data):
    return "".join( chr(x) for x in bytearray(data) )

def updateFileTimes():
    outputStr = str(timeOpen[0]) + " " + str(timeOpen[1]) + " " + str(timeClose[0]) + " " + str(timeClose[1])
    with open("TimeStore", "w") as file:
        file.write(outputStr)

def openBlinds():
    turnOn()
    runReverse()
    time.sleep(calcTotalWait())
    turnOff()
    return True

def closeBlinds():
    turnOn()
    runForward()
    time.sleep(calcTotalWait())
    turnOff()
    return False

#Prevent socket.error: [Errno 98] Address already in use
mysocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
mysocket.bind((host, port))
mysocket.listen(5)
#mysocket.settimeout(None)



while not isQuit:
    c, addr = mysocket.accept()
    #mysocket.settimeout(.5)
    print("Connected")
    #print(public_key.exportKey(format="PEM"))
    c.setblocking(0)

    while True:
        try:
            raw_data = c.recv(1024)
            raw_data = raw_data.replace(b"\n", b'') #remove new line character
            data = raw_data.decode("utf-8", "ignore")

            print(data)

            if data == "Client: OK":
                sendBack = outputStr = str(timeOpen[0]) + " " + str(timeOpen[1]) + " " + str(timeClose[0]) + " " + str(timeClose[1]) 
                #"public_key=" + public_key.exportKey().decode("utf-8") + "\n"
                c.send(sendBack.encode("utf-8"))

            elif data == "Open" and not isOpen:
                isOpen = openBlinds()
            elif data == "Close" and isOpen:
                isOpen = closeBlinds()
            elif "SetTimeOpen" in data:
                splt = data.split()
                timeOpen = [int(splt[1]), int(splt[2])]
                updateFileTimes()
            elif "SetTimeClose" in data:
                splt = data.split()
                timeClose = [int(splt[1]), int(splt[2])]
                updateFileTimes()
            elif data == "":
                break
            elif data == "Quit":
                isQuit = True
                break
                
        except:
            #Detect current time to see if automatically open
            now = datetime.now()
            hour = now.hour
            minute = now.minute
            second = now.second     
            if hour == timeOpen[0] and minute == timeOpen[1] and second < 1 and not isOpen: # 1 Second gap
                isOpen = openBlinds()   
            elif hour == timeClose[0] and minute == timeClose[1] and second < 1 and isOpen: # 1 Second gap
                isOpen = closeBlinds()



#Server to stop
turnOff()

c.send("Server stopped\n".encode("utf-8"))
print("Server stopped")
c.close()






# c.recv(1024)
# sendBack = "public_key=" + public_key.exportKey().decode("utf-8") + "\n"
# c.send(sendBack.encode("utf-8"))
# c.setblocking(0)
# while True:
#     try:
#         data=c.recv(1024)
#         print ('recived: ',data,len(data))

#     except:
#         pass      

#     # #time.sleep(1)
#     # ready = select.select([mysocket], [], [], .1)
#     # mysocket.setblocking(0)
#     # print(ready)
#     # #print(ready)
#     # if ready[0]:
#     #     c.recv(1024)
#     #     print("received")
#     #     sendBack = "public_key=" + public_key.exportKey().decode("utf-8") + "\n"
#     #     c.send(sendBack.encode("utf-8"))
#     #     print("done")


# c.recv(1024)
# sendBack = "public_key=" + public_key.exportKey().decode("utf-8") + "\n"
# c.send(sendBack.encode("utf-8"))
# c.setblocking(0)







    # #time.sleep(1)
    # ready = select.select([mysocket], [], [], .1)
    # mysocket.setblocking(0)
    # print(ready)
    # #print(ready)
    # if ready[0]:
    #     c.recv(1024)
    #     print("received")
    #     sendBack = "public_key=" + public_key.exportKey().decode("utf-8") + "\n"
    #     c.send(sendBack.encode("utf-8"))
    #     print("done")


#Single Thread
# while True:
#     print("go")
#     #Wait until data is received.
#     raw_data = c.recv(1024)
#     raw_data = raw_data.replace(b"\n", b'') #remove new line character
#     data = raw_data.decode("utf-8", "ignore")

#     print(data)

#     if data == "Client: OK":
#         sendBack = "public_key=" + public_key.exportKey().decode("utf-8") + "\n"
#         c.send(sendBack.encode("utf-8"))

#     elif data == "Open":
#         turnOn()
#         runReverse()
#         time.sleep(calcTotalWait())
#         turnOff()
#     elif data == "Close":
#         turnOn()
#         runForward()
#         time.sleep(calcTotalWait())
#         turnOff()
#     elif "SetTimeOpen" in data:
#         splt = data.split()
#         hrs = splt[1]
#         min = splt[2]
#         print(hrs)
#         print(min)
#     elif "SetTimeClosed" in data:
#         pass
#     elif data == "Quit": break