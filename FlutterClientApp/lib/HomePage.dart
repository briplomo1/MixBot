import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
import 'DevicesMenu.dart';
import 'ConnectPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // Global fluter state
  //Is updated when _getBTState
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  List<BluetoothDevice> devices = List<BluetoothDevice>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getState();
    _enableBluetooth();
    _stateListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.index == 0) {
      if (_bluetoothState.isEnabled) {
        _getBondedDevices();
      }
    }
  }

  // Gets current state of bluetooth
  _getState() {
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState.isEnabled) {
          _getBondedDevices();
        }
      });
    });
  }

  // Listens for changes in state
  _stateListener() {
    FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
      _bluetoothState = state;
      print("State isEnabled: ${state.toString()}");
      if (_bluetoothState.isEnabled) {
        _getBondedDevices();
      } else {
        devices.clear();
      }
      setState(() {});
    });
  }

  //Request to enable bluetooth if it is not enabled
  _enableBluetooth() async {
    _bluetoothState = await FlutterBluetoothSerial.instance.state;
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      return true;
    }
    return false;
  }

  // Gets list of paired devices
  _getBondedDevices() {
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      devices = bondedDevices;
      setState(() {});
    });
  }

  void connectDevice(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Connect(
        server: server,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('MixBot App'),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              SwitchListTile(
                title: Text('Enable Bluetooth'),
                value: _bluetoothState.isEnabled,
                onChanged: (bool value) {
                  future() async {
                    if (value) {
                      // Enable Bluetooth
                      await FlutterBluetoothSerial.instance.requestEnable();
                    } else {
                      // Disable Bluetooth
                      await FlutterBluetoothSerial.instance.requestDisable();
                    }
                  }

                  future().then((_) {
                    setState(() {});
                  });
                },
              ),
              ListTile(
                title: Text('Bluetooth STATUS'),
                subtitle: Text(_bluetoothState.toString()),
                trailing: RaisedButton(
                  child: Text('Bluetooth Settings'),
                  onPressed: () {
                    FlutterBluetoothSerial.instance.openSettings();
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  children: devices
                      .map((_device) => BluetoothDeviceListEntry(
                            device: _device,
                            enabled: true,
                            onTap: () {
                              connectDevice(context, _device);
                              print(_device.address);
                            },
                          ))
                      .toList(),
                ),
              )
            ],
          ),
        ));
  }
}
