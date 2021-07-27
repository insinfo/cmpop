import 'dart:async';
import 'dart:html';
import 'package:angular/angular.dart';
import 'package:cmpop_browser/src/shared/utils/utils.dart';

@Directive(selector: '[menuDropdownDirective]')
class MenuHeaderDropdownDirective implements AfterViewInit, AfterChanges, OnDestroy {
  //@Input()
  //String menuDropdownDirective = 'false';

  String classShowSubDropdown = 'show-sub-dropdown';

  StreamSubscription bodyClickStreamSubscription;
  @override
  void ngAfterChanges() {}

  @override
  void ngAfterViewInit() {
    _handleEvent();
  }

  UListElement _menuRoot;

  MenuHeaderDropdownDirective(HtmlElement element) {
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
      if (delegatedTarget.classes.contains('dropdown-trigger')) {
        _menuRoot.querySelector('.dropdown').classes.toggle(classShowSubDropdown);
      } else {
        var chec = _menuRoot.closest('.menu-horizontal').querySelector('#check') as CheckboxInputElement;
        chec.checked = false;
      }
    });

    bodyClickStreamSubscription = document.onClick.listen((event) {
      if (event.target is Element) {
        if ((event.target as Element).classes.contains('dropdown-trigger') == false) {
          _menuRoot.querySelector('.dropdown')?.classes?.remove(classShowSubDropdown);
        }
      }
    });
  }

  @override
  void ngOnDestroy() {
    bodyClickStreamSubscription?.cancel();
  }
}
