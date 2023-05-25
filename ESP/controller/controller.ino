#include <ESP8266WiFi.h>
#include <PubSubClient.h>

// Pin definitions
#define PIN_LED_RED     14
#define PIN_LED_YELLOW  13
#define PIN_LED_GREEN   12
#define PIN_BUTTON      4

#define DEBOUNCE_TIME 2000 // milliseconds
volatile int button_a_count;
volatile unsigned long count_prev_time;

// Variable to hold PICO_ID
int PICO_ID = 1; // change as needed

// Define your moistureThreshold
int moistureThreshold = 30; // change as needed

// Update these with values suitable for your network.
const char* ssid = "EMLI_TEAM_04";
const char* password = "kakskaks";
const char* mqtt_server = "broker.hivemq.com";

// MQTT topics
#define TOPIC_PLANT_WATER_ALARM "/kaks/plant_water_alarm"
#define TOPIC_PUMP_WATER_ALARM "/kaks/pump_water_alarm"
#define TOPIC_MOISTURE "/kaks/moisture"
#define TOPIC_LIGHT "/kaks/light"
#define TOPIC_START_PUMP "/kaks/start_pump"

WiFiClient espClient;
PubSubClient client(espClient);
unsigned long lastMsg = 0;
#define MSG_BUFFER_SIZE	(50)
char msg[MSG_BUFFER_SIZE];
int value = 0;

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

void setup_wifi() {

  delay(10);
  // We start by connecting to a WiFi network
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  randomSeed(micros());

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

bool plant_water_alarm = false;
bool pump_water_alarm = false;
bool moisture_low = false;
bool DEBUG = false;

void callback(char* topic, byte* payload, unsigned int length) {
  payload[length] = '\0'; 
  String strPayload = String((char*)payload); // convert byte* to string

  // split payload into ID and Value
  int commaIndex = strPayload.indexOf(',');
  String strID = strPayload.substring(0, commaIndex);
  String strValue = strPayload.substring(commaIndex+1);

  // convert ID and Value to integer
  int id = strID.toInt();
  int value = strValue.toInt();
  if (DEBUG) {
    Serial.print("[" + String(topic) + "] " + id + ", " + value + "\n");
  }

  // initially turn off all LEDs
  digitalWrite(PIN_LED_RED, LOW);
  digitalWrite(PIN_LED_YELLOW, LOW);
  digitalWrite(PIN_LED_GREEN, LOW);

  if (id == PICO_ID) {
    if (String(topic) == TOPIC_PLANT_WATER_ALARM) {
      plant_water_alarm = (value == 1);
    } else if (String(topic) == TOPIC_PUMP_WATER_ALARM) {
      pump_water_alarm = (value == 1);
    } else if (String(topic) == TOPIC_MOISTURE) {
      moisture_low = (value < moistureThreshold);
    }
  }
}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Create a random client ID
    String clientId = "ESP8266Client-";
    clientId += String(random(0xffff), HEX);
    // Attempt to connect
    if (client.connect(clientId.c_str())) {
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

void setup() {

  Serial.begin(115200);
  while (!Serial);

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

  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
}

void loop() {

  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  // Turn off all LEDs initially
  digitalWrite(PIN_LED_RED, LOW);
  digitalWrite(PIN_LED_YELLOW, LOW);
  digitalWrite(PIN_LED_GREEN, LOW);

  // Check for conditions and light the LED accordingly
  if (plant_water_alarm || pump_water_alarm) {
    digitalWrite(PIN_LED_RED, HIGH);
  } else if (moisture_low) {
    digitalWrite(PIN_LED_YELLOW, HIGH);
  } else {
    digitalWrite(PIN_LED_GREEN, HIGH);
  }
}
