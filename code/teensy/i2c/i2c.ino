#include <Wire.h>


void setup() {
  pinMode(16, OUTPUT);

  Wire.begin();
  Serial.begin(9600);
  while (!Serial) { ; }

  // Wire.beginTransmission(0x42);
  // Wire.write(0x63);
  // Wire.endTransmission();

  // delayMicroseconds(100);

  startI2CTransaction();
  Wire.beginTransmission(0x42);
  Wire.write(0x12);
  Wire.endTransmission();

  delayMicroseconds(100);

  startI2CTransaction();
  Wire.requestFrom(0x42, 1);
  // if (Wire.available()) {
    char c = Wire.read();
    Serial.println("Recieved");
    // Serial.println(c, HEX);
    Serial.println(c, BIN);
  // }

  // for (int i = 0; i < 255; i++) {

  //   startI2CTransaction();
  //   Wire.beginTransmission(0x42);
  //   Wire.write(i);
  //   Wire.endTransmission();

  //   delayMicroseconds(100);

  //   startI2CTransaction();
  //   Wire.requestFrom(0x42, 1);
  //   if (Wire.available()) {
  //     char c = Wire.read();
  //     Serial.println(c, BIN);
  //   }
  //   delayMicroseconds(100);
  // }
}

void loop() {
  // Wire.beginTransmission(0x42);
  // Wire.write(0x63);
  // Wire.endTransmission();

  // delayMicroseconds(200);

  // Wire.requestFrom(0x42, 1);
  // if(Wire.available()) {	      // read response from slave 0x08
  // 	Wire.read();
  // }

  // delayMicroseconds(10);
}

void startI2CTransaction() {
  digitalWrite(16, HIGH);
  delayMicroseconds(2);
  digitalWrite(16, LOW);
}