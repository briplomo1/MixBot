import bluetooth
from bluetooth.btcommon import BluetoothError
from . import makeDrink
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
    serializeSendData(client_sock, json.dumps(readDrinksFile()))
    try:
        while True:
            data = client_sock.recv(1024)
            if data != None:
                makeDrink(data)
            else:               
                print('Couldnt make drink')
    except:
        print("Disconnected from ", client_info)
        client_sock.close()
        server_sock.close()
        print("Restarting BT server")
        setupBT()


def readDrinksFile():
    try:
        with open(drinksFile,"r") as j:
            jsonData = json.load(j)
            print("Content loaded successfully from the %s file" %(drinksFile))

            return jsonData
    except (Exception, IOError) as e:
        print("Failed to load content from the %s" % (drinksFile), e)


def serializeSendData(clientSocket, data):
    print('serialize');
    try:
        serializedData = data
        print("Object successfully converted to a serialized string")
        sendData(clientSocket, serializedData)
    except (Exception) as e:
        print("Failed to convert json object  to serialized string", e)

def sendData(clientSocket, _serializedData):
    try:
        print("Sending data over bluetooth connection")
        clientSocket.send(_serializedData)
        print("Data sent successfully over bluetooth connection")
    except (Exception, IOError) as e:
        print("Failed to send data over bluetooth connection", e)

setupBT()