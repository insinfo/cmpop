//truncate_pipe
import 'package:angular/angular.dart';

/*
 * Raise the value exponentially
 * Takes an exponent argument that defaults to 1.
 * Usage:
 *   value | truncatereverse:limit
 * Example:
 *   {{ 2 |  truncatereverse:2}}
 *   formats to: bi...
 */
@Pipe('truncatereverse')
class TruncateReversePipe extends PipeTransform {
  String transform(String value, int truncateAt) {
    if (value == null) {
      return value;
    }
    //int truncateAt = value.length-1;
    var elepsis = '...'; //define your variable truncation elipsis here
    var truncated = '';

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
