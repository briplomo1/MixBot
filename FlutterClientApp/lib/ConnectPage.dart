import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';
import 'Drinks.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Connect extends StatefulWidget {
  final BluetoothDevice server;

  Connect({@required this.server});

  @override
  _ConnectState createState() => _ConnectState();
}

class _ConnectState extends State<Connect> {
  BluetoothConnection connection;
  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;
  bool isDisconnecting = false;

  //Empty list filled by incoming json data
  List<Drink> _drinks = List<Drink>();

  @override
  void initState() {
    super.initState();
    _getBTConnection();
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }
    super.dispose();
  }

  _getBTConnection() {
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      connection = _connection;
      isConnecting = false;
      isDisconnecting = false;

      setState(() {});
      connection.input.listen(_onDataReceived).onDone(() {
        if (this.mounted) {
          setState(() {});
        }
        Navigator.of(context).pop();
      });
    }).catchError((error) {
      Navigator.of(context).pop();
      print(error);
    });
  }

  void _onDataReceived(Uint8List data) async {
    var jsonData = ascii.decode(data);
    print('ascii decoded');
    List newData = json.decode(jsonData);
    print('jsonDecode');
    List<Drink> drinks =
        newData.map((drink) => new Drink.fromJson(drink)).toList();
    print(drinks[0].name);
    setState(() {
      _drinks = drinks;
    });
    print(_drinks[0]);
  }

  void sendMessage(String text) async {
    text = text.trim();
    if (text.length > 0) {
      try {
        print('Sending data over bluetooth...');
        connection.output.add(utf8.encode(text));
        await connection.output.allSent;
      } catch (e) {
        print(e);
        setState(() {});
      }
    }
  }

//////////////////////////////////////////////////////////////////////
  ///The build and styling of Drinks page
////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: (isConnecting
              ? Text('Connecting to ${widget.server.name}...')
              : isConnected
                  ? Text('Connected with ${widget.server.name}')
                  : Text('Disconnected with ${widget.server.name}'))),
      body: SafeArea(
        child: _drinks != null
            ? ListView(
                children: _drinks.map((drink) {
                  return Padding(
                    padding: EdgeInsets.all(15),
                    // Every drink in drinks.json will produce one list tile
                    child: ListTile(
                      onTap: () => sendMessage(drink.name),
                      title: Text(drink.name),
                    ),
                  );
                }).toList(),
              )
            : Center(
                child: Text('Connecting...'),
              ),
      ),
    );
  }
}
