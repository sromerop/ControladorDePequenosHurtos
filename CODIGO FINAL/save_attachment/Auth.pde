import javax.mail.Authenticator;
import javax.mail.PasswordAuthentication;

public class Auth extends Authenticator {

  public Auth() {
    super();
  }

  public PasswordAuthentication getPasswordAuthentication() {
    String username, password;
    //username = "username@gmail.com";  //jefempresaelco@gmail.com, elcobot2018@gmail.com
    username = "elcobot2018@gmail.com";
    //password = "password";  //ELCO2018 
    password = "ELCO2018";
    System.out.println("authenticating. . .");
    return new PasswordAuthentication(username, password);
  }
}
