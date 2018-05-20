#include <SPI.h>
#include <MFRC522.h>

#include <TimerOne.h>

#define RST_PIN  9    //Pin 9 para el reset del RC522
#define SS_PIN  10   //Pin 10 para el SS (SDA) del RC522
MFRC522 mfrc522(SS_PIN, RST_PIN); ///Creamos el objeto para el RC522

const int sensorPin = A1;   // seleccionar la entrada para el sensor
int sensorValue = 0;         // variable que almacena el valor raw (0 a 1023)
int sensorValueRef = 0;
int pesoRetirado = 0;
int tarjeta = 0;  //0=robo, 1=tarjeta
int tarjetaAnt = 2;

const int ledPin = 8;   // seleccionar la salida para el led
 
void setup() 
{
  Serial.begin(9600); //Iniciamos La comunicacion serial
  SPI.begin();        //Iniciamos el Bus SPI
  mfrc522.PCD_Init(); // Iniciamos el MFRC522
  Timer1.attachInterrupt(quitaTarjeta); // Activa la interrupcion y la asocia a quitaTarjeta
  pinMode(ledPin , OUTPUT);  //definir pin como salida
}

void loop()
{
  sensorValue = analogRead(sensorPin);  // realizar la lectura
    
  // Revisamos si hay nuevas tarjetas  presentes
  if ( mfrc522.PICC_IsNewCardPresent()) 
  {  
    //Seleccionamos una tarjeta
    if ( mfrc522.PICC_ReadCardSerial()) 
    {
      // Enviamos serialemente su UID
      for (byte i = 0; i < mfrc522.uid.size; i++) {
        Serial.print(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " ");
        Serial.print(mfrc522.uid.uidByte[i], HEX);         
      }
      tarjeta = 1;
      Timer1.initialize(5000000); //10s
      noTone(7);
      digitalWrite(ledPin, HIGH);
      mfrc522.PICC_HaltA();
    }
  }
  //if(sensorValue != sensorValueRef)
  if(abs(sensorValue - sensorValueRef) > 5)
  {
    compruebaTarjeta();
    pesoRetirado = sensorValue - sensorValueRef;
    if(tarjetaAnt != tarjeta)
    {
      Serial.print(", "); 
      Serial.println(pesoRetirado);
      //Timer1.initialize(1000000); //10s
    }
    tarjetaAnt = tarjeta;
    sensorValueRef = sensorValue;
    //delay(1000);
  }
}

void compruebaTarjeta()
{ 
  if (tarjeta == 0)
  {
    tone(7, 370);
    digitalWrite(ledPin, LOW);
    if (tarjetaAnt != tarjeta)
    {    
      Serial.print(" ROBO");
    }
  }
}

void quitaTarjeta()
{
  tarjeta = 0;
  tarjetaAnt = 2;
  digitalWrite(ledPin, LOW);
}
