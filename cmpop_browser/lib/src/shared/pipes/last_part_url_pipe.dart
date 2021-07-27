//truncate_pipe
import 'package:angular/angular.dart';

/*
 * Raise the value exponentially
 * Takes an exponent argument that defaults to 1.
 * Usage:
 *   value | lastparturl:limit
 * Example:
 *   {{ 2 |  lastparturl:2}}
 *   formats to: bi...
 */
@Pipe('lastparturl')
class LastPartUrlPipe extends PipeTransform {
  String transform(String value, int truncateAt) {
    if (value == null) {
      return value;
    }

    if (!value.contains('/')) {
      return value;
    }
    //int truncateAt = value.length-1;
    var elepsis = '...'; //define your variable truncation elipsis here
    var truncated = '';

    value = value.trim();
    value = value.lastIndexOf('/') == value.length - 1 ? value.substring(0, value.length - 1) : value;
    value = value.split('/').last;

    if (value.length > truncateAt) {
      //inverter a string
      var input = String.fromCharCodes(value.runes.toList().reversed);
      truncated = input.substring(0, truncateAt - elepsis.length);
      truncated = String.fromCharCodes(truncated.runes.toList().reversed);

      truncated = elepsis + truncated;
    } else {
      truncated = value;
    }

    return truncated;
  }
}
