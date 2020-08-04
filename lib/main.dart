import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
// import 'package:mqtt_client_example/models/message.dart';
// import 'package:mqtt_client_example/dialogs/send_message.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'IoT GARDEN '),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String update;
  String titleBar         = 'MQTT';
  String broker           = 'soldier.cloudmqtt.com';
  int port                = 10775;
  String username         = 'odgbcjgh';
  String passwd           = 'eRbn2-b8D7br';
  String clientIdentifier = 'ESP8266Phone';

  // String topic           = 'temp';
  Set<String> topics      = Set<String>();
  double _temp  = 30;
  double _hum   = 60;
  double _pump  = 0;
  double _light = 0;

  // double _control = 0;
  String _soilhum ;
  String _state = "M";
  String _control = 'OFF';
  int _qosValue = 3;
  String _messageContent = '1';
  String _topicContent;// = 'Project/Light';//'control';
  bool _retainValue = false;

  TextEditingController updateController = TextEditingController();

  mqtt.MqttClient client;
  mqtt.MqttConnectionState connectionState;

  StreamSubscription subscription;


  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:AssetImage("images/leaf.jpg"),
            fit: BoxFit.cover,
            ),
        ),
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Stack(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //mainAxisAlignment: MainAxisAlignment.center,
          
          children: <Widget>[
            Positioned(
              top: 60,
              left: 40,
              child: Text(
              'Nhiệt độ không khí:',
              style: TextStyle(
                color: Colors.white, 
                fontSize: 40, 
                fontWeight: FontWeight.w500, 
              ),
            ),
            ),

            Positioned(
              top: 100,
              left: 120,
              child: Text(
              '$_temp°C',
              style:  TextStyle(
                color: Colors.white, 
                fontSize: 60, 
                fontWeight: FontWeight.w500, 
              ), //Theme.of(context).textTheme.headline4,
            ),
            ),

            Positioned(
              top: 180,
              left: 115,
              child: Text(
              'Độ ẩm đất:',
              style: TextStyle(
                color: Colors.white, 
                fontSize: 40, 
                fontWeight: FontWeight.w500,                 
              ),
            ),
            ),

            Positioned(
              top: 220,
              left: 120,
              child: Text(
              '$_hum%',
              style: TextStyle(
                color: Colors.white, 
                fontSize: 60, 
                fontWeight: FontWeight.w500, 
              ),
                //Theme.of(context).textTheme.headline4,
            ),
            ),


            //  Positioned(
            //   top: 200,
            //   left: 80,
            //   child: Text(
            //   '$_control',
            //   style: Theme.of(context).textTheme.headline4,
            // ),
            // ),

            Positioned(
              top: 300,
              left: 60,
              child: Text(
              'Độ ẩm cần thiết:',
              style: TextStyle(
                color: Colors.white, 
                fontSize: 40, 
                fontWeight: FontWeight.w500, 
              ),
            ),              
            ),

            Positioned(
              top: 310,
              left: 140,
              child:SizedBox( //Input Broker
              width: 120.0,
              child: TextField(
                controller: updateController,
                decoration: InputDecoration(
                  hintText: _soilhum,
                  hintStyle: TextStyle(fontSize: 60, color: Colors.white, fontWeight: FontWeight.w500,),
                  ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 60.0,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
            ),

            Positioned(
              top: 340,
              left: 250,
              child: Text(
              '%',
              style: TextStyle(
                color: Colors.white, 
                fontSize: 60, 
                fontWeight: FontWeight.w500, 
              ),
            ),              
            ),

            Positioned(
              top: 420,
              left: 100,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0), 
                  side: BorderSide(color: Colors.red),
                  ),
                onPressed: (){
                  _topicContent = "Project/Limit";
                  if(updateController.value.text.isNotEmpty) {
                    _messageContent = updateController.value.text;
                    _sendMessage();
                    updateController.clear();
                  }
                 
                },
                child:Text(
                  'Lưu',
                  style: TextStyle(color: Colors.redAccent, 
                  fontSize: 30, 
                  fontWeight: FontWeight.w500, 
                  // fontStyle: FontStyle.italic,
                  ),//Theme.of(context).textTheme.headline4,
                ),
              ),
            ),

            Positioned(
              top: 420,
              left: 210,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0), 
                  side: BorderSide(color: Colors.red),
                ),
                onPressed:(){
                  _topicContent = "Project/Pump";
                  if (_control == 'ON'){
                     _messageContent = 'OFF';
                    // setState(() {
                    //   _control = 'OFF';
                    // });
                    _sendMessage();
                  }
                  else {
                    _messageContent = 'ON';
                    // setState(() {
                    //   _control = 'ON';
                    // });
                    _sendMessage();
                  }                 
                }, //_sendMessage,
                child:Text(
                  '$_control',
                  style: TextStyle(color: Colors.redAccent, 
                  fontSize: 30, 
                  fontWeight: FontWeight.w500, 
                  // fontStyle: FontStyle.italic,
                  ),//Theme.of(context).textTheme.headline4,
                ),
              ),
            ),

            Positioned(
              top: 470,
              left: 100,
              child:SizedBox( //Input Broker
              width: 200.0,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0), 
                  side: BorderSide(color: Colors.red),
                ),               
                onPressed: (){
                  if (client?.connectionState == mqtt.MqttConnectionState.connected) {
                    _disconnect();
                  } else {
                  _connect();
                  }                  
                },
                child:Text(
                  'Kết nối',
                  style: TextStyle(color: Colors.redAccent, 
                  fontSize: 30, 
                  fontWeight: FontWeight.w500, 
                  // fontStyle: FontStyle.italic,
                  ),//Theme.of(context).textTheme.headline4,
                ),
              ),              
            ),
            ),
           
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:(){
                  _topicContent = "Project/Control";
                  if (_state == 'A'){
                    
                    _messageContent = 'M';
                     setState(() {
                      _state = 'M';
                    });
                    _sendMessage();
                  }
                  else {
                    _messageContent = 'A';
                    setState(() {
                      _state = 'A';
                    });
                    _sendMessage();
                  }                 
                },
        tooltip: 'Increment',
        child:Text(
                  '$_state',
                  style: TextStyle(color: Colors.white, 
                  fontSize: 30, 
                  fontWeight: FontWeight.w500, 
                  // fontStyle: FontStyle.italic,
                  ),//Theme.of(context).textTheme.headline4,
                ), 
      ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: _incrementCounter,
    //     tooltip: 'Increment',
    //     child: Icon(Icons.add),
    //   ), // This trailing comma makes auto-formatting nicer for build methods.
    // );
    );
  
  }
  void _connect() async {
    /// First create a client, the client is constructed with a broker name, client identifier
    /// and port if needed. The client identifier (short ClientId) is an identifier of each MQTT
    /// client connecting to a MQTT broker. As the word identifier already suggests, it should be unique per broker.
    /// The broker uses it for identifying the client and the current state of the client. If you don’t need a state
    /// to be hold by the broker, in MQTT 3.1.1 you can set an empty ClientId, which results in a connection without any state.
    /// A condition is that clean session connect flag is true, otherwise the connection will be rejected.
    /// The client identifier can be a maximum length of 23 characters. If a port is not specified the standard port
    /// of 1883 is used.
    /// If you want to use websockets rather than TCP see below.
    /// 
    client = mqtt.MqttClient(broker, '');
    client.port = port;
    
    /// A websocket URL must start with ws:// or wss:// or Dart will throw an exception, consult your websocket MQTT broker
    /// for details.
    /// To use websockets add the following lines -:
    /// client.useWebSocket = true;
    /// client.port = 80;  ( or whatever your WS port is)
    /// Note do not set the secure flag if you are using wss, the secure flags is for TCP sockets only.

    /// Set logging on if needed, defaults to off
    client.logging(on: true);

    /// If you intend to use a keep alive value in your connect message that is not the default(60s)
    /// you must set it here
    client.keepAlivePeriod = 30;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = _onDisconnected;

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password, the default keepalive interval(60s)
    /// and clean session, an example of a specific one below.
    final mqtt.MqttConnectMessage connMess = mqtt.MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        // Must agree with the keep alive set above or not set
        .startClean() // Non persistent session for testing
        .keepAliveFor(30)
        // If you set this you must set a will message
        .withWillTopic('test/test')
        .withWillMessage('nghia message test')
        .withWillQos(mqtt.MqttQos.atMostOnce);
    print('MQTT client connecting....');
    client.connectionMessage = connMess;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    
    try {
      await client.connect(username, passwd);
    } catch (e) {
      print(e);
      _disconnect();
    }

    /// Check if we are connected
    if (client.connectionState == mqtt.MqttConnectionState.connected) {
      print('MQTT client connected');
      setState(() {
        connectionState = client.connectionState;
      });
    } else {
      print('ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client.connectionState}');
      _disconnect();
    }

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    subscription = client.updates.listen(_onMessage);
    _subscribeToTopic("Project/PumpState");
    _subscribeToTopic("Project/Light");
    _subscribeToTopic("Project/DHT11/Hum");
    _subscribeToTopic("Project/DHT11/Temp");
    _subscribeToTopic("Project/SoilHum");
    _subscribeToTopic("Project/ControlState");
    _subscribeToTopic("control");
    _subscribeToTopic("hum");
    _subscribeToTopic("temp");

  }

  void _disconnect() {
    client.disconnect();
    _onDisconnected();
  }

  void _onDisconnected() {
    setState(() {
      topics.clear();
      connectionState = client.connectionState;
      client = null;
      subscription.cancel();
      subscription = null;
    });
    print('MQTT client disconnected');
  }

  void _onMessage(List<mqtt.MqttReceivedMessage> event) {
    final mqtt.MqttPublishMessage recMess =
    event[0].payload as mqtt.MqttPublishMessage;
    final String message =
    mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    // if(event[0].topic == 'Project/DHT11/Temp'){
    if(event[0].topic == 'Project/DHT11/Temp'){
      setState(() {
      _temp = double.parse(message);
      });
    }

    // if(event[0].topic == 'Project/DHT11/Hum'){
    if(event[0].topic == 'Project/DHT11/Hum'){
      setState(() {
      _hum = double.parse(message);
      });
    }

    if(event[0].topic == 'Project/PumpState'){
      setState(() {
      // _control = double.parse(message);
      _control = message;
      });
    }

    if(event[0].topic == 'Project/SoilHum'){
      setState(() {
      _soilhum = message;
      });
    }

    // if(event[0].topic == 'Project/ControlState'){
    //   setState(() {
    //   _state = message;
    //   });
    // }

    // if(event[0].topic == 'Project/Light'){
    //   setState(() {
    //   _light = double.parse(message);
    //   });
    // }

    // if(event[0].topic == 'control'){
    //   setState(() {
    //   _control = double.parse(message);
    //   });
    // }

    // setState(() {
    //   _temp = double.parse(message);
    // });


    // print(event.length);
    // final mqtt.MqttPublishMessage recMess =
    //     event[0].payload as mqtt.MqttPublishMessage;
    // final String message =
    //     mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    // /// The above may seem a little convoluted for users only interested in the
    // /// payload, some users however may be interested in the received publish message,
    // /// lets not constrain ourselves yet until the package has been in the wild
    // /// for a while.
    // /// The payload is a byte buffer, this will be specific to the topic
    // print('MQTT message: topic is <${event[0].topic}>, '
    //     'payload is <-- ${message} -->');
    // print(client.connectionState);
    // setState(() {
    //   messages.add(Message(
    //     topic: event[0].topic,
    //     message: message,
    //     qos: recMess.payload.header.qos,
    //   ));
    //   try {
    //     messageController.animateTo(
    //       0.0,
    //       duration: Duration(milliseconds: 400),
    //       curve: Curves.easeOut,
    //     );
    //   } catch (_) {
    //     // ScrollController not attached to any scroll views.
    //   }
    // });
  }

  void _subscribeToTopic(String topic) {
    if (connectionState == mqtt.MqttConnectionState.connected) {
      setState(() {
        if (topics.add(topic.trim())) {
          print('Subscribing to ${topic.trim()}');
          client.subscribe(topic, mqtt.MqttQos.exactlyOnce);
        }
      });
    }
  }

  void _unsubscribeFromTopic(String topic) {
    if (connectionState == mqtt.MqttConnectionState.connected) {
      setState(() {
        if (topics.remove(topic.trim())) {
          print('Unsubscribing from ${topic.trim()}');
          client.unsubscribe(topic);
        }
      });
    }
  }

    void _sendMessage() {
    final mqtt.MqttClientPayloadBuilder builder =
        mqtt.MqttClientPayloadBuilder();

    // if (_control == 'ON'){
    //   _messageContent = '0';
    //   setState(() {
    //   _control = 'OFF';
    //   });
    // }
    // else {
    //   _messageContent = '1';
    //   setState(() {
    //   _control = 'ON';
    //   });
    // }

    builder.addString(_messageContent);
    client.publishMessage(
      _topicContent,
      mqtt.MqttQos.exactlyOnce,//values[_qosValue],
      builder.payload,
      // retain: _retainValue,
    );

  }
}






 