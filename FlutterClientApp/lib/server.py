import bluetooth
from bluetooth.btcommon import BluetoothError
import time
import json


drinksFile = 'drinks.json'

def setupBT():
    server_sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
    server_sock.bind(("", bluetooth.PORT_ANY))
    server_sock.listen(1)
    port = server_sock.getsockname()[1]
    uuid = "94f39d29-7d6d-437d-973b-fba39e49d4ee"
    bluetooth.advertise_service(server_sock, "SampleServer", service_id=uuid,
                                service_classes=[uuid, bluetooth.SERIAL_PORT_CLASS],
                                profiles=[bluetooth.SERIAL_PORT_PROFILE],
                                # protocols=[bluetooth.OBEX_UUID]
                                )
    print("Waiting for connection on RFCOMM channel", port)
    client_sock, client_info = server_sock.accept()
    print("Accepted connection from", client_info)
    runServer(client_sock, client_sock, server_sock)

def runServer(client_sock, client_info, server_sock):
    serializeSendData(client_sock, readDrinksFile(drinksFile))
    try:
        while True:
            data = client_sock.recv(1024)
            if data == 'quit':
                break
            print(data)
    except:
        print("Disconnected from ", client_info)
        client_sock.close()
        server_sock.close()
        print("Restarting BT server")
        setupBT()


def readDrinksFile(jsonFile):
    try:
        jsonFileObj = open(jsonFile,"r")
        jsonObj = json.load(jsonFileObj)
        print("Content loaded successfully from the %s file" %(jsonFile))
        jsonFileObj.close()
        print(str(jsonObj))
        return jsonObj
    except (Exception, IOError) as e:
        print("Failed to load content from the %s" % (jsonFile), e)

def serializeSendData(clientSocket, data):
    print('serialize');
    try:
        serializedData = json.dumps(data)
        print("Object successfully converted to a serialized string")
        sendData(clientSocket, serializedData)
    except (Exception) as e:
        print("Failed to convert json object  to serialized string", e)

def sendData(clientSocket, _serializedData):
    try:
        print("Sending data over bluetooth connection")
        clientSocket.send(_serializedData)
        time.sleep(0.5)
        while True:
            dataRecv= clientSocket.recv(1024)
            if dataRecv in ['EmptyBufferResend', 'CorruptedBufferResend', 'DelimiterMissingBufferResend']:
                clientSocket.send(_serializedData)
                time.sleep(0.5)
                print("%s : Re-sending data over bluetooth connection" %(dataRecv))
            else:
                break
            print("Data sent successfully over bluetooth connection")
    except (Exception, IOError) as e:
        print("Failed to send data over bluetooth connection", e)

setupBT()