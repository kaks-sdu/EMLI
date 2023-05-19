// Additional MQTT libraries
#include <PubSubClient.h>
#include <ESP8266WiFi.h>
#include <WiFiClient.h>

// Pin definitions
#define PIN_LED_RED     14
#define PIN_LED_YELLOW  13
#define PIN_LED_GREEN   12
#define PIN_BUTTON      4
#define DEBOUNCE_TIME 200 // milliseconds
volatile int button_a_count;
volatile unsigned long count_prev_time;

// WiFi details
const char* WIFI_SSID = "EMLI_TEAM_04";
const char* WIFI_PASSWORD = "kakskaks";
IPAddress IPaddress(192, 168, 0, 222);
IPAddress gateway(192, 168, 0, 1);
IPAddress subnet(255, 255, 255, 0);

// MQTT broker settings
const char* mqttServer = "your_mqtt_broker_ip";
int mqttPort = 1883; // default MQTT port
const char* mqttUser = "your_mqtt_username";
const char* mqttPassword = "your_mqtt_password";

// MQTT topics
#define TOPIC_PLANT_WATER_ALARM "/kaks/plant_water_alarm"
#define TOPIC_PUMP_WATER_ALARM "/kaks/pump_water_alarm"
#define TOPIC_MOISTURE "/kaks/moisture"
#define TOPIC_LIGHT "/kaks/light"
#define TOPIC_START_PUMP "/kaks/start_pump"

// MQTT Client setup
WiFiClient espClient;
PubSubClient client(espClient);

// Variable to hold PICO_ID
int PICO_ID = 1; // change as needed

// Define your moistureThreshold
int moistureThreshold = 500; // change as needed

void callback(char* topic, byte* payload, unsigned int length) {
  payload[length] = '\0'; 
  String strPayload = String((char*)payload); // convert byte* to string

  if (String(topic) == TOPIC_PLANT_WATER_ALARM) {
    if (strPayload.toInt() == 1) {
      digitalWrite(PIN_LED_RED, HIGH);
    } else {
      digitalWrite(PIN_LED_RED, LOW);
    }
  } else if (String(topic) == TOPIC_PUMP_WATER_ALARM) {
    if (strPayload.toInt() == 0) {
      digitalWrite(PIN_LED_RED, HIGH);
    } else {
      digitalWrite(PIN_LED_RED, LOW);
    }
  } else if (String(topic) == TOPIC_MOISTURE) {
    if (strPayload.toInt() < moistureThreshold) {
      digitalWrite(PIN_LED_YELLOW, HIGH);
    } else {
      digitalWrite(PIN_LED_YELLOW, LOW);
    }
  } else if (String(topic) == TOPIC_LIGHT) {
    digitalWrite(PIN_LED_GREEN, HIGH);
  }
}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Attempt to connect
    if (client.connect("ESP8266Client", mqttUser, mqttPassword )) {
      Serial.println("connected");  
      // Subscribe to topics
      client.subscribe(TOPIC_PLANT_WATER_ALARM);
      client.subscribe(TOPIC_PUMP_WATER_ALARM);
      client.subscribe(TOPIC_MOISTURE);
      client.subscribe(TOPIC_LIGHT);
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

ICACHE_RAM_ATTR void button_a_isr()
{
  if (millis() - count_prev_time > DEBOUNCE_TIME)
  {
    count_prev_time = millis();
    button_a_count++;
    char msg[50];
    snprintf(msg, 50, "%d", PICO_ID); // convert int to string
    client.publish(TOPIC_START_PUMP, msg);
  }
}

void setup()
{
// serial
  Serial.begin(115200);
  delay(10);

  // LEDs
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);
  pinMode(PIN_LED_RED, OUTPUT);
  digitalWrite(PIN_LED_RED, LOW);
  pinMode(PIN_LED_YELLOW, OUTPUT);
  digitalWrite(PIN_LED_YELLOW, LOW);
  pinMode(PIN_LED_GREEN, OUTPUT);
  digitalWrite(PIN_LED_GREEN, LOW);

  // button
  pinMode(PIN_BUTTON, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(PIN_BUTTON), button_a_isr, RISING);

  // set the ESP8266 to be a WiFi-client
  WiFi.mode(WIFI_STA); 
  
  // configure static IP address
  WiFi.config(IPaddress, gateway, subnet);
  //WiFi.config(IPaddress, gateway, subnet, primaryDNS, secondaryDNS);

  // connect to Wifi access point
  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(WIFI_SSID);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }
  digitalWrite(LED_BUILTIN, HIGH);
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.local)
  Serial.println("");

  // set MQTT server and callback
  client.setServer(mqttServer, mqttPort);
  client.setCallback(callback);
}

void loop()
{
  if (!client.connected()) {
    reconnect();
  }
  client.loop();  
}
