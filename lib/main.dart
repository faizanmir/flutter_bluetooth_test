import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';
import 'Scanner.dart';
import 'package:uuid/uuid.dart' as uuid;
void main() {
  return runApp(MaterialApp(home: StartStopAndListBluetoothDevices()));
}

class StartStopAndListBluetoothDevices extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StartStopState();
  }
}

class StartStopState extends State<StartStopAndListBluetoothDevices> implements OnPressDeviceListener {
  List<BluetoothDevice> bluetoothDevice;
  BluetoothScanner bluetoothScanner;
  StreamSubscription scanResult;
  FlutterBlue flutterBlue;
  bool isLoading = false;
  StartStopState() {
    bluetoothDevice = new List<BluetoothDevice>();
    flutterBlue = FlutterBlue.instance;
  }

  _fetchDevices() {
    scanResult = flutterBlue.scan().listen((scanResult) {
      if(!bluetoothDevice.contains(scanResult))
        if(scanResult.device.name.length>0) {
          setState(() {
            isLoading = true;
          });
          bluetoothDevice.add(scanResult.device);

        }
    });


  }

  _cancelScan() {
    isLoading = true;
    scanResult.cancel();
    flutterBlue.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Bluetooth Scan and List "),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 300,

              child:
              new ListOrProgress(isLoading,bluetoothDevice),
            ),
            Row(
              children: <Widget>[],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new Buttons("Start", () {
                  print("Starting scan");
                  _fetchDevices();
                }),
                new Buttons("Stop", () {
                  print("Stopping Scan");
                  _cancelScan();
                })
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void onPress(BluetoothDevice bluetoothDevice) {
     print("Connect");
      bluetoothDevice.connect();
      
  }
}

class ListOrProgress extends StatelessWidget  {
   final bool isLoading;
  ListOrProgress(this.isLoading, this.bluetoothDevice);
  BluetoothCharacteristic bluetoothCharacteristic;
  final List<BluetoothDevice> bluetoothDevice;
  _discoverServices(BluetoothDevice device) async {
    await device.connect();
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) {
      print("${service.uuid}");
      List<BluetoothCharacteristic> blueChar = service.characteristics;
      blueChar.forEach((f){
        print("Characteristice =  ${f.uuid}");
        if(f.uuid.toString().compareTo("00000052-0000-1000-8000-00805f9b34fb")==0)
          {
            bluetoothCharacteristic = f;
            print(true);
          }

      });
      



    });

    bluetoothCharacteristic.write([0x11]);
  }
  @override
  Widget build(BuildContext context) {
     if(isLoading) {
       return ListView.builder(itemBuilder: (context, int position) {
         return ListTile(
           isThreeLine: true,
           title: Text(bluetoothDevice[position].name),
           subtitle: Text(bluetoothDevice[position].id.toString()),
           onTap: () {
               _discoverServices(bluetoothDevice[position]);

           },
         );
       });
     }else
       {
         return Center(child: Container(
           height: 50,
           width: 50,
           child: CircularProgressIndicator(
           ),
         ));
       }
  }


}

class Buttons extends StatelessWidget {
  final String text;
  final Function function;
  Buttons(this.text, this.function);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: RaisedButton(
            onPressed: function,
            child: Text(text),
          ),
        ),
      ],
    );
  }
}

abstract class OnPressDeviceListener {
  void onPress(BluetoothDevice bluetoothDevice);
}
