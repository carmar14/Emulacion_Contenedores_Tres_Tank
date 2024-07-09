#include <WiFi.h>
#include <WiFiUdp.h>

// Configuración WiFi
const char* ssid = "your_SSID";
const char* password = "your_PASSWORD";
WiFiUDP Udp;
unsigned int localPort = 8888;
const char* controlCenterIP = "192.168.1.100"; // IP del centro de control
const unsigned int controlCenterPort = 8889;

// Pines de entrada y salida
const int entrada1Pin = 34; // GPIO34 (ADC1)
const int entrada2Pin = 35; // GPIO35 (ADC1)
const int salidaPin = 25;   // GPIO25 (DAC1)

// Variables de estado
float x1 = 0; // Estado del tanque 1 recibido
float x2 = 0; // Estado del tanque 2 
float x3 = 0; // Estado del tanque 3 recibido
float u1 = 0;
float u2 = 0;

// Acciones de control previas
float ai1_k1 = 0;
float ai2_k1 = 0;

// Puntos de consigna
float q1 = 0.4;
float q2 = 0.2;

// Matrices del sistema
const float a21 = 0.0001, a22 = 0.9781, a23 = 0.0111;
const float b21 = 0.0014 , b22 = 64.2202;

// Matrices del controlador
float K1[2][3] = {
  {0.0216, 0.0030, -0.0050},
  {0.0029, 0.0190, -0.0040}
};

float K2[2][2] = {
  {-0.9500e-03, -0.3200e-03},
  {-0.3000e-03, -0.9100e-03}
};

// Variables UDP
char incomingPacket[255];  // buffer for incoming packets


void controlador(float* u, float* ai1, float* ai2, float x1, float x2, float x3, float q1, float q2, float ai1_k1, float ai2_k1) {
  float q_max = 0.0015;
  float q_min = 0;

  // Vector de estado
  float x[3] = {x1, x2, x3};

  // Calculo el error
  float e1 = q1 - x[0];
  float e2 = q2 - x[1];

  // Calculo la accion de control u1 y u2
  *ai1 = e1 + ai1_k1;
  *ai2 = e2 + ai2_k1;
  float ui1 = K2[0][0] * (*ai1) + K2[0][1] * (*ai2);
  float ui2 = K2[1][0] * (*ai1) + K2[1][1] * (*ai2);
  ui1 = -ui1; // accion integral
  ui2 = -ui2; // accion integral

  float up1 = K1[0][0] * x[0] + K1[0][1] * x[1] + K1[0][2] * x[2];
  float up2 = K1[1][0] * x[0] + K1[1][1] * x[1] + K1[1][2] * x[2];
  up1 = -up1; // accion propocional
  up2 = -up2; // accion propocional

  float u1 = ui1 + up1; // accion de control
  float u2 = ui2 + up2; // accion de control

  // Saturacion para evitar daños en los actuadores
  if (u1 > q_max) {
    u1 = q_max;
  }

  if (u2 > q_max) {
    u2 = q_max;
  }

  if (u1 < q_min) {
    u1 = q_min;
  }

  if (u2 < q_min) {
    u2 = q_min;
  }

  u[0] = u1;
  u[1] = u2;
}


void setup(){
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
  // Leer entradas-----algoritmo de control
  
  //u1 = analogRead(entrada1Pin) * 3.3 / 4095.0;
  //u2 = analogRead(entrada2Pin) * 3.3 / 4095.0;

  // Leer estados de los otros ESP32
  x1 = analogRead(32) * 3.3 / 4095.0; // GPIO32 (ADC1)
  x3 = analogRead(33) * 3.3 / 4095.0; // GPIO33 (ADC1)

  // Actualizar estado x2
  x2 = a21 * x1 + a22 * x2 + a23 * x3 + b21 * u1 + b22 * u2;

  // Calcular la acción de control
  float u[2];
  float ai1, ai2;
  controlador(u, &ai1, &ai2, x1, x2, x3, q1, q2, ai1_k1, ai2_k1);
  u1 = u[0];
  u2 = u[1];

  // Actualizar las acciones de control previas
  ai1_k1 = ai1;
  ai2_k1 = ai2;

  /*
  // Recibir estados de los otros ESP32
  int packetSize = Udp.parsePacket();
  if (packetSize) {
    int len = Udp.read(incomingPacket, 255);
    if (len > 0) {
      incomingPacket[len] = 0;
    }
    sscanf(incomingPacket, "x1:%f x3:%f", &x1, &x3);
  }

  // Actualizar estado x2
  x2 = a21 * x1 + a22 * x2 + a23 * x3 + b21 * u1 + b22 * u2;
  */
  
  Serial.print("Estado x2: ");
  Serial.println(x2);

  // Enviar el estado x2 a través del DAC
  dacWrite(salidaPin, x2 * 255 / 3.3); // Convertir x2 a un valor de 0-255 para el DAC

  // Enviar el estado y acciones de control al centro de control
  char buffer[100];
  int buffer_length = sprintf(buffer, "x2:%f,u1:%f,u2:%f", x2, u1, u2);
  Udp.beginPacket(controlCenterIP, controlCenterPort);
  Udp.write((uint8_t*)buffer, buffer_length);
  Udp.endPacket();

  delay(1000);
}
