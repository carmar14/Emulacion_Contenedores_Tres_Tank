#include <WiFi.h>
#include <WiFiUdp.h>

// Configuración WiFi
const char* ssid = "your_SSID";
const char* password = "your_PASSWORD";
WiFiUDP Udp;
unsigned int localPort = 8888;

// Pines de entrada
const int entrada1Pin = 34; // GPIO34 (ADC1)
const int entrada2Pin = 35; // GPIO35 (ADC1)

// Variables de estado
float x1 = 0; // Estado del tanque 1
float x2 = 0; // Estado del tanque 2 recibido
float x3 = 0; // Estado del tanque 3 recibido
float u1 = 0;
float u2 = 0;

// Matrices del sistema
const float a11 = 0.9888, a12 = 0.0001, a13 = 0.0112;
const float b11 = 64.5687 , b12 = 0.0014;

// Variables UDP
char incomingPacket[255];  // buffer for incoming packets

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");

  Udp.begin(localPort);
}

void loop() {
  // Leer entradas
  u1 = analogRead(entrada1Pin) * 3.3 / 4095.0;
  u2 = analogRead(entrada2Pin) * 3.3 / 4095.0;

  // Recibir estados de los otros ESP32
  int packetSize = Udp.parsePacket();
  if (packetSize) {
    int len = Udp.read(incomingPacket, 255);
    if (len > 0) {
      incomingPacket[len] = 0;
    }
    sscanf(incomingPacket, "x2:%f x3:%f", &x2, &x3);
  }

  // Actualizar estado x1
  x1 = a11 * x1 + a12 * x2 + a13 * x3 + b11 * u1 + b12 * u2;

  Serial.print("Estado x1: ");
  Serial.println(x1);

  // Enviar el estado x1
  char buffer[50];
  sprintf(buffer, "x1:%f", x1);
  Udp.beginPacket("192.168.1.101", 8888); // IP del ESP32 2
  Udp.write(buffer);
  Udp.endPacket();

  delay(1000);
}
