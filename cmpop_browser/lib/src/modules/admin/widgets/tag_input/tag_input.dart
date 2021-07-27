import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_router/angular_router.dart';

@Component(
    selector: 'tag-input',
    styleUrls: ['tag_input.css'],
    templateUrl: 'tag_input.html',
    directives: [
      routerDirectives,
      formDirectives,
      coreDirectives,
    ],
    providers: [],
    pipes: [commonPipes])
class TagInputComponent implements OnInit {
  @override
  void ngOnInit() {}
}
