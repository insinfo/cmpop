import 'dart:async';
import 'dart:html';
import 'package:angular/angular.dart';
import 'package:cmpop_browser/src/shared/utils/utils.dart';

@Directive(
  selector: '[customvalidator]',
  providers: [ClassProvider(CustomValidatorDirective)],
  exportAs: 'customvalidator',
)
class CustomValidatorDirective implements OnInit, OnDestroy, AfterViewInit {
  ///valida globalmente ou somente o campo atual
  @Input('customvalidator')
  String customvalidator = ''; // global | single

  @Input('validatorType')
  String validatorType = 'text'; //string | text | cpf | date | cnpj | email //data-validation-type="email"

  final Element el;
  InputElement inputElement;
  FormElement formElement;

  StreamSubscription ssOnInput;
  StreamSubscription ssOnSubmit;
  //observa o formulario para verificar se sera adicionado algum elemento dinamico
  MutationObserver donTreeMutationObserver;

  CustomValidatorDirective(this.el);

  var requiredFormElementsStreamSubscription = <StreamSubscription>[];

  void validateInput([bool isVisual = true, Element ele, String validationType]) {
    ele = ele ?? inputElement;
    validationType = validationType ?? validatorType;
    var value = valueOfInput(ele);

    switch (validationType) {
      case 'string':
        if (value.isEmpty || value == 'null') {
          setInvalidInput(isVisual, ele);
        } else {
          setValidInput(isVisual, ele);
        }
        break;
      case 'email':
        if (!Utils.emailIsValid(value)) {
          setInvalidInput(isVisual, ele);
        } else {
          setValidInput(isVisual, ele);
        }
        break;
      case 'cpf':
        if (!Utils.validarCPF(value)) {
          setInvalidInput(isVisual, ele);
        } else {
          setValidInput(isVisual, ele);
        }
        break;
      case 'cnpj':
        if (!Utils.validarCnpj(value)) {
          setInvalidInput(isVisual, ele);
        } else {
          setValidInput(isVisual, ele);
        }
        break;
      default: //text
        if (value.isEmpty || value == 'null') {
          // print('validateInput value $value');
          setInvalidInput(isVisual, ele);
        } else {
          setValidInput(isVisual, ele);
        }
    }
  }

  void setValidInput([bool isVisual = true, Element ele]) {
    ele = ele ?? inputElement;
    if (isVisual) {
      ele.classes.remove('is-invalid');
      ele.classes.add('is-valid');
    }
    ele.classes.remove('isInvalid');
    ele.classes.add('isValid');
  }

  void setInvalidInput([bool isVisual = true, Element ele]) {
    ele = ele ?? inputElement;
    if (isVisual) {
      ele.classes.remove('is-valid');
      ele.classes.add('is-invalid');
    }
    ele.classes.remove('isValid');
    ele.classes.add('isInvalid');
  }

  bool isFormValid() {
    var invalidEle = formElement.querySelectorAll('[required].isInvalid'); //required

    if (invalidEle.isEmpty) {
      return true;
    }
    validateInput(true, invalidEle.first, getValidationType(invalidEle.first));
    invalidEle.first.focus();
    return false;
  }

  @override
  void ngOnInit() {}

  bool isValidElements(Element el) {
    if (el is InputElement) {
      return true;
    } else if (el is TextAreaElement) {
      return true;
    } else if (el is CheckboxInputElement) {
      return true;
    } else if (el is RadioButtonInputElement) {
      return true;
    } else if (el is SelectElement) {
      return true;
    }
    return false;
  }

  String valueOfInput(Element el) {
    if (el is InputElement) {
      return el.value;
    } else if (el is TextAreaElement) {
      return el.value;
    } else if (el is CheckboxInputElement) {
      return el.value;
    } else if (el is RadioButtonInputElement) {
      return el.value;
    } else if (el is SelectElement) {
      return el.value;
    }

    return '';
  }

  @override
  void ngAfterViewInit() {
    init();
  }

  void init() {
    if (customvalidator == 'single') {
      if (el is InputElement) {
        inputElement = el;
        validateInput(false);
        ssOnInput = inputElement.onInput.listen((event) {
          validateInput();
        });
      } else {
        print(
            'Esta tag "${el.tagName}" não é valida. É necessário que esta "[customvalidator]" seja colocada em um InputElement. se for "single"');
      }
    } else if (customvalidator == 'global') {
      if (el is FormElement) {
        //observa o formulario para verificar se sera adicionado algum elemento dinamico
        donTreeMutationObserver = MutationObserver((List<dynamic> mutationsList, MutationObserver observer) {
          for (var mutation in mutationsList) {
            if (mutation.type == 'childList') {
              //print('A child node has been added or removed.');
              //print(mutation.target);
              reInitOnInputListen();
            }
          }
        });
        // Start observing the target node for configured mutations
        donTreeMutationObserver.observe(el, attributes: false, childList: true, subtree: true);

        formElement = el;
        ssOnSubmit = formElement.querySelector('button[type=submit]').onClick.listen((event) {
          if (!isFormValid()) {
            event.preventDefault();
          }
        });
        var requiredElements = formElement.querySelectorAll('[required]');
        requiredElements.forEach((element) {
          validateInput(false, element, getValidationType(element));
          if (isValidElements(element)) {
            var ss = element.onInput.listen((event) {
              validateInput(true, element, getValidationType(element));
            });

            requiredFormElementsStreamSubscription.add(ss);
          }
        });
      } else {
        print(
            'Esta tag "${el.tagName}" não é valida. É necessário que esta "[customvalidator]" seja colocada em um FormElement. se for "global"');
      }
    } else {
      print(
          'Opção invalida para a [customvalidator] tem que ser [customvalidator]="global" ou [customvalidator]="single"');
    }
  }

  void reInitOnInputListen() {
    requiredFormElementsStreamSubscription.forEach((ss) {
      ss?.cancel();
    });
    var requiredElements = formElement.querySelectorAll('[required]');
    requiredElements.forEach((element) {
      validateInput(false, element, getValidationType(element));
      if (isValidElements(element)) {
        var ss = element.onInput.listen((event) {
          validateInput(true, element, getValidationType(element));
        });
        requiredFormElementsStreamSubscription.add(ss);
      }
    });
  }

  String getValidationType(Element element) {
    if (element.attributes.containsKey('data-validation-type')) {
      return element.attributes['data-validation-type'];
    } else {
      return null;
    }
  }

  @override
  void ngOnDestroy() {
    ssOnInput?.cancel();
    ssOnSubmit?.cancel();
    // Later, you can stop observing
    donTreeMutationObserver?.disconnect();
  }
}
