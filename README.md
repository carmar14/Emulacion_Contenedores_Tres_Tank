Repositorio para el manejo del sistema de tres tanques

ESP32 1, 2 y 3:
Cada uno lee sus entradas y estados de los otros dos ESP32.
Calculan su propio estado y las acciones de control.
Envían su estado a través de su salida DAC.
Envían su estado y acciones de control al centro de control en el PC a través de UDP.

Centro de Control (PC):
Recibe los datos de los tres ESP32.
Muestra los datos en la consola.

Notas
Direcciones IP: Asegurarse de que las direcciones IP en el código UDP (en Udp.beginPacket(...)) correspondan a las direcciones IP asignadas a cada ESP32 en tu red.
Configuración de WiFi: Reemplaza your_SSID y your_PASSWORD con las credenciales de tu red WiFi.
