#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include "DHT.h"

#define DHTTYPE DHT11   // DHT 11
#define DHTPIN 0     // DATA connects to D3
#define SOIL_MOIST_A_PIN A0 //PE4 connects to soil moisture sensor
#define SOIL_MOIST_D_PIN 4 // D2
#define T_RELAY_PIN 13 // Relay to D7

 //Network setting
const char* ssid      = "Luong"; //YourNetworkName
const char* password  =  "30041989"; //

 //MQTT setting
const char* mqttServer    = "soldier.cloudmqtt.com";
const int   mqttPort      = 10775;
const char* mqttUser      = "odgbcjgh";
const char* mqttPassword  = "eRbn2-b8D7br";
const char* mqttClientID  = "ESP8266Client";

//int light = 14;                      // Light connects to GPIO14 (D5)
//int pump = 13;                      // Pump connects to GPIO13 (D7) 
char messageBuff[100];             // Save message
char controlBuff[100]; 
String message;
String limit = "80";

WiFiClient espClient;
PubSubClient client(espClient);

 // Values of DHT11
float humDHT = 0.0;
float tempDHT = 0.0;

 // Initialize DHT11
DHT dht(DHTPIN, DHTTYPE);

 // Soil Moisture Sensor
int const TIME_TO_GET_SAMPLE = 5000; //5s
int const SAMPLE_TIME = 500; //0.5 s
int  TREE_WATER_LEVEL = 50;
int sensorMHValue = 0;//store sensor value
float moistSOIL = 0.0;
int bumpStatus = 0;
int waterStatus = 0;// -1: less water, 0: enough water,  +1 : more water

void setup() 
{

 //Check the WiFi connection
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
     delay(500);
    //Serial.println("Connecting to WiFi..");
  }
  //Serial.println("Connected to the WiFi network");

 //Set Server MQTT
  client.setServer(mqttServer, mqttPort);
  client.setCallback(callback);

 //Connect to the cloudMQTT server
  while (!client.connected())
  {
    //Serial.println("Connecting to MQTT...");
    if (client.connect(mqttClientID, mqttUser, mqttPassword )) 
    {
      //Serial.println("Connected");  
    } 
    else 
    {
      //Serial.print("Failed with state: ");
      //Serial.println(client.state());
      delay(2000);
    }
   }
  //delay(2000);

 //Publish and Subscribe a message on topic 
  client.subscribe("Project/Light");
  client.subscribe("Project/Pump");
  client.subscribe("Project/SoilHum");
  client.subscribe("Project/Control");
  client.subscribe("Project/Limit");

  dht.begin();    // Start reading DHT11

  pinMode(T_RELAY_PIN, OUTPUT); // Start Pump
  digitalWrite(T_RELAY_PIN, LOW);
}

void callback(char* topic, byte* payload, unsigned int length) {
  if (strcmp(topic,"Project/Control")==0){
  //client.publish("Project/ControlState", "M");
  int i;
  for (i = 0; i < length; i++) {
    messageBuff[i] = (char)payload[i];
  }
  messageBuff[i] = '\0';
  message = String(messageBuff);
  }

  if (strcmp(topic,"Project/Limit")==0){
  //client.publish("Project/ControlState", "M");
  int i;
  for (i = 0; i < length; i++) {
    messageBuff[i] = (char)payload[i];
  }
  messageBuff[i] = '\0';
  limit = String(messageBuff);
  }
  
  if (strcmp(topic,"Project/Pump")==0){
  int i;
  for (i = 0; i < length; i++) {
    messageBuff[i] = (char)payload[i];
  }
  messageBuff[i] = '\0';
  String message = String(messageBuff);
  if (message == "ON") {
    digitalWrite(T_RELAY_PIN, HIGH);           // Turn PUMP on when receive message "on"
    client.publish("Project/PumpState", "ON"); 
  } 
  else if (message == "OFF") {                  // Turn PUMP on when receive message "off"
    digitalWrite(T_RELAY_PIN, LOW);
    client.publish("Project/PumpState", "OFF");  
  } 
  }
}

void wateringProcess(){
  int i = 0;
  moistSOIL = 0;
  for (i = 0; i < 10; i++)  //
  {
    moistSOIL += analogRead(SOIL_MOIST_A_PIN); //Đọc giá trị cảm biến độ ẩm đất
    delay(50);   // Đợi đọc giá trị ADC
  }
  moistSOIL = moistSOIL / (i);
  moistSOIL = map(moistSOIL, 1023, 0, 0, 100); //Ít nước:0%  ==> Nhiều nước
  
  
    if(moistSOIL < limit.toInt()){
      digitalWrite(T_RELAY_PIN, HIGH);
      bumpStatus = 1;
      waterStatus = -1;
      client.publish("Project/PumpState", "ON");
    }
    else{
      digitalWrite(T_RELAY_PIN, LOW);
      bumpStatus = 0;
      waterStatus = +1;
      client.publish("Project/PumpState", "OFF");
    }
}


void loop() {
  if (message == "A"){
    client.publish("Project/ControlState", "A");
    wateringProcess();
    }
  //wateringProcess(); // process and checking to watering
  tempDHT = dht.readTemperature();
  Serial.print(limit);
  client.publish("Project/SoilHum" , String(limit).c_str(), true);
  Serial.print("Measured Temperature: "); 
  Serial.print(tempDHT);
  Serial.println("°C");
  client.publish("Project/DHT11/Temp" , String(tempDHT).c_str(), true);
  Serial.print("Soil Moisture: ");
  Serial.print(moistSOIL);
  Serial.println("%");
  client.publish("Project/DHT11/Hum" , String(moistSOIL).c_str(), true);
//  client.publish("Project/SoilHum" , String(moistSOIL).c_str(), true);
  Serial.println();
  client.loop();
  delay(2000);
}
