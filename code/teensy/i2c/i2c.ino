#include <Wire.h>


void setup() 
{
  pinMode(16, OUTPUT);

  Wire.begin();
  Serial.begin(9600);

  Wire.beginTransmission(0x42);
  Wire.write(0x63);
  Wire.endTransmission();

  delayMicroseconds(100);

  digitalWrite(16, HIGH);
  delayMicroseconds(10);
  digitalWrite(16, LOW);
  delayMicroseconds(10);

  Wire.beginTransmission(0x42);
  Wire.write(0x63);
  Wire.endTransmission();
}

void loop() 
{
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