import 'package:angular/angular.dart';
import 'package:cmpop_browser/src/shared/components/carousel/carousel.dart';
import 'dart:html' as html;

@Component(
  selector: 'slide',
  templateUrl: 'slide.html',
  styleUrls: ['slide.css'],
)
class SlideComponent implements OnDestroy, AfterContentInit {
  @ViewChild('slideContainer')
  html.DivElement slideContainer;

  bool active = false;
  /* @Input('active')
  set active(bool value) {
    if (value == null) {
      return;
    }
    if (value != _active) {
      _active = value;
    }
  }

  bool get active => _active;*/

  //Scope  scope;
  html.Element element;
  CarouselComponent parent;

  SlideComponent(this.element);

  @override
  void ngOnDestroy() {}

  @override
  void ngAfterContentInit() {}
}
