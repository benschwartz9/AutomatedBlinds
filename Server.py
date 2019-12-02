import socket
from Crypto.PublicKey import RSA
from Crypto import Random
import random


#Generate private key and public key
random_generator = Random.new().read
private_key = RSA.generate(1024, random_generator)
public_key = private_key.publickey()

#Declartion
mysocket = socket.socket()
host = "192.168.113.1"#socket.gethostbyname(socket.getfqdn())
port = 9876

encrypt_str = "encrypted_message="

# if host == "127.0.1.1": #"192.168.113.1":
#     import commands
#     host = commands.getoutput("hostname -I")
print("host = " + host)

#Prevent socket.error: [Errno 98] Address already in use
mysocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
print(0)
mysocket.bind((host, port))
print(1)
mysocket.listen(5)
print(2)
c, addr = mysocket.accept()
print(3)
#print(public_key.exportKey(format="PEM"))

def customDecode(data):
    return "".join( chr(x) for x in bytearray(data) )

def getHost():
    return int(random.random()*1000000)

while True:
    print("go")
    #Wait until data is received.
    raw_data = c.recv(1024)
    raw_data = raw_data.replace(b"\n", b'') #remove new line character
    data = raw_data.decode("utf-8", "ignore")

    
    print(data)

    if data == "Client: OK":
        sendBack = "public_key=" + public_key.exportKey().decode("utf-8") + "\n"
        c.send(sendBack.encode("utf-8"))
        print("public key sent")

    elif data == "Open":
        
    elif data == "Close":

    elif data == "SetTimeOpen"

    elif data == "SetTimeClosed"

    # elif encrypt_str in data:
    #     print("elif")


    #     #remove encrypt_str
    #     #raw_data = raw_data.replace(encrypt_str.encode("utf-8"), b'')
    #     data = data.replace(encrypt_str, '')

    #     #decrypt        
    #     decrypted = private_key.decrypt(data)
    #     decrypted = decrypted.decode("utf-8", "ignore")

    #     print(decrypted)

    #     #remove padding
    #     #See Link: How to decrypt an RSA encrypted file in Python
    #     if len(decrypted) > 0 and decrypted[0] == '\x02':
    #         pos = decrypted.find('\x00')
    #         if pos > 0:
    #             sendBack = "Server: OK"
    #             c.send(sendBack.encode("utf-8"))
    #             message = decrypted[pos+1:]
    #             print(message)

    elif data == "Quit": break

#Server to stop
c.send("Server stopped\n".encode("utf-8"))
print("Server stopped")
c.close()