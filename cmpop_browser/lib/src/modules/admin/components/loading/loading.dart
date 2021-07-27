import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'loading',
  templateUrl: 'loading.html',
  styleUrls: ['loading.css'],
  directives: [
    coreDirectives,
    formDirectives,
    routerDirectives,
  ],
)
class LoadingComponent {
  @Input()
  bool visibility = false;
}
