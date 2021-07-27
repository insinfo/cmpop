import 'package:angular/angular.dart';
import 'package:angular/security.dart';

@Pipe('safe')
class SafePipe implements PipeTransform {
  final DomSanitizationService sanitizer;

  SafePipe(this.sanitizer);

  SafeResourceUrl transform(url) {
    return sanitizer.bypassSecurityTrustResourceUrl(url);
  }

  /// Transform
  /// @param value: string
  /// @param type: string
  /*dynamic transform2(value, type) // SafeHtml | SafeStyle | SafeScript | SafeUrl | SafeResourceUrl
  {
    switch (type) {
      case 'html':
        return sanitizer.bypassSecurityTrustHtml(value);
      case 'style':
        return sanitizer.bypassSecurityTrustStyle(value);
     /* case 'script':
        return sanitizer.bypassSecurityTrustScript(value);*/
      case 'url':
        return sanitizer.bypassSecurityTrustUrl(value);
      case 'resourceUrl':
        return sanitizer.bypassSecurityTrustResourceUrl(value);
      default:
        return sanitizer.bypassSecurityTrustHtml(value);
    }
  }*/
}
