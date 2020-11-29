#import Rpi.GPIO as GPIO
import json
import time

# GPIO.setmode(GPIO.BOARD)
# GPIO.setwarnings(False)

# for pin in range(3,9):
#     GPIO.setup(pin, GPIO.OUT)
#     print('GPIOs is setup')

def drinksDict():
    try:
        with open('drinks.json',"r") as j:
            jsonData = json.load(j)
            print("Content loaded successfully from the drinks file")
            return jsonData
    except (Exception, IOError) as e:
        print("Failed to load content from the drinks file", e)


mapLiquors = {
        'vodka': 3,
        'whiskey': 4,
        'sourmix':  5,
        'tequila': 6,
        'rum': 7,
        'clubsoda': 8
    }
def makeDrink(key):
    for drink in drinksDict():
        if drink['name'] == key:
            for item in drink['ingredients']:
                pour(item, drink['ingredients'][item])


    

def pour(item, amount):
    pumpRunTime = float(amount) * 5
    # Motor run for amount
    # 1 oz is equal to 17secs
    pin = mapLiquors[item]
    GPIO.output(pin, True)
    time.sleep(pumpRunTime)
    GPIO.output(pin, False)
    print('Dispensed for '+str(pumpRunTime)+' seconds from motor '+str(pin-2))
        

makeDrink('WhiskeySour')