import java.util.*;
import javax.activation.*;

// A function to send mail
void sendMail(String ID, String Apellidos, String Nombre, String Zona) {
  // Create a session
  String host="smtp.gmail.com";
  Properties props=new Properties();

  // SMTP Session
  props.put("mail.transport.protocol", "smtp");
  props.put("mail.smtp.host", host);
  props.put("mail.smtp.port", "587");
  props.put("mail.smtp.auth", "true");
  // We need TTLS, which gmail requires
  props.put("mail.smtp.starttls.enable","true");
  props.put("mail.smtp.ssl.trust", "smtp.gmail.com");

  // Create a session
  Session session = Session.getDefaultInstance(props, new Auth());

  try {
    MimeMessage msg=new MimeMessage(session);
    msg.setFrom(new InternetAddress("elcobot2018@gmail.com", "BOT de ELCO"));
    msg.addRecipient(Message.RecipientType.TO,new InternetAddress("jefempresaelco@gmail.com"));
    msg.setSubject("Urgente: nuevo caso de uso de material sin permiso");
    BodyPart messageBodyPart = new MimeBodyPart();    
    // Fill the message
    messageBodyPart.setText("El empleado implicado es " + Apellidos + ", " + Nombre + " con ID: " + ID + ". El incidente se ha dado en la " + Zona + ".");
    Multipart multipart = new MimeMultipart();
    multipart.addBodyPart(messageBodyPart);
    msg.setContent(multipart);
    msg.setSentDate(new Date());
    Transport.send(msg);
    println("Mail sent!");
  } catch(Exception e) {
    e.printStackTrace();
  }
}

// A function to send mail
void sendMailDesconocido(String ID, String Zona) {
  // Create a session
  String host="smtp.gmail.com";
  Properties props=new Properties();

  // SMTP Session
  props.put("mail.transport.protocol", "smtp");
  props.put("mail.smtp.host", host);
  props.put("mail.smtp.port", "587");
  props.put("mail.smtp.auth", "true");
  // We need TTLS, which gmail requires
  props.put("mail.smtp.starttls.enable","true");
  props.put("mail.smtp.ssl.trust", "smtp.gmail.com");

  // Create a session
  Session session = Session.getDefaultInstance(props, new Auth());

  try {
    MimeMessage msg=new MimeMessage(session);
    msg.setFrom(new InternetAddress("elcobot2018@gmail.com", "BOT de ELCO"));
    msg.addRecipient(Message.RecipientType.TO,new InternetAddress("jefempresaelco@gmail.com"));
    msg.setSubject("Urgente: tarjeta desconocida");
    BodyPart messageBodyPart = new MimeBodyPart();    
    // Fill the message
    messageBodyPart.setText("Se ha detectado una tarjeta extraña, con ID: " + ID + ". El incidente se ha dado en la " + Zona + ".");
    Multipart multipart = new MimeMultipart();
    multipart.addBodyPart(messageBodyPart);
    msg.setContent(multipart);
    msg.setSentDate(new Date());
    Transport.send(msg);
    println("Mail sent!");
  } catch(Exception e) {
    e.printStackTrace();
  }
}
