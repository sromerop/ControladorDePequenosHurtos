import com.sun.mail.pop3.*;
import com.sun.mail.util.*;
import com.sun.mail.util.logging.*;
import com.sun.mail.handlers.*;
import com.sun.mail.iap.*;
import com.sun.mail.auth.*;
import com.sun.mail.imap.*;
import com.sun.mail.imap.protocol.*;
import com.sun.mail.smtp.*;
import javax.mail.*;
import javax.mail.util.*;
import javax.mail.search.*;
import javax.mail.event.*;
import javax.mail.internet.*;

import processing.sound.*;

import javax.mail.*;
import javax.mail.internet.*;

import processing.serial.*;

import java.io.*;
import org.apache.poi.ss.usermodel.Sheet;

import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;

Serial myPort;  // Create object from Serial class
String lectura;     // Data received from the serial port
String nuevoLect;
String ide;
String zona;

String[][] saving;
int indiceColumnaID;
int indiceColumnaApellidos;
int indiceColumnaNombre;
int indiceColumnaPermiso1;
int indiceColumnaPermiso2;
int indiceColumnaPermiso;
int indiceFilaCabeceras;
int indiceFilaID;

SoundFile file;
PFont f1;
PFont f2;
int cuenta;
int email;
int emailDesc;

PrintWriter output;  //Para crear el archivo de texto donde guardar los datos 

void setup() {
  // I know that the first port in the serial list on my mac
  // is Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 9600);
  
  // import excel data to a 2d string:
  //saving = importExcel("PLACE FILEPATH & FILE NAME HERE");
  saving = importExcel("C:/Users/srome/Desktop/ETSIT/ELCO/CODIGO FINAL 2 sensores/BBDD.xlsm");
  
  // search for table headers
  for(int j=0; j<saving.length; j++){  //filas
    for(int i=0; i<saving[j].length; i++){  //columnas
      if(("ID").equals(saving[j][i])){
        indiceColumnaID = i;
        indiceFilaCabeceras = j;
        println("indiceFilaCabeceras = " + indiceFilaCabeceras);
        println("indiceColumnaID = " + indiceColumnaID);
      }
      if(("Apellidos").equals(saving[j][i])){
        indiceColumnaApellidos = i;
        println("indiceColumnaApellidos = " + indiceColumnaApellidos);
      }
      if(("Nombre").equals(saving[j][i])){
        indiceColumnaNombre = i;
        println("indiceColumnaNombre = " + indiceColumnaNombre);
      }
      if(("Zona 1").equals(saving[j][i])){
        indiceColumnaPermiso1 = i;
        println("indiceColumnaPermiso1 = " + indiceColumnaPermiso1);
      }
      if(("Zona 2").equals(saving[j][i])){
        indiceColumnaPermiso2 = i;
        println("indiceColumnaPermiso2 = " + indiceColumnaPermiso2);
      }
    }
  }
  
  String[] lines = loadStrings("lectura_datos.txt");
  output = createWriter("lectura_datos.txt"); //Creamos el archivo de texto, que es guardado en la carpeta del programa
  
  if(lines.length == 0){
  } else {
    for (int i = 0 ; i < lines.length; i++) {
    output.println(lines[i]);
    }
  }
  
  size(1000, 600);
  f1 = loadFont("Stencil-48.vlw");
  f2 = loadFont("MicrosoftYaHeiUI-Bold-48.vlw");
  file = new SoundFile(this, "sound.mp3");
}

void draw() {
  
  if(myPort.available() > 0){  // Si hay datos disponibles,
    lectura = myPort.readStringUntil('\n');    // se leen y se guardan
    indiceFilaID = 0;
    indiceColumnaPermiso = 0;
    nuevoLect = null;
    ide = null;
    zona = null;
    email = 0;
    emailDesc = 0;
  } else {
    background(255, 255, 255);  // blanco, 255-255-255
    textFont(f2,50);
    textAlign(CENTER);
    fill(0);
    text("SIN INCIDENTES", width/2, height/2);    
  }
  
  if(lectura != null){
    nuevoLect = lectura.substring(1, (lectura.length() - 2));  // El dato leído empieza con un espacio y termina en \n
    int coma = nuevoLect.indexOf(',');
    ide = nuevoLect.substring(0, coma);
    String resto = nuevoLect.substring((coma + 2), nuevoLect.length());
    coma = resto.indexOf(',');
    zona = resto.substring(0, coma);
    if(zona.equals("ZONA 1")){
      indiceColumnaPermiso = indiceColumnaPermiso1;
    } else if(zona.equals("ZONA 2")){
      indiceColumnaPermiso = indiceColumnaPermiso2;
    }
    println("indiceColumnaPermiso = " + indiceColumnaPermiso);
    for(int j = indiceFilaCabeceras; j < saving.length; j++){  //filas
      for(int i = indiceColumnaID; i < saving[j].length; i++){  //columnas
        if(ide.equals(saving[j][i])){  // Busca si el ID leído coincide con alguno de la tabla
          indiceFilaID = j;
          println("indiceFilaID = " + indiceFilaID);
        }   
      }
    }
    lectura = null;
    Date date = new Date();
    DateFormat hourdateFormat = new SimpleDateFormat("dd/MM/yyyy, HH:mm:ss");
    output.println(nuevoLect + ", " + hourdateFormat.format(date));
    println("Escrito");
   }

  if((nuevoLect != null) && !ide.equals("ROBO") && ("No").equals(saving[indiceFilaID][indiceColumnaPermiso])){  //Si no tiene permiso, se envía un correo con sus datos
    if(email == 0){
      sendMail(ide, saving[indiceFilaID][indiceColumnaApellidos], saving[indiceFilaID][indiceColumnaNombre], zona);
      email = 1;      
      println("Finished NO PERMISO");
    }
    background(255, 255, 255);  // blanco, 255-255-255
    textFont(f2,50);
    textAlign(CENTER);
    fill(0);
    text("ATENCIÓN: TIENE UN NUEVO EMAIL", width/2, height/2);    
  }
  if((nuevoLect != null) && !ide.equals("ROBO") && indiceFilaID == 0){
    if(emailDesc == 0){
      sendMailDesconocido(ide, zona);
      emailDesc = 1;
      println("Finished TARJETA EXTRAÑA");
    } 
    background(255, 255, 0);  // amarillo, 255-255-0
    textFont(f2,50);
    textAlign(CENTER);
    fill(0); 
    text("ATENCIÓN:", width/2, height/2 - 80);
    text("TARJETA NO IDENTIFICADA", width/2, height/2 - 20);
    text("ID = " + ide, width/2, height/2 + 80);
    text("EN LA " + zona, width/2, height/2 + 140);
  }
  if((nuevoLect != null) && ide.equals("ROBO")){  // Si hay un robo, lo saca en la pantalla
    robo();
  }
  if((nuevoLect != null) && !ide.equals("ROBO")){  // Deja de haber robo, para de sonar
    file.stop();
  }
  if((nuevoLect != null) && !ide.equals("ROBO") && ("Sí").equals(saving[indiceFilaID][indiceColumnaPermiso])){  //Si tiene permiso, sin incidentes
    background(255, 255, 255);  // blanco, 255-255-255
    textFont(f2,50);
    textAlign(CENTER);
    fill(0);
    text("SIN INCIDENTES", width/2, height/2);    
  }  
}

void keyPressed() //Cuando se pulsa una tecla
{
  if(key=='c'){
    output.flush(); // Escribe los datos restantes en el archivo
    output.close(); // Final del archivo
    exit();  // Salimos del programa
  }
}

void robo(){ 
  if(cuenta > 15 && cuenta < 31){
    background(16, 44, 84);  // azul, 016-044-084
  } else {
    background(204, 6, 5);  // rojo, 204-006-005
  }
  cuenta++;
  if(cuenta > 31){
    cuenta = 0;
  }
  textFont(f1,50);
  textAlign(CENTER);
  fill(255);
  text("ATENCIÓN: SE ESTÁ PRODUCIENDO", width/2, height/2 - 30);
  text("UN ROBO EN ESTOS MOMENTOS", width/2, height/2 + 30);
  text("EN LA " + zona, width/2, height/2 + 90);
  if(file.isPlaying() == 0){
    file.play();
    file.amp(5);
  }
}
