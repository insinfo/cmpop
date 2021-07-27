import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EnviaEmail {
  EnviaEmail() {
    smtpServer = SmtpServer(
      'smtp.gmail.com',
      username: 'desenv.pmro@gmail.com',
      password: 'S15tem@5PMR0',
      port: 587,
    );
    message = Message();
  }
  SmtpServer smtpServer;
  Message message;

  void addFileData(Stream<List<int>> _stream, String contentType, {String fileName}) {
    final attachment = StreamAttachment(_stream, contentType, fileName: fileName);
    message.attachments.add(attachment);
  }

  String deEmail = 'desenv.pmro@gmail.com';
  String deNome = 'PORTAL cmpop';
  String paraEmail = '';
  String assunto = 'PORTAL cmpop ::';
  String html = '';

  void addDestinoEmail(String email) {
    message.recipients.add(email);
  }

  Future<SendReport> envia() async {
    message.from = Address(deEmail, deNome);
    message.recipients.add(paraEmail);
    message.subject = assunto; //'PORTAL cmpop :: FORMULÁRIO PARA ENTRADA DE EXCURSÃO';
    message.html = html;
    return await send(message, smtpServer);
  }
}
