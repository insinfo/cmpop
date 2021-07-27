import 'dart:async';
import 'dart:html';
import 'package:angular/angular.dart';
import 'package:cmpop_browser/src/shared/utils/utils.dart';

@Directive(selector: '[menuDropdownDirective]')
class MenuFooterDropdownDirective implements AfterViewInit, AfterChanges, OnDestroy {
  //@Input()
  //String menuDropdownDirective = 'false';
  StreamSubscription bodyClickStreamSubscription;
  @override
  void ngAfterChanges() {}

  @override
  void ngAfterViewInit() {
    _handleEvent();
  }

  UListElement _menuRoot;

  MenuFooterDropdownDirective(HtmlElement element) {
    if (element is UListElement) {
      _menuRoot = element;
    } else {
      throw Exception('MenuDropdownDirective não pode se atribuida a um elemento diferente de UL');
    }
  }

  void _handleEvent() {
    //var li = _menuDropdownContainer.parent;
    //var rootUl = li.parent;

    Utils.addDynamicEventListener(_menuRoot, 'click', 'a', (e, delegatedTarget) {
      if (delegatedTarget.classes.contains('menu-dropdown-trigger')) {
        _menuRoot.querySelector('.menu-dropdown-container').classes.toggle('menu-dropdown-container-show');
      } else {
        // _menuDropdownContainer.classes.remove('menu-dropdown-container-show');
      }
    });

    bodyClickStreamSubscription = document.onClick.listen((event) {
      if (event.target is Element) {
        if ((event.target as Element).classes.contains('menu-dropdown-trigger') == false) {
          _menuRoot.querySelector('.menu-dropdown-container').classes.remove('menu-dropdown-container-show');
        }
      }
    });
  }

  @override
  void ngOnDestroy() {
    bodyClickStreamSubscription?.cancel();
  }
}
