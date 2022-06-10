Python bluetooth server designed for Raspberry Pi 3 +.
Sends json drinks list to Flutter client. Client displays drink menu and upon choosing drink and on tap, returns string of drink name which is proccessed by server.
Drink requested is processed in makeDrink.py where pins are mapped and drink is poured.
makeDrink function is based on Raspberry Pi 3 and a 1 to 1 relay to motor design. Seconds that motor runs is based on testing of motor pump flow rate.
