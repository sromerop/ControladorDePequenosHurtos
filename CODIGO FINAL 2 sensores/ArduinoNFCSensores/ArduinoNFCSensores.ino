#include <SPI.h>
#include <MFRC522.h>

#include <TimerOne.h>

#define RST_PIN  9    //Pin 9 para el reset del RC522
#define SS_PIN  10   //Pin 10 para el SS (SDA) del RC522
MFRC522 mfrc522(SS_PIN, RST_PIN); ///Creamos el objeto para el RC522

const int sensor1Pin = A0;   // seleccionar la entrada para el sensor 1
int sensor1Value = 0;         // variable que almacena el valor raw (0 a 1023)
int sensor1ValueRef = 0;
int pesoRetirado1 = 0;
const int sensor2Pin = A1;   // seleccionar la entrada para el sensor 2
int sensor2Value = 0;         // variable que almacena el valor raw (0 a 1023)
int sensor2ValueRef = 0;
int pesoRetirado2 = 0;

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
  sensor1Value = analogRead(sensor1Pin);  // realizar la lectura
  sensor2Value = analogRead(sensor2Pin);  // realizar la lectura
    
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
      //delay(1000);    
    }
  }
  //if(sensor1Value != sensor1ValueRef || sensor2Value != sensor2ValueRef)
  if((abs(sensor1Value - sensor1ValueRef) > 20) || (abs(sensor2Value - sensor2ValueRef) > 20))
  {
    compruebaTarjeta();
    if(sensor2Value != sensor2ValueRef)
    {
      pesoRetirado2 = sensor2Value - sensor2ValueRef;
      if(tarjetaAnt != tarjeta)
      {
        Serial.print(", ZONA 2, ");
        Serial.println(pesoRetirado2);
        //Timer1.initialize(1000000); //10s
      }
      tarjetaAnt = tarjeta;
      sensor2ValueRef = sensor2Value;
    }    
    if(sensor1Value != sensor1ValueRef)
    {
      pesoRetirado1 = sensor1Value - sensor1ValueRef;
      if(tarjetaAnt != tarjeta)
      {
        Serial.print(", ZONA 1, ");
        Serial.println(pesoRetirado1);
        //Timer1.initialize(1000000); //10s
      }
      tarjetaAnt = tarjeta;
      sensor1ValueRef = sensor1Value;
    }
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
